# Conversion Search by Manufacturer Number

This project analyzes item conversion opportunities by comparing pricing for cross-referenced medical supply items based on their manufacturer catalog numbers. It calculates per-unit cost differences and potential savings using BigQuery.

---

## 📁 Files

| File | Description |
|------|-------------|
| `sql/conversion_by_mfr_number.sql` | Main SQL script for estimating item conversion savings. |
| `example_inputs/manufacturer_catalog_numbers.csv` | Sample list of manufacturer catalog numbers. Replace with your own. |

---

## 📊 What It Does

- Joins item pricing and cross-reference data
- Normalizes unit prices to "each"
- Estimates cost savings if using alternate items
- Summarizes savings by contract

---

## 🧪 How to Use

1. Replace the placeholder table names in the SQL:
    ```sql
    FROM `project.dataset.item_cross_references`
    ```
    with your actual BigQuery project and dataset names.

2. Edit the manufacturer numbers in the `IN (...)` clause or use the list from `example_inputs/manufacturer_catalog_numbers.csv`.

3. Run the script in BigQuery Console or your preferred SQL editor.

---

## 📦 Example Output (columns)

| Cross Contract | Manufacturer Number | Primary Item | Cross Item | Est. Cross Spend | Est. Savings |
|----------------|----------------------|--------------|------------|------------------|--------------|

---

## 🛡️ Notes

- No PHI or PII is used.
- All internal table names are redacted.
- For healthcare-specific use cases, ensure compliance with HIPAA or internal data policies.

---

## 📬 Contact

For questions or suggestions, feel free to open an issue or fork this repo.
