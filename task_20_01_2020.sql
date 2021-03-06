CREATE OR REPLACE FUNCTION get_function_ddl(vschema varchar, vtime boolean default false)
RETURNS TABLE(func_name text, result text) AS $$
BEGIN
RETURN query
    SELECT 
        f_name::text, E'/*\n'||CASE WHEN vtime THEN NOW()::time::text||':' ELSE ' ' END||E' Auto generated by get_function_ddl API v1\n*/\nCREATE OR REPLACE FUNCTION '||f_name||'('||
        f_arg||E')\nRETURNS '||f_result||' AS '||CHR(36)||CHR(36)||f_desc||CHR(36)||CHR(36)||' LANGUAGE plpgsql;'
    FROM
        (SELECT 
            pp.proname AS f_name, 
            pg_get_function_arguments(pp.oid) AS f_arg, 
            pg_get_function_result(pp.oid) AS f_result, 
            pp.prosrc AS f_desc 
        FROM pg_catalog.pg_proc pp
        LEFT JOIN pg_catalog.pg_namespace pn ON pn.oid = pp.pronamespace     
        WHERE pg_catalog.pg_function_is_visible(pp.oid) AND pn.nspname  = vschema)
    t;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_table_ddl(vtable text, vtime boolean default false)
RETURNS TABLE(t_row text) AS $$
BEGIN
RETURN query
    SELECT E'/*\n'||CASE WHEN vtime THEN NOW()::TIME::text||':' ELSE '' END||E' Auto generated by get_table_ddl API v1\n*/\n'||'CREATE TABLE IF NOT EXISTS '||vtable||'('||array_to_string(array_agg(column_name||' '||datatype||' '||CASE WHEN pk_count = 1 OR contype != 'PRIMARY KEY '  THEN contype ELSE '' END||ref||nullable||defval),', ')||CASE WHEN AVG(pk_count) > 1 THEN ', PRIMARY KEY('||array_to_string(array_agg(CASE WHEN contype IS NOT NULL THEN column_name END),', ')||')' ELSE '' END||');' FROM
    (SELECT
        DISTINCT pat.attname AS column_name,
        COUNT(CASE WHEN inf.constraint_type = 'PRIMARY KEY' THEN inf.constraint_type END) OVER(PARTITION BY inf.constraint_type) AS pk_count,
        CASE
            WHEN (SELECT * FROM pg_get_serial_sequence(pcl.relname, pat.attname)) IS NOT NULL THEN 'SERIAL'  
            ELSE pg_catalog.format_type(pat.atttypid, pat.atttypmod)
        END AS datatype,
        CASE 
            WHEN inf.constraint_type IS NULL THEN NULL
            ELSE CONCAT(inf.constraint_type,' ')
        END AS contype,
        CASE 
            WHEN tc.constraint_type = 'FOREIGN KEY' THEN 'REFERENCES '||ccu.table_name||'('||ccu.column_name||') '
            ELSE ''
        END AS ref,
        CASE
            WHEN pat.attnotnull THEN 'NOT NULL'
            ELSE 'NULL'
        END AS nullable,
        CASE
            WHEN isc.column_default IS NULL THEN ''
            WHEN (SELECT * FROM pg_get_serial_sequence(isc.table_name, isc.column_name)) IS NOT NULL THEN '' 
            ELSE ' DEFAULT '||isc.column_default||' '
        END AS defval,
        pat.attnum AS columns_number
    FROM pg_class pcl INNER JOIN pg_attribute pat ON pcl.oid = pat.attrelid
    INNER JOIN INFORMATION_SCHEMA.COLUMNS isc ON isc.column_name = pat.attname
    LEFT JOIN pg_constraint pct ON pat.attrelid = pct.conrelid AND pat.attnum = ANY(pct.conkey) AND pct.contype != 'f'
    LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS inf ON pct.conname = inf.constraint_name 
    LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ck ON isc.column_name = ck.column_name AND isc.table_name = ck.table_name AND ck.position_in_unique_constraint = 1
    LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON ck.table_name = tc.table_name AND ck.constraint_name = tc.constraint_name
    LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.constraint_name = ccu.constraint_name
    WHERE pcl.relname = vtable AND isc.table_name = vtable AND pat.attnum > 0 AND pat.attisdropped = 'f'
    ORDER BY pat.attnum)t;
RETURN query
    SELECT REPLACE(indexdef, 'INDEX', 'INDEX IF NOT EXISTS')||';' FROM pg_indexes WHERE tablename = vtable;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_tables_ddl(vschema character varying, vtime boolean default false) 
RETURNS TABLE(tname text, result text) AS $$ 
BEGIN  
   RETURN query     
        SELECT table_name, get_table_ddl(table_name, vtime) FROM (SELECT table_name::text FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = vschema)t;  
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_trigger_ddl(vtable varchar, vtime boolean default false)
RETURNS TEXT AS $$
DECLARE
    vresult text;
BEGIN
    EXECUTE 'SELECT E''/*\n''||CASE WHEN '||vtime||' THEN NOW()::TIME::TEXT||'':'' ELSE '''' END||E'' Auto generated by get_trigger_ddl API v1\n*/\n''||array_to_string(array_agg(_row),E''\n'') FROM ( 
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

CREATE OR REPLACE FUNCTION get_triggers_ddl(vschema character varying, vtime boolean default false) 
RETURNS TABLE(tname text, result text) AS $$ 
BEGIN  
   RETURN query     
        SELECT table_name, get_trigger_ddl(table_name, vtime) FROM (SELECT table_name::text FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = vschema)t;  
END;
$$ LANGUAGE plpgsql;
