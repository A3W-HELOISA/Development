CREATE TABLE floats (id serial4 NOT NULL, CONSTRAINT pk_floats PRIMARY KEY (id)); -- Updated to one line
-- Permissions
ALTER TABLE floats OWNER TO postgres;
GRANT ALL ON TABLE floats TO postgres;

ALTER TABLE floats ADD COLUMN wmo_id varchar(10) NULL;
ALTER TABLE floats ADD COLUMN deployment_date date NULL;
ALTER TABLE floats ADD COLUMN float_type varchar(50) NULL;
ALTER TABLE floats ADD COLUMN status varchar(20) NULL;
ALTER TABLE floats ADD CONSTRAINT uq_floats_wmo_id UNIQUE (wmo_id); -- Updated constraint name

CREATE TABLE float_positions (id serial4 NOT NULL, CONSTRAINT pk_float_positions PRIMARY KEY (id)); -- Updated to one line
-- Permissions
ALTER TABLE float_positions OWNER TO postgres;
GRANT ALL ON TABLE float_positions TO postgres;

ALTER TABLE float_positions ADD COLUMN float_id int4 NULL;
ALTER TABLE float_positions ADD COLUMN position_date date NULL;
ALTER TABLE float_positions ADD COLUMN geom public.geometry(point, 2100) NULL; -- Updated column name and projection
ALTER TABLE float_positions ADD CONSTRAINT fk_float_positions_float_id FOREIGN KEY (float_id) REFERENCES floats(id); -- Updated constraint name
CREATE INDEX idx_float_positions_geom ON float_positions USING GIST(geom); -- Added spatial index

CREATE TABLE float_forecasts (id serial4 NOT NULL, CONSTRAINT pk_float_forecasts PRIMARY KEY (id)); -- Updated to one line
-- Permissions
ALTER TABLE float_forecasts OWNER TO postgres;
GRANT ALL ON TABLE float_forecasts TO postgres;

ALTER TABLE float_forecasts ADD COLUMN float_id int4 NULL;
ALTER TABLE float_forecasts ADD COLUMN forecast_date date NULL;
ALTER TABLE float_forecasts ADD COLUMN forecast_time time NULL;
ALTER TABLE float_forecasts ADD COLUMN geom public.geometry(point, 2100) NULL; -- Updated column name and projection
ALTER TABLE float_forecasts ADD CONSTRAINT fk_float_forecasts_float_id FOREIGN KEY (float_id) REFERENCES floats(id); -- Updated constraint name
CREATE INDEX idx_float_forecasts_geom ON float_forecasts USING GIST(geom); -- Added spatial index