-- ============================================================
-- fts5_examples.sql
-- Example Full-Text Search (FTS5) queries for Bible WebUS
-- ============================================================

-- ------------------------------------------------------------
-- 1. Basic full-text search
-- Find verses containing the word "light"
-- ------------------------------------------------------------
SELECT
    v.book_order,
    v.osis,
    v.chapter,
    v.verse,
    v.text
FROM verses_fts f
JOIN verses v ON v.verse_id = f.rowid
WHERE f.text MATCH 'light'
ORDER BY v.global_ordinal
LIMIT 10;


-- ------------------------------------------------------------
-- 2. Phrase search
-- Exact phrase match (words must be adjacent)
-- ------------------------------------------------------------
SELECT
    v.osis,
    v.chapter,
    v.verse,
    v.text
FROM verses_fts f
JOIN verses v ON v.verse_id = f.rowid
WHERE f.text MATCH '"eternal life"';


-- ------------------------------------------------------------
-- 3. AND search
-- Both words must appear (any distance)
-- ------------------------------------------------------------
SELECT
    v.osis,
    v.chapter,
    v.verse,
    v.text
FROM verses_fts f
JOIN verses v ON v.verse_id = f.rowid
WHERE f.text MATCH 'father light';


-- ------------------------------------------------------------
-- 4. OR search
-- Either word may appear
-- ------------------------------------------------------------
SELECT
    v.osis,
    v.chapter,
    v.verse,
    v.text
FROM verses_fts f
JOIN verses v ON v.verse_id = f.rowid
WHERE f.text MATCH 'father OR light';


-- ------------------------------------------------------------
-- 5. Proximity search (NEAR)
-- Words within ~10 tokens of each other
-- NOTE: distance is approximate, tokenizer-dependent
-- ------------------------------------------------------------
SELECT DISTINCT
    v2.osis,
    v2.chapter,
    v2.verse,
    v2.text
FROM verses_fts
JOIN verses v1 ON v1.verse_id = verses_fts.rowid
JOIN verses v2
  ON v2.global_ordinal BETWEEN v1.global_ordinal - 4
                          AND v1.global_ordinal + 4
WHERE verses_fts MATCH 'God'
  AND v2.verse_id IN (
      SELECT rowid
      FROM verses_fts
      WHERE verses_fts MATCH 'people'
  )
ORDER BY v2.global_ordinal
LIMIT 20;



-- ------------------------------------------------------------
-- 6. Ranked results using bm25()
-- Lower score = more relevant
-- ------------------------------------------------------------
SELECT
    v.osis,
    v.chapter,
    v.verse,
    v.text,
    bm25(verses_fts) AS score
FROM verses_fts
JOIN verses v ON v.verse_id = verses_fts.rowid
WHERE verses_fts.text MATCH 'light'
ORDER BY score
LIMIT 10;


-- ------------------------------------------------------------
-- 7. Restrict FTS results to a specific book
-- (FTS + structured filtering)
-- ------------------------------------------------------------
SELECT
    v.osis,
    v.chapter,
    v.verse,
    v.text
FROM verses_fts f
JOIN verses v ON v.verse_id = f.rowid
WHERE f.text MATCH 'light'
  AND v.osis = 'JHN'
ORDER BY v.chapter, v.verse;


-- ------------------------------------------------------------
-- 8. Restrict to Old Testament only
-- ------------------------------------------------------------
SELECT
    v.osis,
    v.chapter,
    v.verse,
    v.text
FROM verses_fts f
JOIN verses v ON v.verse_id = f.rowid
JOIN osis_to_detailed_name o ON o.osis = v.osis
WHERE f.text MATCH 'light'
  AND o.testament = 'OT'
ORDER BY v.global_ordinal
LIMIT 20;


-- ------------------------------------------------------------
-- 9. Combine FTS with verse-distance logic
-- Example: verses containing "light" within a range of ordinals
-- ------------------------------------------------------------
SELECT
    v.osis,
    v.chapter,
    v.verse,
    v.text
FROM verses_fts f
JOIN verses v ON v.verse_id = f.rowid
WHERE f.text MATCH 'light'
  AND v.global_ordinal BETWEEN 26000 AND 27000
ORDER BY v.global_ordinal;


-- ------------------------------------------------------------
-- 10. Debug helper
-- Count how many verses match a term
-- ------------------------------------------------------------
SELECT COUNT(*) AS match_count
FROM verses_fts
WHERE text MATCH 'light';



--------------------------------------------------------------------
--  With the variable global_ordinal you can now do cool things LIKE
--------------------------------------------------------------------


--  “How far apart are Isaiah 53:5 and Matthew 8:17 — exactly?”

SELECT
    ABS(
        (SELECT global_ordinal FROM verses
         WHERE osis='ISA' AND chapter=53 AND verse=5)
      -
        (SELECT global_ordinal FROM verses
         WHERE osis='MAT' AND chapter=8 AND verse=17)
    ) AS verse_distance;

--  “Give me ±3 verses around John 1:14, regardless of chapter boundaries.”

