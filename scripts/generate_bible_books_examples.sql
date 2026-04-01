-- ============================================================
--  There are atomic tools in here that allows you to do
--  whatever you can think of.  Some Examples below.
-- ============================================================

-- ============================================================
-- generate_book.sql
-- Generate a complete Bible book from SQLite
-- Example: Book of Genesis (WebUS)
-- ============================================================

-- PARAMETERS (edit as needed)
-- ----------------------------
-- Translation: WEBUS
-- Book OSIS:   GEN
-- -----------------------------
-- Pretty Version

SELECT
    printf(
        '%s %d:%d %s',
        v.osis,
        v.chapter,
        v.verse,
        v.text
    ) AS verse_line
FROM verses v
WHERE v.translation_code = 'WEBUS'
  AND v.osis = 'GEN'
ORDER BY
    v.chapter,
    v.verse;
	

-- ============================================================
-- Print full book of Genesis with chapter headers only
-- (no verse numbers)
-- ============================================================

SELECT
    CASE
        WHEN chapter != LAG(chapter) OVER (
            ORDER BY chapter, verse
        )
        THEN printf('Genesis Chapter %d\n', chapter)
        ELSE ''
    END
    || text AS output_line
FROM verses
WHERE translation_code = 'WEBUS'
  AND osis = 'GEN'
ORDER BY chapter, verse;

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

--  “What’s the longest uninterrupted stretch of verses in Psalms that mention mercy?”

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



-- I'm going to encourage you to ask AI to generate crazy sql to do whatever you want to do with this database.