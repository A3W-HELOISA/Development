INSERT INTO module (id, name, description) VALUES (1, 'module1', 'description1');

INSERT INTO process (id, module, description, use_sentinel, use_axis11, use_axis12, use_axis2, sentinel_product_required_specs, axis11_product_required_specs, axis12_product_required_specs, axis2_product_required_specs, geom) VALUES (1, 1, 'description1', false, false, false, false, 'sentinel_product_required_specs1', 'axis11_product_required_specs1', 'axis12_product_required_specs1', 'axis2_product_required_specs1', ST_GeomFromText('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))', 2100));

INSERT INTO area (id, name, geom, description) VALUES (1, 'area1', ST_GeomFromText('POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))', 2100), 'description1');    

INSERT INTO process_area (id, process_id, area_id) VALUES (1, 1, 1);

INSERT INTO vessel_type (id, description) VALUES (1, 'description1');   

