CREATE OR REPLACE FUNCTION create_table(vtable VARCHAR)
    RETURNS text AS $result$
DECLARE
    result text;
BEGIN
    SELECT 'CREATE TABLE '||vtable||' ('||
    array_to_string(
        array_agg(column_name||' '||data_type||' '||contypes||nullable)
    ,', ')
    ||');' 
    INTO result 
    FROM (SELECT 
        pc.relname AS table_name, 
        at.attname AS column_name, 
        CASE 
            WHEN pct.conname IS NULL THEN ''
            ELSE CONCAT(inf.constraint_type,' ')
        END AS contypes, 
        CASE
            WHEN (SELECT * FROM pg_get_serial_sequence(pc.relname, at.attname)) IS NOT NULL THEN 'SERIAL'
            ELSE pg_catalog.format_type(at.atttypid, at.atttypmod) 
        END AS data_type, 
        CASE 
            WHEN at.attnotnull THEN 'NOT NULL' 
            ELSE 'NULL' 
        END AS nullable
        FROM pg_class pc JOIN pg_attribute at ON pc.oid = at.attrelid 
        LEFT JOIN pg_index pi ON at.attrelid = pi.indrelid AND at.attnum = ANY(pi.indkey)
        LEFT JOIN pg_constraint pct ON pi.indexrelid = pct.conindid AND pct.contype != 'f'
        LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS inf ON pct.conname = inf.constraint_name
        WHERE pc.relname = vtable AND at.attnum > 0 AND NOT at.attisdropped
    )t;
    RETURN result;
END;
$result$ LANGUAGE plpgsql;
college=# SELECT * FROM create_table('sample');
                                                                                             create_table

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 CREATE TABLE sample (email character varying(20) UNIQUE NOT NULL, id SERIAL PRIMARY KEY NOT NULL, query text NULL, update_on timestamp without 
time zone NULL, name character varying(10) NOT NULL);
(1 row)

CREATE OR REPLACE FUNCTION create_indexes(vtable varchar)
RETURNS TEXT AS $t_row$
DECLARE
    t_row TEXT;
BEGIN
    SELECT array_to_string(array_agg(CONCAT(indexdef,';')), E'\n') INTO t_row FROM (SELECT indexdef FROM pg_indexes WHERE tablename = vtable)T;
    RETURN t_row;
END;
$t_row$ LANGUAGE plpgsql;
CREATE FUNCTION

college=# SELECT * FROM create_indexes('sample');
                               create_indexes
----------------------------------------------------------------------------
 CREATE UNIQUE INDEX sample_pkey ON public.sample USING btree (id);        +
 CREATE UNIQUE INDEX sample_email_key ON public.sample USING btree (email); 
(1 row)

CREATE OR REPLACE FUNCTION updateInsertion()
  RETURNS trigger AS
$BODY$
BEGIN
    UPDATE sample SET 
    update_on = NOW(), 
    query = 'INSERT INTO sample(id, name, email) VALUES('||NEW.id||' ,'''||NEW.name||''' ,'''||NEW.email||''');'
    WHERE id = NEW.id;
    RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER updateSample
  AFTER INSERT
  ON sample
  FOR EACH ROW
  EXECUTE PROCEDURE updateInsertion();
  
 SELECT * FROM sample;
 id |   name   |       email        |         update_on          |                                      query

----+----------+--------------------+----------------------------+---------------------------------------------------------------------------------
 16 | manoj    | manoj@gmail.com    | 2020-01-13 15:00:12.905334 | INSERT INTO sample(id, name, email) VALUES(16,'manoj','manoj@gmail.com');    
 17 | santhosh | santhosh@gmail.com | 2020-01-13 15:01:10.323589 | INSERT INTO sample(id, name, email) VALUES(17,'santhosh','santhosh@gmail.com');
 18 | elango   | elango@gmail.com   | 2020-01-13 15:01:25.725237 | INSERT INTO sample(id, name, email) VALUES(18,'elango','elango@gmail.com');  
 20 | kumar    | kumar@gmail.com    | 2020-01-13 15:06:19.963051 | INSERT INTO sample(id, name, email) VALUES(20,'kumar','kumar@gmail.com');    
 21 | meg      | meg@gmail.com      | 2020-01-13 15:07:28.593198 | INSERT INTO sample(id, name, email) VALUES(21 ,'meg' ,'meg@gmail.com');      
(5 rows)


