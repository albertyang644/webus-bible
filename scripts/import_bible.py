import sqlite3
import pathlib
import re
import os

# ---------------- CONFIG ----------------
BASE_DIR = pathlib.Path(__file__).resolve().parent

DB_PATH = BASE_DIR / "../db/bible.sqlite3"
VERSE_DIR = BASE_DIR / "../data/Bible_WebUS_One_Folder_Only"

TRANSLATION = "WEBUS"

FILENAME_RE = re.compile(r'^(\d{3})_([A-Z0-9]{3})_(\d{3})_(\d{3})\.txt$')
# ----------------------------------------


def main():
    print("USING DB:", os.path.abspath(DB_PATH))

    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON")
    cur = conn.cursor()

    files = sorted(p for p in VERSE_DIR.iterdir() if p.suffix == ".txt")
    if not files:
        raise RuntimeError("No .txt files found in verse directory")

    rows = []
    ordinal = 1

    for path in files:
        m = FILENAME_RE.match(path.name)
        if not m:
            raise ValueError(f"Invalid filename: {path.name}")

        book_order = int(m.group(1))
        osis       = m.group(2)
        chapter    = int(m.group(3))
        verse      = int(m.group(4))

        text = path.read_text(encoding="ascii").strip()
        byte_len = len(text.encode("ascii"))

        rows.append((
            TRANSLATION,
            book_order,
            osis,
            chapter,
            verse,
            text,
            path.name,
            byte_len,
            ordinal
        ))

        ordinal += 1

    print(f"Prepared {len(rows)} verse rows")

    cur.execute("SELECT osis FROM osis_to_detailed_name")
    valid_osis = {row[0] for row in cur.fetchall()}

    bad_osis = sorted({row[2] for row in rows if row[2] not in valid_osis})
    if bad_osis:
        raise RuntimeError(f"OSIS codes missing from ontology: {bad_osis}")

    print("OSIS validation passed")
    print("BEGIN BULK INSERT")

    conn.execute("BEGIN")
    cur.executemany("""
        INSERT INTO verses (
            translation_code,
            book_order,
            osis,
            chapter,
            verse,
            text,
            filename,
            byte_len,
            global_ordinal
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, rows)
    conn.commit()

    print("BULK INSERT COMPLETE")
    print(f"Inserted {len(rows)} verses.")


if __name__ == "__main__":
    main()
