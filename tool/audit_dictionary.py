"""Read-only integrity audit of the dictionary assets actually bundled by Flutter."""

import argparse
from collections import Counter
import json
from pathlib import Path
import re
import sys
import unicodedata

ROOT = Path(__file__).resolve().parent.parent


class Parser(argparse.ArgumentParser):
    def error(self, message):
        print('error: ' + json.dumps(message))
        print('help: "python3 tool/audit_dictionary.py --help"')
        raise SystemExit(2)


def audit():
    bundled = re.findall(r'AMDText_.*\.json', (ROOT / 'pubspec.yaml').read_text())
    repository = re.findall(r"'(AMDText_[^']+\.json)'", (
        ROOT / 'lib/src/services/dictionary_repository.dart').read_text())
    errors, reviews, sections = [], [], []
    ids = set()
    counts = Counter()
    if bundled != repository:
        errors.append(dict(issue='asset_manifest_mismatch'))
    for name in bundled:
        doc = json.loads((ROOT / name).read_text())
        entries = doc['entries']
        section_counts = Counter()
        if doc['entry_count'] != len(entries):
            errors.append(dict(file=name, issue='entry_count_mismatch'))
        for e in entries:
            counts['entries'] += 1
            identity = (doc['section'], e['id'])
            if identity in ids:
                errors.append(dict(file=name, id=e['id'], issue='duplicate_id'))
            ids.add(identity)
            issues = []
            for field in ('arabic', 'arabic_vocalized'):
                text = e.get(field, '')
                latin = sorted({c for c in text if 'LATIN' in unicodedata.name(c, '')})
                if latin or any(c in text for c in ['⟦', '\ufffd']):
                    errors.append(dict(file=name, id=e['id'], field=field,
                                       page=e['page'], issue='invalid_arabic', value=text))
            if not e.get('arabic', '').strip():
                issues.append('missing_arabic')
            if not e.get('myanmar', '').strip():
                issues.append('missing_myanmar')
            if e.get('needs_review') or e.get('harakat_needs_review'):
                issues.append('source_review_flag')
            if any('LATIN' in unicodedata.name(c, '') for c in e['myanmar']):
                issues.append('legacy_myanmar_characters')
            if re.search('[ٺٻۇٴ]', e['arabic'] + e.get('arabic_vocalized', '')):
                issues.append('legacy_arabic_marks')
            if issues:
                reviews.append(dict(file=name, section=doc['section'], id=e['id'],
                                    page=e['page'], column=e.get('column'), issues=issues,
                                    arabic=e['arabic'], myanmar=e['myanmar']))
                counts.update(issues)
                section_counts.update(issues)
        sections.append(dict(file=name, section=doc['section'], entries=len(entries),
                             review_counts=dict(section_counts)))
    return dict(summary=dict(sections=len(bundled), entries=counts['entries'],
                             errors=len(errors), review_entries=len(reviews),
                             source_review_flags=counts['source_review_flag'],
                             legacy_myanmar_entries=counts['legacy_myanmar_characters'],
                             legacy_arabic_mark_entries=counts['legacy_arabic_marks'],
                             missing_arabic_entries=counts['missing_arabic'],
                             missing_myanmar_entries=counts['missing_myanmar']),
                errors=errors, sections=sections, review_queue=reviews)


def main():
    if len(sys.argv) == 2 and sys.argv[1] in ('--version', '-v', '-V'):
        print('1.0.0')
        return
    parser = Parser(description=__doc__, epilog=(
        'Examples: python3 tool/audit_dictionary.py; '
        'python3 tool/audit_dictionary.py --report docs/data/entry-audit.json; '
        'python3 tool/audit_dictionary.py --strict'))
    parser.add_argument('--report', type=Path, help='Write full JSON evidence at this path')
    parser.add_argument('--strict', action='store_true', help='Also fail for unresolved linguistic review items')
    args = parser.parse_args()
    report = audit()
    print('bin: ' + json.dumps(str(Path(__file__).resolve())))
    print('description: Audit the bundled Arabic and Myanmar dictionary entries')
    for key, value in report['summary'].items():
        print(f'{key}: {value}')
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
        print('report: ' + json.dumps(str(args.report)))
    if not report['errors']:
        print('arabic_integrity: "0 Latin letters or unresolved glyph codes in both Arabic fields"')
    if report['summary']['review_entries']:
        print('linguistic_review: pending')
    if report['errors'] or (args.strict and report['summary']['review_entries']):
        sys.exit(1)


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError) as error:
        print('error: ' + json.dumps(str(error)))
        print('help: "Check asset JSON files and run python3 tool/audit_dictionary.py --help."')
        sys.exit(1)
