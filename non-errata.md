# non_errata.md

## Overview

The following verses in the WEBUS dataset appear as **empty entries**. These are **not errors**. They are **intentional omissions** based on modern critical Greek texts (NU/UBS tradition), while preserving canonical verse numbering.

Total verse count remains correct: **31,103**

---

## Empty Verses (Non-Errata)

### Luke 17:36

* Present in KJV
* Omitted in most modern critical texts

---

### Acts 8:37

* Contains the confession: *“I believe that Jesus Christ is the Son of God”*
* Often footnoted or omitted in modern translations

---

### Acts 15:34

* Not present in earliest manuscripts
* Considered a later addition

---

### Acts 24:7

* Later textual insertion
* Removed in critical editions

---

### Romans 16:25 (Special Case)

* Not truly missing
* Part of a **doxology that shifts location**:

  * Sometimes placed after Romans 14
  * Sometimes at the end of Romans 16
* This is a **structural placement variation**, not a true omission

---

## Key Principle

These entries are:

> **Intentional structural placeholders preserving canonical verse indexing**

They ensure:

* Alignment with standard Bible references
* Compatibility across translations
* Integrity of cross-referencing systems

---

## Recommended Handling

Do **not**:

* Delete these rows
* Renumber verses
* Attempt to “fix” the dataset

Instead, treat them as:

* Valid entries with no textual content
* Structural anchors within the canonical system

---

## Suggested Flagging (Optional)

```sql
ALTER TABLE verses ADD COLUMN is_missing INTEGER DEFAULT 0;

UPDATE verses
SET is_missing = 1
WHERE text IS NULL OR TRIM(text) = '';
```

---

## Summary

The following verses are correctly empty in WEBUS:

* Luke 17:36
* Acts 8:37
* Acts 15:34
* Acts 24:7
* Romans 16:25 (placement variation)

Your dataset is **accurate and structurally correct**.

---
