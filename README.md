# Bible WebUS — Canonical Scripture as Data

This repository provides a **canonical, open, and computation-first representation of the Bible (World English Bible, US edition)** designed for long-term durability, precise analysis, and unrestricted reuse.

The project treats Scripture as **structured data**, not as a presentation artifact.

---

## What This Repository Contains

### 🗄️ Canonical Dataset
- **`db/bible.sqlite3`** — SQLite database containing every verse as an atomic record
  - Deterministic ordering via `global_ordinal`
  - OSIS-compliant book identifiers
  - Ready for querying, analysis, and application use

### 📄 Source Artifacts
- **`data/Bible_WebUS_One_Folder_Only.zip`**
- **`data/Bible_WebUS_One_Folder_Per_Book.zip`**

These ZIP archives contain the original **ASCII flat-file verse sources**, preserved for transparency and reproducibility.

### 🧱 Schema & Reference Data
- **`sql/schema.sql`** — Database schema
- **`sql/osis_to_detailed_name.csv`** — Canonical book ontology (66 books)

### 🛠️ Tooling
- **`scripts/import_bible.py`** — Deterministic import pipeline from flat files into SQLite

---

## Documentation

- 📘 **[Whitepaper](whitepaper.md)**  
  Architectural rationale, theological perspective, and design philosophy.

- 📄 **[Filename Specification](filename_desc.md)**  
  Canonical verse filename format and guarantees.

---

## Design Principles (Summary)

- **Atomic data** — one verse per record
- **Derived structure** — chapters and books are reconstructed, not embedded
- **Absolute position** — every verse has a unique global ordinal
- **Orthogonal access** — sequence, proximity, and content are independent
- **Longevity-first** — ASCII, SQLite, no external dependencies

---

## Example Queries

Generate a complete book:

```sql
SELECT chapter, verse, text
FROM verses
WHERE translation_code = 'WEBUS'
  AND osis = 'GEN'
ORDER BY global_ordinal;
```

Measure distance between verses:

```sql
SELECT ABS(
  (SELECT global_ordinal FROM verses WHERE osis='ISA' AND chapter=53 AND verse=5)
- (SELECT global_ordinal FROM verses WHERE osis='MAT' AND chapter=8 AND verse=17)
) AS verse_distance;
```

---

## Intended Use

This dataset is suitable for:

- Bible study tools
- Research and linguistic analysis
- Reading-plan generation
- Audio narration pipelines
- Mobile and desktop applications
- Long-term archival preservation

It is intentionally **presentation-agnostic**.

---

## License

The World English Bible (WEB) text is in the public domain.

All schema, tooling, and documentation in this repository are released under a permissive open-source license unless otherwise noted.

---

## Final Note

This project exists to **remove friction between the reader and the text**.

Good data design, in this context, is an act of stewardship.  May this text allow you to draw closer to God.