SELECT
    osis,
    chapter,
    verse,
    text
FROM verses
WHERE global_ordinal BETWEEN
      (SELECT global_ordinal FROM verses
       WHERE osis='JHN' AND chapter=1 AND verse=14) - 3
  AND (SELECT global_ordinal FROM verses
       WHERE osis='JHN' AND chapter=1 AND verse=14) + 3
ORDER BY global_ordinal;

--  “Find verses where light and darkness occur within 5 verses of each other.”

SELECT
    a.osis,
    a.chapter,
    a.verse,
    a.text AS verse_a,
    b.text AS verse_b
FROM verses a
JOIN verses b
  ON ABS(a.global_ordinal - b.global_ordinal) <= 5
WHERE a.text LIKE '%light%'
  AND b.text LIKE '%darkness%'
ORDER BY a.global_ordinal
LIMIT 10;

-- “What’s the longest uninterrupted stretch of verses in Psalms that mention mercy?”
WITH matches AS (
    SELECT
        global_ordinal,
        global_ordinal
        - ROW_NUMBER() OVER (ORDER BY global_ordinal) AS grp
    FROM verses
    WHERE osis='PSA'
      AND text LIKE '%mercy%'
)
SELECT
    MIN(global_ordinal) AS start,
    MAX(global_ordinal) AS end,
    COUNT(*) AS length
FROM matches
GROUP BY grp
ORDER BY length DESC
LIMIT 1;


-- ============================================================
-- Want to read the Bible in a Year? Break it up to 365 chunks.
-- 365-day reading chunks (roughly equal by verse count)
-- Output: day, start ref, end ref, total words
-- ============================================================

WITH
params AS (
  SELECT
    'WEBUS' AS translation,
    365     AS days
),
total AS (
  SELECT
    MAX(v.global_ordinal) AS max_ord
  FROM verses v
  JOIN params p ON p.translation = v.translation_code
),
assigned AS (
  SELECT
    v.translation_code,
    v.global_ordinal,
    v.osis,
    v.chapter,
    v.verse,
    v.text,

    -- Day assignment: 1..365 (based on position along the global ordinal line)
    ((v.global_ordinal - 1) * (SELECT days FROM params) / (SELECT max_ord FROM total)) + 1
      AS day,

    -- Word count per verse (simple whitespace word counting)
    CASE
      WHEN length(trim(v.text)) = 0 THEN 0
      ELSE
        (length(trim(v.text)) - length(replace(trim(v.text), ' ', '')) + 1)
    END AS word_count
  FROM verses v
  JOIN params p ON p.translation = v.translation_code
),
day_ranges AS (
  SELECT
    day,
    MIN(global_ordinal) AS start_ord,
    MAX(global_ordinal) AS end_ord,
    SUM(word_count)     AS total_words
  FROM assigned
  GROUP BY day
),
start_ref AS (
  SELECT
    d.day,
    a.osis    AS start_osis,
    a.chapter AS start_chapter,
    a.verse   AS start_verse
  FROM day_ranges d
  JOIN assigned a
    ON a.day = d.day
   AND a.global_ordinal = d.start_ord
),
end_ref AS (
  SELECT
    d.day,
    a.osis    AS end_osis,
    a.chapter AS end_chapter,
    a.verse   AS end_verse
  FROM day_ranges d
  JOIN assigned a
    ON a.day = d.day
   AND a.global_ordinal = d.end_ord
)

SELECT
  d.day,

  s.start_osis   AS start_book,
  s.start_chapter,
  s.start_verse,

  e.end_osis     AS end_book,
  e.end_chapter,
  e.end_verse,

  d.total_words
FROM day_ranges d
JOIN start_ref s ON s.day = d.day
JOIN end_ref   e ON e.day = d.day
ORDER BY d.day;

-- “Generate 90-second narration chunks (~20 verses per chunk).”
SELECT
    (global_ordinal - 1) / 20 AS chunk_id,
    MIN(global_ordinal) AS start,
    MAX(global_ordinal) AS end,
    GROUP_CONCAT(text, ' ') AS chunk_text
FROM verses
GROUP BY chunk_id
ORDER BY chunk_id;

-- ============================================================
-- Thematic Density Heatmap: Which books have the highest "concentration" of a keyword?
-- (e.g., 'faith' – verses mentioning it per total verses in book, as a percentage)
-- Output: book, density percentage, total mentions
-- ============================================================
WITH book_stats AS (
    SELECT
        osis,
        COUNT(*) AS total_verses,
        SUM(CASE WHEN text LIKE '%faith%' THEN 1 ELSE 0 END) AS mentions
    FROM verses
    WHERE translation_code = 'WEBUS'
    GROUP BY osis
)
SELECT
    osis,
    ROUND((mentions * 100.0 / total_verses), 2) AS density_pct,
    mentions
FROM book_stats
WHERE mentions > 0
ORDER BY density_pct DESC
LIMIT 10;
-- ============================================================
-- End of examples
-- ============================================================

-- I'm going to encourage you to ask AI to generate crazy sql to do whatever you want to do with this database.