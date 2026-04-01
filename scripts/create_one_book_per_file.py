from pathlib import Path
from collections import defaultdict

ROOT = Path("../data/Bible_WebUS_One_Folder_Only")
OUT  = Path("../data/Bible_WebUS_One_File_Per_Book")
OUT.mkdir(exist_ok=True)

books = defaultdict(list)

for verse_file in ROOT.glob("*.txt"):
    parts = verse_file.stem.split("_")
    if len(parts) < 4:
        continue
    book_key = "_".join(parts[:2])  # 001_GEN
    books[book_key].append(verse_file)

for book_key, files in sorted(books.items()):
    out_file = OUT / f"{book_key}.txt"
    with out_file.open("w", encoding="ascii") as out:
        for vf in sorted(files):
            text = vf.read_text(encoding="ascii").strip()
            if text:
                out.write(text + "\n")
    print(f"Wrote {out_file}")
