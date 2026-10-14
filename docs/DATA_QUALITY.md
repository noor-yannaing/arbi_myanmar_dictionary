# Dictionary character audit

The Arabic/English mixing reported in search results was present in the stored
dictionary entries. It was not caused by a keyboard, search ranking, or English
UI labels. Both Arabic fields fed the problem into the search index and UI.

## Repair completed

| Measure | Result |
| --- | ---: |
| Bundled sections audited | 28 |
| Records audited | 17,020 |
| Entries corrected | 412 |
| Fields corrected | 824 |
| Section files changed | 23 |
| Latin letters remaining in either Arabic field | 0 |
| `⟦gNNNN⟧` placeholders remaining in either Arabic field | 0 |
| Ambiguous replacements applied | 0 |

Examples from the source-backed correction ledger:

| Source page | Extracted text | Corrected text |
| --- | --- | --- |
| 53 | `بر⟦g1946⟧ (ج) برا⟦g1946⟧` | `برثن (ج) براثن` |
| 54 | `بر⟦g1966⟧` | `برطم` |
| 71 | `تز⟦g2008⟧ ( تز⟦g2008⟧ا)` | `تزنر ( تزنرا)` |
| 288 | `كاcس(ج)كوابيس` | `كابوس(ج)كوابيس` |
| 295 | `كهرHء` | `كهرباء` |
| 326 | `مصطL` | `مصطفى` |

The PDF's custom font uses ligatures: one encoded glyph can draw several Arabic
letters. A fallback character is meaningful only in its own page/font context.
The same letter can map differently elsewhere. We decoded named Unicode
ligatures, rendered the original font's unnamed glyphs, and checked replacements
against page/column usage. Font object IDs are tracked because subset names can
also repeat with different encodings.

The original `arabic_source`, Myanmar definitions, IDs, page/column metadata,
record order and extraction-review flags are preserved. Display/search fields
are fixed at source; runtime stripping, hiding entries, and replacing letters
with blank strings are not used.

## What still needs source review

The complete [review queue](data/entry-audit.json) contains 1,573 unique entries.
Categories overlap; these numbers must not be added together.

| Finding | Entries | Interpretation |
| --- | ---: | --- |
| Original extraction/harakat review flag | 1,112 | Existing uncertainty about text, glyphs or vowel positions |
| Latin legacy characters in Myanmar | 493 | Examples include ü, ò, ó and í; requires Myanmar source conversion review |
| Legacy Arabic mark codes | 604 | Includes ٺ, ٻ and the pair ئۇٴ; some represent separately positioned source marks |
| Missing Arabic headword | 3 | Qaf #711, Mim #520 and Mim #698; likely continuation rows |
| Missing Myanmar definition | 10 | Alif #61–65, #1898, #2056, #2076, #2091 and #2336 |

One additional Alif record (#60) has an empty vocalized field but a nonempty
plain Arabic field. The model already falls back to plain Arabic in this case.
No replacement text has been invented for missing fields. Final editorial
proofreading must compare entire source rows, the neighboring continuation
lines, Arabic diacritics, and Myanmar meanings.

Dotless yeh in transcribed ligatures is represented as `ى` to preserve the
visible source glyph; search folds it to `ي`. Some source dot marks remain as
separate legacy code points. Vowel positions already marked as uncertain remain
uncertain. Removing Latin artifacts does not establish that those entries are
linguistically flawless.

## Reproduce the checks

```sh
python3 tool/audit_dictionary.py --report docs/data/entry-audit.json
flutter test
flutter analyze
```

The ordinary audit fails on Latin/placeholder corruption, manifest mismatch,
duplicate IDs, or bad section counts. It reports the editorial queue separately.
`python3 tool/audit_dictionary.py --strict` also fails while that queue remains.
That stricter result is expected for this corpus and is an honest publication
gate; it must not be reported as passed.

[character-corrections.json](data/character-corrections.json) records the section,
entry ID, page, column, field, original value, repaired value, and decoded glyph
for every field changed. The source-inspection and repair commands are explained
in [ARCHITECTURE.md](ARCHITECTURE.md#regenerate-source-encoding-evidence).
