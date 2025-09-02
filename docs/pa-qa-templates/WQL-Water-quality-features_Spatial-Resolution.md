# Spatial Resolution
The following instruction are applicable for the **Water Quality Features** products, i.e., chlorophyl-a and turbidity parameters.

| Module ID | Related Requirements | Expected Input | Automated test | Date | Tester |
|------|---|--------------------------------------| --- |----| ---|
| WS-WQ-IF-AD    |  GNEO-SOW-2-URS-003, GNEO-SOW-2-FRS-002 | Chl-a COG      | No | 19/02/2025 | \<Name> |

## Tools
- GDAL
- QGIS (for visual/manual verification)
- Internet Browser (Firefox, Google Chrome etc.)

## Instructions
### Step 1: Native Pixel Size from GeoTIFF Metadata
#### Objective: Confirm that the nominal raster pixel size is exactly 10m.
#### Instructions:
1. Run the following command in the command line:  
`gdalinfo <filename.tif>`  

2. Look for the following line:  
```bash
Pixel Size = (10.000000000000000,-10.000000000000000)
```  

3. Confirm that:
    - X and Y pixel sizes are both exactly 10.0 meters.
    - Negative Y value is expected (origin at top left).

#### Pass Criteria:
- Pixel size = (10.0, -10.0) → **PASS**  
- Any deviation > 0.01 meters → **FAIL**

### Step 2: Validate GeoTIFF CRS is Greek Grid
#### Objective: Confirm that the spatial resolution is measured in meters of the Greek Grid.
#### Instructions:
1. From `gdalinfo` output, check the Coordinate Reference System (CRS) section:
```bash
Coordinate System is:
PROJCRS["GGRS87 / Greek Grid", ...  
ID["EPSG",2100]]
```
#### Pass Criteria:
- CRS = EPSG:2100 → **PASS**  
- CRS = any other → **FAIL**

### Step 3: Cross-check with STAC Metadata
#### Objective: Confirm that the STAC metadata correctly declares the spatial resolution.
#### Instructions:
1. Open the corresponding `stac-item.json` or product metadata with your internet browser.
2. Look for the fields:
```json
"gsd": <number>
```
and
```json
"proj:epsg": <epsg:code>
```
or
```json
"proj:code": <epsg_code>
```

#### Pass Criteria:
- `"gsd": 10` AND  (`"proj:epsg": 2100` OR `"proj:code": "EPSG:2100`) → **PASS**
- Otherwise → **FAIL**

### Step 4: Visual Resolution Check in QGIS
#### Objective: Confirm that the spatial resolution and Greek Grid appear as they should in QGIS.
#### Instructions:
1. Open a new QGIS project and open GeoTIFF.
2. Go to the GeoTIFF layer *Properties*.
3. Go to the *Information* tab.
4. Check the *Pixel Size* under the *Information from Provider*.
5. Check the *Name* under the *Coordinate Reference System (CRS)*.

#### Pass Criteria:
- `Pixel Size 10,-10` AND `Name	EPSG:2100 - GGRS87 / Greek Grid` → **PASS**
- Otherwise → **FAIL**