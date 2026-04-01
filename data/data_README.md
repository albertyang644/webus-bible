# Bible WebUS Dataset

A structured, machine-ready version of the **World English Bible (WEBUS)** designed for programmatic use, data pipelines, and AI workflows.

---

## Overview

* **31,103 verses**
* One verse per record / file
* Canonical `(book, chapter, verse)` structure
* OSIS-based book codes (e.g., `GEN`, `ROM`, `MAT`)
* Optimized for:

  * SQLite / relational databases
  * AI ingestion
  * bulk text processing

---

## Data Formats

Two distribution formats are provided:

### 1. One Folder Only (**Recommended**)

* All verses in a single directory
* Ideal for:

  * scripting
  * bulk ingestion
  * AI pipelines

### 2. One File Per Book

* Verses grouped by book
* Easier for manual browsing and inspection

📦 Download from the **Releases** section.

---

## File Naming Convention

Each verse file follows a structured naming format:

```text
BBB_BOOK_CCC_VVV.txt
```

Example:

```text
042_LUK_017_036.txt
```

Where:

* `BBB` = book order
* `BOOK` = OSIS code
* `CCC` = chapter (zero-padded)
* `VVV` = verse (zero-padded)

See `filename_desc.md` for full details.

---

## Database Notes

* `osis` → canonical book identifier (stable, language-neutral)
* `book` → alias for usability (mirrors `osis`)
* `chapter`, `verse` → numeric structure
* `text` → verse content

Design principle:

> **Machine precision internally, human clarity externally**

---

## Known Structural Notes

Some entries may appear unusual but are **intentional**:

* Certain verses are present but empty (e.g., Acts 8:37)
* The Romans doxology appears at **Romans 14:26** instead of 16:25–27

These are not errors.

See:

* `docs/anomalies/missing_verses.md`
* `docs/anomalies/romans_doxology_note.md`

---

## Design Goals

This dataset prioritizes:

* Canonical verse alignment
* Structural consistency
* Cross-translation compatibility
* Zero ambiguity for programmatic use

---

## License

World English Bible (WEB) is in the public domain.
(Confirm specific WEBUS attribution if required.)

---

## Summary

* Use **One Folder Only** for automation
* Use **One File Per Book** for exploration
* Treat anomalies as **intentional structure**, not errors

---
