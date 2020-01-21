CREATE OR REPLACE FUNCTION ddl_for_table(vtable character varying)
RETURNS TABLE(t_row text) AS $$
BEGIN
-- CREATE TABLE
RETURN query
    SELECT 
        'CREATE TABLE '||vtable||' ('||array_to_string(array_agg(column_name||' '||
        datatype||' '||contype||nullable||defval),', ')||E');'
    FROM
        (SELECT 
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
            FROM pg_class pcl INNER JOIN pg_attribute pat ON pcl.oid = pat.attrelid 
            INNER JOIN information_schema.columns isc ON isc.column_name = pat.attname
            LEFT JOIN pg_constraint pct ON pat.attrelid = pct.conrelid AND pat.attnum = ANY(pct.conkey)
            LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS inf ON pct.conname = inf.constraint_name
            WHERE pcl.relname = vtable AND isc.table_name = vtable AND pat.attnum > 0 AND pat.attisdropped = 'f' 
            ORDER BY pat.attnum
        )t;
-- CREATE INDEXES
RETURN query
    SELECT indexdef||';' FROM pg_indexes WHERE tablename = vtable;
-- CREATE TRIGGER
RETURN query
    SELECT 
        'CREATE trigger '||trigger_name||' '||
        action_timing||' '||array_to_string(array_agg(event_manipulation),' OR ')||' '||
        vtable||' '||'FOR EACH '||action_orientation||' '||action_statement||';' 
    FROM (
        SELECT trigger_name, event_manipulation, action_statement, action_timing, action_orientation
        FROM INFORMATION_SCHEMA.TRIGGERS 
        WHERE event_object_table = vtable)t 
        GROUP BY trigger_name, action_statement, action_timing, action_orientation;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fun1('sample');
                                                                                               t_row

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 CREATE TABLE sample (id SERIAL PRIMARY KEY NOT NULL, name character varying(10) UNIQUE NOT NULL, 
 age integer NOT NULL, city character varying(10) NOT NULL DEFAULT 'chennai'::character varying );
 CREATE UNIQUE INDEX sample_pkey ON public.sample USING btree (id);
 CREATE UNIQUE INDEX sample_name_key ON public.sample USING btree (name);
 CREATE trigger sample_changes_trigger AFTER INSERT OR UPDATE sample FOR EACH ROW EXECUTE FUNCTION updatelog();
 CREATE trigger sample_changes_triggers AFTER UPDATE sample FOR EACH ROW EXECUTE FUNCTION updatelog();
(5 rows)

CREATE OR REPLACE FUNCTION ddl_for_function(vschema varchar)
RETURNS TABLE(result text) AS $$
BEGIN
RETURN query
    SELECT 
        'CREATE OR REPLACE FUNCTION '||f_name||'('||
        f_arg||') RETURNS '||f_result||' AS '||CHR(36)||CHR(36)||f_desc||CHR(36)||CHR(36)||' LANGUAGE plpgsql;' 
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

SELECT * FROM ddl_for_function('public');

                                                                                    result


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 CREATE OR REPLACE FUNCTION getpersons() 
 RETURNS SETOF person AS $$
 BEGIN
  RETURN query
    SELECT * FROM person LIMIT 20;
 END;
 $$ LANGUAGE plpgsql;
 
 CREATE OR REPLACE FUNCTION change_logs() RETURNS trigger AS $$
 BEGIN
  IF NEW.name <> OLD.name THEN
   INSERT INTO person_changes(person_id, name, changed_on) VALUES(OLD.id, OLD.name, NOW());
  END IF;
  RETURN NEW;
 END;
 $$ LANGUAGE plpgsql;
 
 CREATE OR REPLACE FUNCTION getinfo(vname character varying, vyear integer) RETURNS TABLE(student_name character varying, subject_name character varying, exam character varying, mark integer) AS $$
 BEGIN
  RETURN query
    SELECT p.name AS student_name, s.name AS subject_name, e.type AS exam, m.mark FROM person p JOIN marks m ON p.id = m.student_id JOIN subject s 
    ON m.sub_code = s.code JOIN exam e ON m.exam_type = e.id WHERE p.name = vname AND m.year = vyear LIMIT 10;
 END;
 $$ LANGUAGE plpgsql;
 
 CREATE OR REPLACE FUNCTION getperson_to_json() RETURNS json AS $$
 DECLARE
  t_row json;
 BEGIN
  SELECT array_to_json(array_agg(row_to_json(t))) INTO t_row FROM (SELECT * FROM person) t;
  RETURN t_row;
 END;
 $$ LANGUAGE plpgsql;

