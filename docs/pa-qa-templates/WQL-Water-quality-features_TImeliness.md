# Timeliness
The following instructions are applicable for the **Water Quality Features** products, i.e., chlorophyl-a and turbidity parameters, to verify that they are delivered within 3 hours of Sentinel-2 acquisition time or availability on G-Hub, ensuring Near Real-Time (NRT) compliance.

| Module ID | Related Requirements | Expected Input | Automated test | Date | Tester |
|------|---|--------------------------------------| --- |----| ---|
| WS-WQ-IF-AD    |  GNEO-SOW-2-URS-003, GNEO-SOW-2-FRS-002 | Chl-a COG      | No | 19/02/2025 | \<Name> |

## Tools
- Internet Browser (Firefox, Google Chrome etc.)

## Instructions
### Step 1: Extract Sentinel-2 Acquisition Time or Availability on G-Hub
#### Objective: Get the Sentinel-2 timestamp of when it became available on G-Hub.
#### Instructions:
1. Select a given product.
2. Open the `stac-item.json` of the product  
3. Find the Sentinel-2 availability datetime field:  
```json
"datetime": "<datetime>"
```  
4. Record this as the availability time.

#### Pass Criteria:
- Field must be present and ISO 8601 compliant → **PASS**  
- Otherwise → **FAIL**

### Step 2: Retrieve Delivery Time
#### Objective: Get the timestamp of the when the water quality product became available on G-Hub.
#### Instructions:
1. Open the `stac-item.json` of the product  
2. Find the water quality product delivery datetime field:  
```json
"published": "<datetime>"
```  
3. Record this as the availability time.

#### Pass Criteria:
- Field must be present and ISO 8601 compliant → **PASS**  
- Otherwise → **FAIL**

### Step 3: Calculate Timeliness (Latency)
#### Objective: Confirm that the calculated timeliness is aligned with the nominal timeliness.
#### Instructions:
1. Compute time delta (in minutes or hours) between availability datetime and delivery datetime
```Timeliness (Δt) = product_delivery_datetime – s2_available_datetime```

#### Pass Criteria:
- Δt ≤ 3 hours → **PASS**
- if Δt > 3 hours → **FAIL**

### Step 4: Generate an overall report about product timeliness. (Optional)
#### Objective: Generate a report with statistics about timeliness of the products of given days.
#### Instructions:
1. Repeat the above steps for all water quality products for a given day.
2. Record the outcomes on a table. Assign `1` for PASS and `0` for FAIL.

| Product ID               | Acquisition Time (UTC) | Delivery Time (UTC) | Δt (hrs) | Pass |
| ------------------------ | ---------------------- | ------------------- | -------- | ----- |
| ID_1                     | \<datetime>            | \<datetime>         | \<difference>     | 1     |
| ID_2                     | \<datetime>            | \<datetime>         | \<difference>     | 0     |
| ID_N                     | \<datetime>            | \<datetime>         | \<difference>     | 1     |

3. Calculate the percentage of products that PASSED, and the average timeliness and standard deviation for that given day.

| Date       | # Products | NRT Pass (%) | Avg Δt (hrs) | Std Δt (hrs) |
| ---------- | ---------- | ------------ | ------------ | ------------ |
| Day_1      | 14         | \<perc>      | \<number>    | \<number>    |
| Day_2      | 12         | \<perc>      | \<number>    | \<number>    |
| Day_N      | 12         | \<perc>      | \<number>    | \<number>    |