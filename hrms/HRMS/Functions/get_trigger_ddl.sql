/*
2020-01-21 15:06:16.122965: Auto generated by get_function_ddl API v1
*/
CREATE OR REPLACE FUNCTION get_trigger_ddl(vtable character varying, vtime boolean DEFAULT false)
RETURNS text AS $$
DECLARE
    vresult text;
BEGIN
    EXECUTE 'SELECT E''/*\n''||CASE WHEN '||vtime||' THEN NOW() AT TIME ZONE ''Asia/Kolkata''::text||'':'' ELSE '''' END||E'' Auto generated by get_trigger_ddl API v1\n*/\n''||array_to_string(array_agg(_row),E''\n'') FROM ( 
        SELECT
            ''CREATE trigger ''||trigger_name||E''\n''||
            action_timing||'' ''||
            array_to_string(array_agg(event_manipulation::text),'' OR '')||E''\nON '||
            vtable||E'\n FOR EACH ''||action_orientation||E''\n''||
            action_statement||E'';\n'' AS _row
        FROM (
            SELECT
                trigger_name,
                event_manipulation,
                action_statement,
                action_timing,
                action_orientation
                FROM INFORMATION_SCHEMA.TRIGGERS WHERE event_object_table = '''||vtable||''')t 
        GROUP BY trigger_name, action_statement, action_timing, action_orientation)t_tow;' INTO vresult;
    RETURN vresult;
END;
$$ LANGUAGE plpgsql;