"""Inspect the source PDF's glyph names without changing dictionary data.

Uses pdfminer.six, a development tool only. Produces a source-font specimen PDF
and machine-readable page mappings for review; no font is shipped with the app.
"""

import argparse
from collections import defaultdict
import io
import json
from pathlib import Path
import re
import sys
import unicodedata


def main():
    if len(sys.argv) == 2 and sys.argv[1] in ('--version', '-v', '-V'):
        print('1.0.0')
        return
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-pdf', required=True)
    parser.add_argument('--out', required=True, help='Directory for generated evidence')
    args = parser.parse_args()
    from pdfminer.pdfparser import PDFParser
    from pdfminer.pdfdocument import PDFDocument
    from pdfminer.pdfpage import PDFPage
    from pdfminer.pdftypes import resolve1
    from pdfminer.psparser import literal_name
    from pdfminer.pdfdevice import PDFTextDevice
    from pdfminer.pdfinterp import PDFPageInterpreter, PDFResourceManager

    class Resources(PDFResourceManager):
        def get_font(self, objid, spec):
            font = super().get_font(objid, spec)
            font.source_object_id = objid
            return font

    class Usage(PDFTextDevice):
        def render_char(self, matrix, font, fontsize, scaling, rise, cid, ncs, graphicstate):
            # Exclude running headers and page numbers. Coordinates are PDF points.
            if 30 < matrix[5] < self.height - 50:
                column = 'right' if matrix[4] >= self.width / 2 else 'left'
                self.counts[(font.source_object_id, cid, column)] += 1
            return font.char_width(cid) * fontsize * scaling

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    pages = {}
    specimens = {}
    fonts = {}
    with open(args.source_pdf, 'rb') as source:
        doc = PDFDocument(PDFParser(source))
        resources = Resources()
        usage = Usage(resources)
        interpreter = PDFPageInterpreter(resources, usage)
        for number, page in enumerate(PDFPage.create_pages(doc), 1):
            usage.counts = defaultdict(int)
            usage.width, usage.height = page.mediabox[2:]
            interpreter.process_page(page)
            rows = []
            for ref in resolve1(page.resources.get('Font', {})).values():
                spec = resolve1(ref)
                name = literal_name(spec['BaseFont'])
                if 'MUHAMMADI' not in name:
                    continue
                enc = resolve1(spec.get('Encoding', {}))
                differences = enc.get('Differences', []) if isinstance(enc, dict) else []
                for item in differences:
                    if isinstance(item, int):
                        code = item
                        continue
                    glyph = literal_name(item)
                    if (re.fullmatch(r'g\d+', glyph) or
                            (glyph.startswith('uni') and '.' in glyph) or
                            glyph in ('uni067A', 'uni067B', 'uni0674', 'uni06C7')):
                        base = glyph.split('.')[0][3:]
                        decoded = None
                        if re.fullmatch(r'(?:[0-9A-Fa-f]{4})+', base):
                            decoded = unicodedata.normalize('NFKC', ''.join(
                                chr(int(base[i:i + 4], 16)) for i in range(0, len(base), 4)
                            ))
                        row = dict(code=code, character=chr(code), glyph=glyph,
                                   unicode=decoded, font=name, font_id=ref.objid)
                        row['uses'] = {column: usage.counts[(ref.objid, code, column)]
                                       for column in ('right', 'left')}
                        rows.append(row)
                        if glyph not in specimens:
                            specimens[glyph] = dict(page=number, **row)
                            descriptor = resolve1(spec['FontDescriptor'])
                            fonts[ref.objid] = (spec, descriptor,
                                               resolve1(descriptor['FontFile2']).get_data())
                    code += 1
            pages[str(number)] = rows
        (out / 'source-font-mappings.json').write_text(
            json.dumps(dict(pages=pages, specimens=specimens), ensure_ascii=False, indent=2) + '\n'
        )
        write_specimen(out / 'source-glyph-specimens.pdf', specimens, fonts)
    print(f'pages: {len(pages)}\nglyphs: {len(specimens)}\nreport: {out / "source-font-mappings.json"}\nspecimens: {out / "source-glyph-specimens.pdf"}')


