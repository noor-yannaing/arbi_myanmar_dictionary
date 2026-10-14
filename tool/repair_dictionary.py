"""Recover Latin fallback characters using reviewed, page-aware source mappings.

Default is a dry run. --apply performs a mechanical rewrite of affected Arabic
fields only. Original arabic_source and all linguistic review flags survive.
"""

import argparse
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent


def main():
    if len(sys.argv) == 2 and sys.argv[1] in ('--version', '-v', '-V'):
        print('1.0.0')
        return
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-map', required=True, type=Path)
    parser.add_argument('--report', required=True, type=Path)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    source = json.loads(args.source_map.read_text())['pages']
    known = json.loads((ROOT / 'tool/legacy_arabic_glyphs.json').read_text())['glyphs']
    files = re.findall(r'AMDText_.*\.json', (ROOT / 'pubspec.yaml').read_text())
    changes, unresolved, documents = [], [], {}
    for name in files:
        document = json.loads((ROOT / name).read_text())
        documents[name] = document
        for entry in document['entries']:
            for field in ('arabic', 'arabic_vocalized'):
                before = entry.get(field, '')
                if not re.search('[A-Za-z]', before):
                    continue
                evidence = []

                def decode(match):
                    token = match.group()
                    if token.startswith('⟦'):
                        glyph = token[1:-1]
                        value = known.get(glyph)
                        candidates = [glyph]
                    else:
                        rows = [r for r in source[str(entry['page'])]
                                if r['character'] == token and
                                r['uses'].get(entry['column'], 0) > 0 and
                                (r['glyph'] in known or len(r['unicode'] or '') > 1)]
                        values = {known.get(r['glyph'], r['unicode']) for r in rows}
                        candidates = sorted({r['glyph'] for r in rows})
                        value = next(iter(values)) if len(values) == 1 else None
                    if value is None:
                        unresolved.append(dict(file=name, id=entry['id'], field=field,
                                               page=entry['page'], token=token, candidates=candidates))
                        return token
                    evidence.append(dict(token=token, glyphs=candidates, replacement=value))
                    return value

                after = re.sub(r'⟦g\d+⟧|[A-Za-z]', decode, before)
                if after != before:
                    changes.append(dict(file=name, section=document['section'], id=entry['id'],
                                        page=entry['page'], column=entry['column'], field=field,
                                        before=before, after=after, evidence=evidence))
                    entry[field] = after
    report = dict(changed_fields=len(changes),
                  changed_entries=len({(c['file'], c['id']) for c in changes}),
                  unresolved=unresolved, changes=changes)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    if args.apply and not unresolved:
        for name in {c['file'] for c in changes}:
            (ROOT / name).write_text(json.dumps(documents[name], ensure_ascii=False, indent=2) + '\n')
    print(f'mode: {"apply" if args.apply else "dry-run"}\nchanged_entries: {report["changed_entries"]}'
          f'\nchanged_fields: {len(changes)}\nunresolved: {len(unresolved)}\nreport: {args.report}')
    if unresolved:
        print('status: "No dictionary files written; ambiguous mappings require source review."')
        sys.exit(1)


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, KeyError) as error:
        print('error: ' + json.dumps(str(error)))
        print('help: "Run python3 tool/repair_dictionary.py --help and check the source-map path."')
        sys.exit(1)
