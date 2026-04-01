-- Create sql for Bible.sqlite3

CREATE TABLE verses (
    verse_id         INTEGER PRIMARY KEY,

    translation_code TEXT    NOT NULL,
    book_order       INTEGER NOT NULL,
    osis             TEXT    NOT NULL,
    chapter          INTEGER NOT NULL,
    verse            INTEGER NOT NULL,

    text             TEXT    NOT NULL,
    filename         TEXT    NOT NULL,
    byte_len         INTEGER NOT NULL,

    global_ordinal   INTEGER NOT NULL,

    UNIQUE(translation_code, book_order, chapter, verse),
    UNIQUE(translation_code, global_ordinal),

    FOREIGN KEY (osis) REFERENCES osis_to_detailed_name(osis)
);

CREATE TABLE osis_to_detailed_name (
    osis            TEXT PRIMARY KEY,   -- GEN, EXO, JHN
    book_order      INTEGER NOT NULL,   -- 1..66 (matches filename BBB)
    short_name      TEXT NOT NULL,      -- Gen, Exod, John
    long_name       TEXT NOT NULL,      -- Genesis, Exodus, John
    testament       TEXT CHECK(testament IN ('OT','NT')) NOT NULL
);

CREATE VIRTUAL TABLE verses_fts
USING fts5(
    text,
    content='verses',
    content_rowid='verse_id'
);
CREATE INDEX IF NOT EXISTS idx_verses_translation_osis
ON verses (translation_code, osis);

CREATE INDEX IF NOT EXISTS idx_verses_book_chapter_verse
ON verses (translation_code, book_order, chapter, verse);

CREATE INDEX IF NOT EXISTS idx_verses_translation_global_ordinal
ON verses (translation_code, global_ordinal);

