python - <<'PY'
import csv

selected = {}

with open("acinetobacter_baumannii.tsv", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f, delimiter="\t")

    for row in reader:
        acc = row["Assembly Accession"].strip()
        paired = row["Assembly Paired Assembly Accession"].strip()

        if not acc.startswith(("GCA_", "GCF_")):
            continue

        # Preferir RefSeq si existe el ensamblaje emparejado
        if paired.startswith("GCF_"):
            chosen = paired
        elif acc.startswith("GCF_"):
            chosen = acc
        else:
            chosen = acc

        # Identificador común GCA/GCF
        key = chosen.split("_", 1)[1]
        selected[key] = chosen

with open("accessions.txt", "w") as out:
    for acc in sorted(selected.values()):
        out.write(acc + "\n")

print(f"Ensamblajes únicos: {len(selected)}")
PY
