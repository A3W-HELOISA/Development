--DROP FUNCTION public.get_processing_validation(INTEGER, TEXT);
CREATE OR REPLACE FUNCTION get_processing_validation(
    parameter1 INTEGER
) RETURNS TABLE (
    xxx1 INTEGER,
    xxx2 TEXT
) AS $$
BEGIN
    RETURN QUERY
        SELECT xxx1, xxx2
        FROM yyy
        WHERE zzz=parameter1
END;
$$ LANGUAGE plpgsql;