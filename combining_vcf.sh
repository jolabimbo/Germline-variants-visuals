import pandas as pd
from pathlib import Path
import re
import gzip
import io

### === STEP 1: COMBINE ANNOTATED TXT FILES === ###
print("🔹 Step 1: Combining annotated TXT files...")

annotated_folder = Path("output")  # Change if your folder has a different name
txt_dfs = []

for f in annotated_folder.glob("*txt"):
    if f.is_file():
        print(f"Processing file: {f.name}")
        df = pd.read_csv(f, sep="\t", dtype=str)
        match = re.match(r"(\d+)_", f.name)
        file_id = match.group(1) if match else f.stem.split("_")[0]
        df.insert(0, "ID", file_id)
        txt_dfs.append(df)

if txt_dfs:
    combined_txt = pd.concat(txt_dfs, ignore_index=True)
    combined_txt.to_csv("combined.csv", index=False)
    print(f"✅ Annotated TXT combined → combined.csv | Shape: {combined_txt.shape}")
else:
    print("⚠️ No annotated .txt files found.")

### === STEP 2: COMBINE NORMALIZED VCF FILES === ###
print("\n🔹 Step 2: Combining gzipped normalized VCF files...")

vcf_folder = Path("output_03")  # Adjust as needed
vcf_dfs = []

for f in vcf_folder.glob("*normalized.vcf.gz"):
    print(f"Processing zipped VCF: {f.name}")
    
    with gzip.open(f, "rt") as fh:
        lines = [line for line in fh if not line.startswith("##")]

    if not lines:
        print(f"⚠️ Skipping empty VCF: {f.name}")
        continue

    header_line = next((line for line in lines if line.startswith("#CHROM")), None)
    data_lines = [line for line in lines if not line.startswith("#")]

    if header_line and data_lines:
        columns = header_line.strip().lstrip("#").split("\t")
        vcf_df = pd.read_csv(io.StringIO("".join(data_lines)), sep="\t", names=columns, dtype=str)
        match = re.match(r"(\d+)_", f.name)
        file_id = match.group(1) if match else f.stem.split("_")[0]
        vcf_df.insert(0, "Sample_ID", file_id)
        vcf_dfs.append(vcf_df)
    else:
        print(f"⚠️ No usable content in: {f.name}")

if vcf_dfs:
    combined_vcf = pd.concat(vcf_dfs, ignore_index=True)
    combined_vcf.to_csv("combined_vcf.csv", index=False)
    print(f"✅ Normalized VCFs combined → combined_vcf.csv | Shape: {combined_vcf.shape}")
else:
    print("⚠️ No valid gzipped VCF files found.")

### === STEP 3: RENAME SAMPLE IDS USING MAPPING FILE === ###
print("\n🔹 Step 3: Renaming sample IDs using mapping file...")

try:
    # Try renaming the annotated file first
    df_to_rename = pd.read_csv("combined.csv")
except FileNotFoundError:
    print("⚠️ combined.csv not found. Skipping rename.")
    df_to_rename = None

try:
    mapping_df = pd.read_csv("sample_name.csv")
    id_to_name = mapping_df.set_index("ID")["NAME"].to_dict()
    
    if df_to_rename is not None:
        df_to_rename["ID"] = df_to_rename["ID"].map(id_to_name).fillna(df_to_rename["ID"])
        df_to_rename.to_csv("vcf_with_named_ids.csv", index=False)
        print("✅ Renamed IDs saved → vcf_with_named_ids.csv")
except FileNotFoundError:
    print("⚠️ sample_name.csv not found. Cannot perform ID renaming.")