SELECT * FROM ddl_for_schema('public');

                                                                                    result


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 CREATE TABLE department (id SERIAL PRIMARY KEY NOT NULL, name character varying(25) UNIQUE NOT NULL);
 CREATE UNIQUE INDEX department_pkey ON public.department USING btree (id);
 CREATE UNIQUE INDEX department_name_key ON public.department USING btree (name);
 CREATE TABLE subject (code SERIAL PRIMARY KEY NOT NULL, name character varying(15) UNIQUE NOT NULL);
 CREATE UNIQUE INDEX subject_pkey ON public.subject USING btree (code);
 CREATE UNIQUE INDEX subject_name_key ON public.subject USING btree (name);
 CREATE TABLE person (id SERIAL PRIMARY KEY NOT NULL, name character varying(15) UNIQUE NOT NULL, email character varying(25) UNIQUE NOT NULL, dept_id integer NOT NULL, age integer NOT NULL, gender character(1) NULL, role integer NULL);
 CREATE UNIQUE INDEX pserson_pkey ON public.person USING btree (id);
 CREATE UNIQUE INDEX pserson_name_key ON public.person USING btree (name);
 CREATE UNIQUE INDEX pserson_email_key ON public.person USING btree (email);
 CREATE trigger name_changes BEFORE UPDATE person FOR EACH ROW EXECUTE FUNCTION change_logs();
 CREATE TABLE student_subject (id SERIAL PRIMARY KEY NOT NULL, dept_id integer NULL, sub_code integer NULL, year integer NULL, part integer NULL);
 CREATE UNIQUE INDEX student_subject_pkey ON public.student_subject USING btree (id);
 CREATE TABLE marks (sno SERIAL NOT NULL, student_id integer PRIMARY KEY NOT NULL, student_id integer NOT NULL, sub_code integer PRIMARY KEY NOT NULL, sub_code integer NOT NULL, mark integer NOT NULL, year integer PRIMARY KEY NOT NULL, exam_type integer NOT NULL, exam_type integer PRIMARY KEY NOT NULL, staff_id integer NULL);
 CREATE UNIQUE INDEX marks_pk ON public.marks USING btree (student_id, sub_code, year, exam_type);
 CREATE TABLE person_changes (id SERIAL PRIMARY KEY NOT NULL, person_id integer NULL, name character varying(15) NOT NULL, changed_on timestamp(6) without time zone NOT NULL);
 CREATE UNIQUE INDEX person_changes_pkey ON public.person_changes USING btree (id);
 CREATE TABLE sample11 (id integer NULL, id integer NULL);
 CREATE TABLE role (id SERIAL PRIMARY KEY NOT NULL, name character varying(20) UNIQUE NOT NULL);
 CREATE UNIQUE INDEX role_pkey ON public.role USING btree (id);
 CREATE UNIQUE INDEX role_role_name_key ON public.role USING btree (name);
 CREATE TABLE result (?column? text NULL);
 CREATE TABLE exam (id SERIAL PRIMARY KEY NOT NULL, type character varying(13) NOT NULL);
 CREATE UNIQUE INDEX exam_pkey ON public.exam USING btree (id);
 CREATE TABLE sample (id SERIAL PRIMARY KEY NOT NULL, name character varying(10) UNIQUE NOT NULL, age integer NOT NULL, city character varying(10) NOT NULL DEFAULT 'chennai'::character varying );
 CREATE UNIQUE INDEX sample_pkey ON public.sample USING btree (id);
 CREATE UNIQUE INDEX sample_name_key ON public.sample USING btree (name);
 CREATE trigger sample_changes_trigger AFTER INSERT OR UPDATE sample FOR EACH ROW EXECUTE FUNCTION updatelog();
 CREATE trigger sample_changes_triggers AFTER UPDATE sample FOR EACH ROW EXECUTE FUNCTION updatelog();
 CREATE TABLE changes_logs (id integer NULL, table_name text NOT NULL, action character varying(6) NOT NULL, updated_on timestamp without time zone NULL, query text NOT NULL);
 CREATE TABLE exam_log (id SERIAL NOT NULL, type character varying(13) PRIMARY KEY NOT NULL, year integer PRIMARY KEY NOT NULL);
 CREATE UNIQUE INDEX exam_ck ON public.exam_log USING btree (type, year);
 CREATE TABLE sample1 (name character varying NULL);
 CREATE TABLE staff_subject (id SERIAL PRIMARY KEY NOT NULL, staff_id integer NULL, sub_code integer NULL, year integer NULL, part integer NULL);
 CREATE UNIQUE INDEX staff_subject_pkey ON public.staff_subject USING btree (id);
 
 CREATE OR REPLACE FUNCTION getpersons() 
 RETURNS SETOF person AS $$
 BEGIN
  RETURN query
  SELECT * FROM person LIMIT 20;
 END;
 $$ LANGUAGE plpgsql;
                                             
 CREATE OR REPLACE FUNCTION change_logs() RETURNS trigger AS $$
 BEGIN
  IF NEW.name <> OLD.name THEN
   INSERT INTO person_changes(person_id, name, changed_on) VALUES(OLD.id, OLD.name, NOW());
  END IF;
  RETURN NEW;
 END;
 $$ LANGUAGE plpgsql;
 
 CREATE OR REPLACE FUNCTION getinfo(vname character varying, vyear integer) RETURNS TABLE(student_name character varying, subject_name character varying, exam character varying, mark integer) AS $$
 BEGIN
  RETURN query
    SELECT p.name AS student_name, s.name AS subject_name, e.type AS exam, m.mark FROM person p JOIN marks m ON p.id = m.student_id JOIN subject s 
    ON m.sub_code = s.code JOIN exam e ON m.exam_type = e.id WHERE p.name = vname AND m.year = vyear LIMIT 10;
 END;
 $$ LANGUAGE plpgsql;
 
 CREATE OR REPLACE FUNCTION getperson_to_json() RETURNS json AS $$
 DECLARE
  t_row json;
 BEGIN
  SELECT array_to_json(array_agg(row_to_json(t))) INTO t_row FROM (SELECT * FROM person) t;
  RETURN t_row;
 END;
 $$ LANGUAGE plpgsql;
