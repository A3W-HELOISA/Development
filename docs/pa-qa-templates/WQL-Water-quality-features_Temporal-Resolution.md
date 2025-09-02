# Temporal Resolution
The following instructions are applicable for the **Water Quality Features** products, i.e., chlorophyl-a and turbidity parameters.
This protocol ensures the acquisition date and the expected temporal resolution of Sentinel-2-based **Water Quality Features** chl-a GeoTIFF products is valid and consistent across the product and metadata.

| Module ID | Related Requirements | Expected Input | Automated test | Date | Tester |
|------|---|--------------------------------------| --- |----| ---|
| WS-WQ-IF-AD    |  GNEO-SOW-2-URS-004, GNEO-SOW-2-FRS-003 | Chl-a COG      | No | 19/02/2025 | \<Name> |

## Tools
- Spreadsheet editor
- Internet Browser (Firefox, Google Chrome etc.)

## Instructions
### Step 1: Confirm Product Contains Valid Acquisition Date
#### Objective: Ensure that each chl-a product is tied to a single valid Sentinel-2 acquisition date.
#### Instructions:
1. Open `stac-item.json` file with the internet browser. 

2. Locate:
```json
"processing:datetime": "<datetime>"
```
or
```json
"processing:start_datetime": "<datetime>",
"processing:end_datetime": "<datetime>"
```

#### Pass Criteria:
- A valid ISO 8601 `proccessing:datetime` exists → **PASS**
- The `processing:start_datetime` / `processing:end_datetime` exist and have the same value (optional) → **PASS**
- Missing or malformed datetimes → **FAIL**

### Step 2: Validate Consistency Across Metadata and Filename
#### Objective: Ensure the timestamp in the filename, directory, and metadata match.
#### Instructions:
1. Identify the datetime in the GeoTIFFs filename based on the defined file naming convention.
2. Compare it with the `proccessing:datetime` or `processing:start_datetime`/`processing:end_datetime` of the STAC metadata fields.

#### Pass Criteria:
- Filename and metadata date align → **PASS**  
- Inconsistent naming or misaligned timestamps → **FAIL**

### Step 3: Cross-check with respective Sentinel-2 acquisition datetimes
#### Objective: Confirm that the datetime of the product coincides with the respective Sentinel-2 sensing datetime.
#### Instructions:
1. Locate Sentinel-2 sensing datetime in STAC metadata:
```json
"datetime": "<datetime>"
```
2. Compare it with the `processing:datetime` or `processing:start_datetime` or `processing:end_datetime`.

#### Pass Criteria:
- Datetimes are the same → **PASS**
- Otherwise → **FAIL**

### Step 4: Calculate time deltas between products
#### Objective: Measure the time interval between successive observations for a given water body.
#### Instructions:
1. Select a water body and create a table for all respective available products over time.
2. Extract `processing:datetime` or `processing:start_datetime` or `processing:end_datetime` or date from filename
3. Populate the table with the products id, datetimes and calculate the time deltas between successive dates.

| Product ID | Date       | Difference (days) |
| ---------- | ---------- | ------     |
| ID_1       | 2025-04-10 | –          |
| ID_2       | 2025-04-15 | 5          |
| ID_3       | 2025-04-20 | 5          |
| ID_4       | 2025-04-23 | 3          |

#### Pass Criteria:
- Difference < 3 days → **FAIL** (potential duplicate)
- Difference = [3–5] days → **PASS**
- Difference > 5 days → **FAIL**