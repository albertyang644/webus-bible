# Filename Specification — Bible WebUS

This document defines the canonical filename format used for all verse-level source files in the Bible WebUS dataset.

The filename itself is treated as a first-class data interface:
self-describing, position-stable, human-readable, and machine-parseable.

OSIS in this case is 3 letters for every book of the Bible.

---

## 1. Canonical Filename Format

BBB_OSIS_CCC_VVV.txt

Example:
001_GEN_001_001.txt

---

## 2. Field Definitions

BBB   (3 digits)  Canonical book order (001–066)  
OSIS  (3 chars)   OSIS book code (e.g., GEN, MAT, JHN)  
CCC   (3 digits)  Chapter number (zero-padded)  
VVV   (3 digits)  Verse number (zero-padded)  
.txt               Plain ASCII text file  

All segments are fixed-width and zero-padded.

---

## 3. Semantic Meaning

### 3.1 Book Order (BBB)

- Encodes the canonical Protestant Bible order
- Independent of language or translation
- Enables absolute ordering without lookups

Examples:
001 → Genesis
039 → Malachi
040 → Matthew
066 → Revelation

---

### 3.2 OSIS Code (OSIS)

- Standardized OSIS 3-letter book identifiers
- Matches entries in osis_to_detailed_name
- Stable across datasets and tooling

Examples:
GEN → Genesis
PSA → Psalms
JHN → John
REV → Revelation

---

### 3.3 Chapter (CCC) and Verse (VVV)

- Decimal integers
- Zero-padded to width 3
- No embedded ranges
- No verse suffixes (e.g., a, b)

Each file represents exactly one verse.

---

## 4. Ordering Guarantees

Because all components are fixed-width:

- Lexicographic order equals canonical Bible order
- Files can be sorted using a simple string sort
- No locale, collation, or numeric parsing required

This guarantees correct ordering from Genesis 1:1 through Revelation 22:21.

---

## 5. Atomicity Guarantees

Each file is atomic:

- Exactly one verse
- No embedded structure
- No cross-verse dependencies
- No formatting markup

This enables deterministic ingestion, idempotent imports, and precise validation.

---

## 6. Character Encoding

- Files are ASCII-only
- No Unicode normalization required
- Safe for legacy systems, embedded devices, and long-term archival

---

## 7. What Filenames Do Not Encode (by design)

The filename intentionally does not include:

- Translation name
- Language
- Testament
- Pericope or section headings
- Cross-references
- Formatting or markup

Those belong in metadata tables, not filenames.

---

## 8. Rationale

This scheme was chosen to satisfy:

- Human readability
- Machine determinism
- Stable sorting
- Cross-platform portability
- Long-term archival safety

The filename alone answers:
What book is this, what chapter is this, what verse is this, and where does it belong?

---

## 9. Relationship to SQLite Dataset

Filename fields map directly to database columns:

BBB   → book_order
OSIS  → osis
CCC   → chapter
VVV   → verse

The SQLite database adds global_ordinal, full-text search, joins, and analytics.

The filename remains the source-level canonical identifier.

---

## 10. Stability Guarantee

This filename format is considered stable.

Any future change would require:
- a new dataset version
- explicit migration tooling
- preserved backward compatibility

---

## 11. Summary

The filename format is deterministic, self-describing, and stable.

BBB_OSIS_CCC_VVV.txt

It is part of the dataset’s public contract, not an implementation detail.
