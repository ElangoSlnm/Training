--DDL FOR SCHEMA
CREATE OR REPLACE FUNCTION ddl_for_schema(vschema character varying) 
RETURNS TABLE(result text) AS $$ 
DECLARE 
    t_row INFORMATION_SCHEMA.TABLES%ROWTYPE;
BEGIN    
    EXECUTE 'COPY (SELECT * FROM ddl_for_function('''||vschema||''')) TO ''C:\Users\Elango\Documents\pyhton\psql_backup\function.sql'';';
    FOR t_row IN
        SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = vschema
    LOOP
        EXECUTE 'COPY (SELECT ddl_for_table('''||t_row.table_name||''')) TO ''C:\Users\Elango\Documents\pyhton\psql_backup\'||t_row.table_name||'.sql'';';
    END LOOP;
    --SELECT ddl_for_table(table_name) FROM (SELECT table_name::text FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = vschema)t;
END;
$$ LANGUAGE plpgsql;


--DDL FOR FUNCTION
CREATE OR REPLACE FUNCTION ddl_for_function(vschema varchar)
RETURNS TABLE(result text) AS $$
BEGIN
RETURN query
    SELECT 
        REPLACE(('CREATE OR REPLACE FUNCTION '||f_name||'('||
        f_arg||') RETURNS '||f_result||' AS '||CHR(36)||CHR(36)||f_desc||CHR(36)||CHR(36)||' LANGUAGE plpgsql;'),E'\n',' ') 
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

--DDL FOR TRIGGERS
CREATE OR REPLACE FUNCTION generate_triggers(vtable varchar)
RETURNS table(trigger text) AS $$
BEGIN
    RETURN query
    SELECT 
        'CREATE trigger '||trigger_name||E'\n'||
        action_timing||' '||
        array_to_string(array_agg(event_manipulation),' OR ')||E'\n'||
        vtable||E'\n'||
        'FOR EACH '||action_orientation||E'\n'||
        action_statement||E';\n'
    FROM (
        SELECT
            trigger_name,
            event_manipulation,
            action_statement,
            action_timing,
            action_orientation
            FROM INFORMATION_SCHEMA.TRIGGERS WHERE event_object_table = vtable)t 
    GROUP BY trigger_name, action_statement, action_timing, action_orientation;
END;
$$ LANGUAGE plpgsql;

--DDL FOR TABLE
CREATE OR REPLACE FUNCTION ddl_for_table(vtable character varying)
RETURNS TABLE(t_row text) AS $$
BEGIN
RETURN query
    SELECT 'CREATE TABLE IF NOT EXISTS '||vtable||'('||array_to_string(array_agg(column_name||' '||datatype||' '||CASE WHEN pk_count = 1 OR contype != 'PRIMARY KEY '  THEN contype ELSE '' END||ref||nullable||defval),', ')||CASE WHEN AVG(pk_count) > 1 THEN ', PRIMARY KEY('||array_to_string(array_agg(CASE WHEN contype IS NOT NULL THEN column_name END),', ')||')' ELSE '' END||');' FROM
    (SELECT
        pat.attname AS column_name,
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
RETURN query
    SELECT 
        'CREATE trigger '||trigger_name||' '||
         action_timing||' '||array_to_string(array_agg(event_manipulation),' OR ')||' ON '||
        vtable||' '||'FOR EACH '||action_orientation||' '||action_statement||';' 
    FROM (
        SELECT trigger_name, event_manipulation, action_statement, action_timing, action_orientation
        FROM INFORMATION_SCHEMA.TRIGGERS 
        WHERE event_object_table = vtable)t 
        GROUP BY trigger_name, action_statement, action_timing, action_orientation;
END;
$$ LANGUAGE plpgsql;
