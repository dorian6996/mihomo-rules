#!/usr/bin/env python3
import os
import json
import yaml

DAT_DIR = "dat"
OUTPUT_DIR = "lists"

os.makedirs(f"{OUTPUT_DIR}/geoip", exist_ok=True)
os.makedirs(f"{OUTPUT_DIR}/geosite", exist_ok=True)

def convert(dat_file, output_subdir):
    with open(dat_file, "r", encoding="utf-8", errors="ignore") as f:
        data = json.load(f)  # ZKEEN dat можно читать как JSON
    for category, payload in data.items():
        filename = os.path.join(OUTPUT_DIR, output_subdir, f"{category}.yaml")
        with open(filename, "w", encoding="utf-8") as out:
            yaml.dump({"payload": payload}, out, allow_unicode=True)
        print(f"Written {filename}")

convert(os.path.join(DAT_DIR, "geosite.dat"), "geosite")
convert(os.path.join(DAT_DIR, "geoip.dat"), "geoip")