def write_specimen(path, specimens, fonts):
    """Make a diagnostic PDF displaying actual embedded source glyph outlines."""
    objects = []

    def add(data):
        objects.append(data if isinstance(data, bytes) else data.encode('ascii'))
        return len(objects)

    def stream(data, extra=''):
        return add(f'<< /Length {len(data)} {extra} >>\nstream\n'.encode() + data + b'\nendstream')

    catalog = add('')
    page_tree = add('')
    helvetica = add('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>')
    font_refs = {}
    from pdfminer.psparser import literal_name
    for font_id, (spec, desc, data) in fonts.items():
        name = literal_name(spec['BaseFont'])
        font_file = stream(data, f'/Length1 {len(data)}')
        bbox = ' '.join(str(v) for v in desc['FontBBox'])
        descriptor = add(f'<< /Type /FontDescriptor /FontName /{name} /Flags 4 '
                         f'/FontBBox [{bbox}] /ItalicAngle 0 /Ascent {desc["Ascent"]} '
                         f'/Descent {desc["Descent"]} /CapHeight {desc["CapHeight"]} '
                         f'/StemV 100 /FontFile2 {font_file} 0 R >>')
        differences = resolve_encoding(spec)
        widths = ' '.join(str(v) for v in spec['Widths'])
        font_refs[font_id] = add(f'<< /Type /Font /Subtype /TrueType /BaseFont /{name} '
                             f'/FirstChar {spec["FirstChar"]} /LastChar {spec["LastChar"]} '
                             f'/Widths [{widths}] /FontDescriptor {descriptor} 0 R '
                             f'/Encoding << /Type /Encoding /BaseEncoding /WinAnsiEncoding '
                             f'/Differences [{differences}] >> >>')
    keys = sorted(specimens, key=lambda x: (not x.startswith('g'), x))
    page_ids = []
    for start in range(0, len(keys), 40):
        commands = ['BT /H 16 Tf 28 820 Td (Original dictionary font specimens) Tj ET']
        resources = [f'/H {helvetica} 0 R']
        for i, key in enumerate(keys[start:start + 40]):
            row = specimens[key]
            x, y = 25 + (i % 4) * 145, 750 - (i // 4) * 76
            fid = font_refs[row['font_id']]
            resources.append(f'/F{i} {fid} 0 R')
            commands += [f'BT /H 9 Tf {x} {y + 28} Td ({key}) Tj ET',
                         f'BT /H 8 Tf {x} {y + 17} Td (Source page {row["page"]}) Tj ET',
                         f'BT /F{i} 32 Tf {x + 42} {y - 10} Td <{row["code"]:02x}> Tj ET']
        content = stream('\n'.join(commands).encode('ascii'))
        page_ids.append(add(f'<< /Type /Page /Parent {page_tree} 0 R /MediaBox [0 0 610 850] '
                            f'/Resources << /Font << {" ".join(resources)} >> >> '
                            f'/Contents {content} 0 R >>'))
    objects[catalog - 1] = f'<< /Type /Catalog /Pages {page_tree} 0 R >>'.encode()
    objects[page_tree - 1] = (f'<< /Type /Pages /Count {len(page_ids)} /Kids [' +
                            ' '.join(f'{p} 0 R' for p in page_ids) + '] >>').encode()
    result = io.BytesIO()
    result.write(b'%PDF-1.4\n')
    offsets = [0]
    for n, obj in enumerate(objects, 1):
        offsets.append(result.tell())
        result.write(f'{n} 0 obj\n'.encode() + obj + b'\nendobj\n')
    xref = result.tell()
    result.write(f'xref\n0 {len(objects) + 1}\n0000000000 65535 f \n'.encode())
    for offset in offsets[1:]:
        result.write(f'{offset:010d} 00000 n \n'.encode())
    result.write(f'trailer << /Size {len(objects) + 1} /Root {catalog} 0 R >>\nstartxref\n{xref}\n%%EOF'.encode())
    path.write_bytes(result.getvalue())


def resolve_encoding(spec):
    from pdfminer.pdftypes import resolve1
    from pdfminer.psparser import literal_name
    enc = resolve1(spec['Encoding'])
    return ' '.join(str(v) if isinstance(v, int) else '/' + literal_name(v)
                    for v in enc['Differences'])


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, ImportError) as error:
        print('error: ' + json.dumps(str(error)))
        print('help: "Run python3 tool/inspect_source_fonts.py --help; pdfminer.six is needed only for source inspection."')
        sys.exit(1)
