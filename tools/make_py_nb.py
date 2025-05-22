def main():
    """
    Convert rmd_chunks/python-chunks.py into a notebook
    (one code-cell per chunk, in the same order).
    """


import pathlib
import re
import nbformat as nbf

root = pathlib.Path(__file__).resolve().parents[1]  # repo root
py_chunks = root / "rmd_chunks" / "python-chunks.py"
nb_file = root / "decisioncurveanalysis-python-tutorial.ipynb"

# read and split on chunk headers
text = py_chunks.read_text()
parts = re.split(r"^##\s+----\s+([A-Za-z0-9_-]+)\s+-----\s*$", text, flags=re.M)

# parts[0] is the text before the first chunk (usually empty); skip it
chunk_pairs = zip(parts[1::2], parts[2::2])  # (chunk_name, code)

nb = nbf.v4.new_notebook()
for name, code in chunk_pairs:
    cell = nbf.v4.new_code_cell(source=code.strip() + "\n")
    cell.metadata["jupyter"] = {"source_hidden": False}
    nb.cells.append(cell)

nb.metadata["language_info"] = {"name": "python"}
nbf.write(nb, nb_file)
print(f"Wrote {nb_file.relative_to(root)}")


if __name__ == "__main__":
    main()
