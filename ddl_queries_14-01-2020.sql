CREATE OR REPLACE FUNCTION create_table(vtable VARCHAR)
    RETURNS text AS $result$
DECLARE
    _query text;
    _indexes text;
    result text;
BEGIN
    SELECT 'CREATE TABLE '||vtable||' ('||
    array_to_string(
        array_agg(column_name||' '||datatype||' '||contype||nullable||defval)
    ,', ')
    ||');' 
    INTO _query FROM(SELECT 
        pat.attname AS column_name, 
        CASE
            WHEN (SELECT * FROM pg_get_serial_sequence(pcl.relname, pat.attname)) IS NOT NULL THEN 'SERIAL'
            ELSE pg_catalog.format_type(pat.atttypid, pat.atttypmod)
        END AS datatype,
        CASE 
            WHEN pct.conname IS NULL OR inf.constraint_type = 'FOREIGN KEY' THEN ''
            ELSE CONCAT(inf.constraint_type,' ')
        END AS contype,
        CASE 
            WHEN pat.attnotnull THEN 'NOT NULL' 
            ELSE 'NULL' 
        END AS nullable,
        CASE 
            WHEN isc.column_default IS NULL THEN ''
            WHEN (SELECT * FROM pg_get_serial_sequence(isc.table_name, isc.column_name)) IS NOT NULL THEN ''
            ELSE ' DEFAULT '||isc.column_default||' '
        END AS defval
    FROM 
        pg_class pcl INNER JOIN pg_attribute pat ON pcl.oid = pat.attrelid 
        INNER JOIN information_schema.columns isc ON isc.column_name = pat.attname
        LEFT JOIN pg_constraint pct ON pat.attrelid = pct.conrelid AND pat.attnum = ANY(pct.conkey)
        LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS inf ON pct.conname = inf.constraint_name
        WHERE pcl.relname = vtable AND isc.table_name = vtable AND pat.attnum > 0 AND pat.attisdropped = 'f' ORDER BY pat.attnum)t;
    SELECT array_to_string(array_agg(CONCAT(indexdef,';')), E'\n') INTO _indexes FROM (SELECT indexdef FROM pg_indexes WHERE tablename = vtable)t;
    result:=_query||E'\n'||_indexes;
    RETURN result;
END;
$result$ LANGUAGE plpgsql


SELECT * FROM create_table('sample');
                                                                                            create_table

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 CREATE TABLE sample (id SERIAL PRIMARY KEY NOT NULL, name character varying(10) UNIQUE NOT NULL, age integer NOT NULL, city character varying(10) NOT NULL DEFAULT 'chennai'::character varying );+
 CREATE UNIQUE INDEX sample_pkey ON public.sample USING btree (id);
                                                   +
 CREATE UNIQUE INDEX sample_name_key ON public.sample USING btree (name);
(1 row)                                     
                                    

CREATE OR REPLACE FUNCTION updateLog()
RETURNS trigger AS $BODY$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        UPDATE changes_logs SET action = TG_OP, updated_on = NOW(), query = current_query() WHERE id = NEW.id;
    ELSEIF (TG_OP = 'INSERT') THEN
        INSERT INTO changes_logs(id, table_name, action, updated_on, query) VALUES (NEW.id, TG_TABLE_NAME, TG_OP, NOW(), current_query());
    END IF;
    RETURN NEW;
END;
$BODY$ LANGUAGE PLPGSQL;


CREATE TRIGGER sample_changes_trigger
  AFTER INSERT OR UPDATE
  ON sample
  FOR EACH ROW
  EXECUTE PROCEDURE updateLog();
                                                                                    
                                                                                    
SELECT * FROM changes_logs;
 id | table_name | action |         updated_on         |                                  query
----+------------+--------+----------------------------+--------------------------------------------------------------------------
  3 | sample     | INSERT | 2020-01-14 11:52:43.435045 | INSERT INTO sample (name, age, city) VALUES('sakthi', 24, 'coimbatore'); 
  2 | sample     | UPDATE | 2020-01-14 13:55:29.372623 | UPDATE sample SET name='s.elango' WHERE name = 'elango';
(2 rows)
                                                                                    
                                                                                    
CREATE OR REPLACE FUNCTION show_trigger(vtable varchar)
RETURNS text AS $result$
DECLARE
    result text;
BEGIN
    SELECT 'CREATE TRIGGER '||trigger_name||E'\n '||action_timing||' '||event_manipulation||E'\nON '||event_object_table||E'\n'||action_statement 
    INTO result FROM (SELECT 
        event_object_table,
        trigger_name,
        event_manipulation,
        action_statement,
        action_timing 
    FROM 
        information_schema.triggers 
    WHERE event_object_table = vtable ORDER BY event_object_table,event_manipulation)t;
    RETURN result;
END;
$result$ LANGUAGE plpgsql;

SELECT * FROM show_trigger('sample');
             show_trigger
---------------------------------------
 CREATE TRIGGER sample_changes_trigger+
  AFTER INSERT                        +
 ON sample                            +
 EXECUTE FUNCTION updatelog()
(1 row)
                                                                                    
