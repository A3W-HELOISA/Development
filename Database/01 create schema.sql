-- module
CREATE TABLE module (id SERIAL, CONSTRAINT pk_module PRIMARY KEY (id));
ALTER TABLE module ADD COLUMN name VARCHAR(255) UNIQUE NOT NULL;
ALTER TABLE module ADD COLUMN description TEXT;

-- process
CREATE TABLE process (id SERIAL, CONSTRAINT pk_process PRIMARY KEY (id));
ALTER TABLE process ADD COLUMN module INTEGER REFERENCES module(id);
ALTER TABLE process ADD COLUMN description TEXT;
ALTER TABLE process ADD COLUMN description TEXT;
ALTER TABLE process ADD use_sentinel BOOL DEFAULT false not null;
ALTER TABLE process ADD use_axis11 BOOL DEFAULT false not null;
ALTER TABLE process ADD use_axis12 BOOL DEFAULT false not null;
ALTER TABLE process ADD use_axis2 BOOL DEFAULT false not null;
ALTER TABLE process ADD COLUMN sentinel_product_required_specs TEXT;
ALTER TABLE process ADD COLUMN axis11_product_required_specs TEXT;
ALTER TABLE process ADD COLUMN axis12_product_required_specs TEXT;
ALTER TABLE process ADD COLUMN axis2_product_required_specs TEXT;
ALTER TABLE process ADD COLUMN geom GEOMETRY(Polygon, 2100) NOT NULL;--geofence

-- area
CREATE TABLE area (id SERIAL, CONSTRAINT pk_area PRIMARY KEY (id));
ALTER TABLE area ADD COLUMN name VARCHAR(255) UNIQUE NOT NULL;
ALTER TABLE area ADD COLUMN geom GEOMETRY(Polygon, 2100) NOT NULL;
ALTER TABLE area ADD COLUMN description TEXT;
CREATE INDEX idx_area_geom ON area USING GIST(geom);

-- process_area
CREATE TABLE process_area (id SERIAL, CONSTRAINT pk_area PRIMARY KEY (id));
ALTER TABLE process_area ADD COLUMN process_id INTEGER REFERENCES process(id);
ALTER TABLE process_area ADD COLUMN area_id INTEGER REFERENCES area(id);
CREATE UNIQUE INDEX uq_process_area_idx ON process_area(process_id, area_id);

-- vessel_type
CREATE TABLE vessel_type (id SERIAL, CONSTRAINT pk_vessel_type PRIMARY KEY (id));
ALTER TABLE vessel_type ADD COLUMN description TEXT;
CREATE UNIQUE INDEX uq_vessel_type_idx ON vessel_type(description);





