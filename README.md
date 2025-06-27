📘 README: Preparing CSV from VCF and Annotated Text Files
This document describes how to process variant call format (VCF) and annotated text files into a single merged CSV, with support for compressed VCFs and sample ID mapping for clarity.

🧩 Step 1: Combine Annotated TXT Files into a Single CSV
This script reads all .txt files in a specified folder (e.g., output/ or output_03/), extracts the sample ID from the filename, and concatenates the data into a single CSV file.

🧬 Step 2: Combine Normalized .vcf.gz Files into a Single CSV
This script reads all gzipped normalized VCF files, extracts relevant data (excluding metadata lines), and merges them into one CSV with the sample ID attached.

🧾 Step 3: Rename Sample IDs Using Mapping File
If your combined file uses numerical IDs, you can replace them with actual sample names using a mapping file (sample_name.csv) with two columns: ID and NAME.

Ensure all VCF and TXT files follow the naming convention: ID_filename.* (e.g., 123_normalized.vcf.gz, 123_ann.txt)

The scripts assume that IDs are numeric and come first in the filename.

You may adjust regex and column separators if your files are formatted differently.

📍 To Run
Open a terminal or Jupyter Notebook and execute each script block sequentially. Make sure all file paths and filenames are correctly specified.
