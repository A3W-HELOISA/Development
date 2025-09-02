# Area of Interest
The following instructions are applicable for the **Water Quality Features** products, i.e., chlorophyl-a and turbidity parameters. Ensure that each Chl-a product:
1. Covers the intended geographic AOI (named lakes or lagoons).
2. Applies lake-specific masking or processing rules.
3. Is labeled consistently in the metadata by name and water body type (if relevant).
4. Avoids spurious generation for non-targeted or invalid regions.

| Module ID | Related Requirements | Expected Input | Automated test | Date | Tester |
|------|---|--------------------------------------| --- |----| ---|
| WS-WQ-IF-AD    |  GNEO-SOW-2-URS-003, GNEO-SOW-2-FRS-002 | Chl-a COG      | No | 19/02/2025 | \<Name> |

## Tools
- QGIS (for visual/manual verification)
- Internet Browser (Firefox, Google Chrome etc.)
- Spreadsheet or Vector or GeoJSON file with the list of the reference water bodies

### Step 1: Load Reference AOIs and extract desired AOI geometry.
#### Objective: Browse the list of the reference Areas of Interest (AOI).
#### Instructions:
1. Go to the [official webpage](https://www.heloisa.gr) or the product documents webpage, and download the official water body reference file (Spreadsheet, Vector or GeoJSON). The reference file (if a Vector) must contain an attribute table with the following fields: `aoi_id`, `aoi_name`, `aoi_type`, `aoi_bbox`, `aoi_geometry_wgs`, `aoi_geometry`.
2. Load the file in a GIS software.
3. Identify the geometry of the desired AOI.

#### Pass Criteria:
- `aoi_id` has a unique ID specific for each AOI as defined in reference document → **PASS**
- `aoi_name` has a unique name of the AOI → **PASS**
- `aoi_type` can contain two possible values (i.e., `lake`, `lagoon`) → **PASS**
- `aoi_bbox` is the bounding box of the AOI and is in WKT format in `EPSG:4326` → **PASS**
- `aoi_geometry_wgs` is the shape of the water body boundaries and is in WKT format in `EPSG:4326` → **PASS**
- `aoi_geometry` is the shape of the water body boundaries and is in WKT format in `EPSG:2100` → **PASS**
- Any deviation → **FAIL**

### Step 2: Verify the AOI semantic fields match.
#### Objective: Confirm that the product's fields coincide with reference AOI file fields.
#### Instructions:
1. Load the `stac-item.json` of the generate chl-a product of interest for the desired AOI.
2. Identify the fields referring to the `aoi_id`, `aoi_name` and `aoi_type`.

#### Pass Criteria:
- `aoi_id`, `aoi_name` and `aoi_type` exactly coincide with the respective ones in the reference file → **PASS**  
- Otherwise → **FAIL**

### Step 3: Extract geometry of chl-a product and verify spatial match.
#### Objective: Extract the geometry of the generate chl-a product and verify match with reference file.
#### Instructions:
1. Load the `stac-item.json` of the generate chl-a product of interest for the desired AOI.
2. Identify the field referring to the respective geometry bounding box, i.e.
```json
{
  "type": "Feature",
  "properties": {
    "name": "<aoi-name>",
    "type": "<aoi_type>"
  },
  "geometry": {
    "type": "Polygon",
    "coordinates": [...]
  }
}
```
3. Load it on top of the reference file in the GIS software.
4. Load the GeoTIFF of the chl-a product in the GIS software.

#### Pass Criteria:
- AOI geometry of the reference file, and GeoTIFF bounding box and the product geometry exactly coincide → **PASS**  
- Otherwise → **FAIL**