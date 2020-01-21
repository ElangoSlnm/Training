/*
05:58:47.532029: Auto generated by get_function_ddl API v1
*/
CREATE OR REPLACE FUNCTION create_partition_table_if_not_exists(p_aud_schema text, p_schema_name text, p_table_name text, v_current_date timestamp without time zone DEFAULT now(), p_owner text DEFAULT CURRENT_USER)
RETURNS integer AS $$
DECLARE

v_first_date date:=date_trunc('month', v_current_date)::date;
v_last_date date:=(date_trunc('month', v_current_date) + interval '1 month - 1 day')::date;
v_p_key text:=to_char(v_current_date::date,'YYYYMM');
p_aud_tab_name_with_schema text:=p_aud_schema||'.aud_'||p_schema_name||'_'||p_table_name;
t_table_name text:=p_aud_tab_name_with_schema||'_'||v_p_key;

v_sql text;
BEGIN 
/*
1. aneesh.balakrishnan@imaginea.com 14-Jan-2020: First version for creating partion table
*/

IF (SELECT to_regclass(t_table_name) IS NULL)
THEN

v_sql:='
CREATE TABLE IF NOT EXISTS '||p_aud_tab_name_with_schema||'_'||v_p_key||' (like '||p_aud_tab_name_with_schema||' including all) INHERITS ('||p_aud_tab_name_with_schema||');
ALTER TABLE '||p_aud_tab_name_with_schema||'_'||v_p_key||' ADD CONSTRAINT p_key_check_constraint CHECK (p_key >= '' '||v_first_date||' '' and p_key <= '' '||v_last_date||' ''); ;
CREATE INDEX ON '||p_aud_tab_name_with_schema||'_'||v_p_key||' (p_key);
ALTER TABLE '||p_aud_tab_name_with_schema||'_'||v_p_key||' OWNER TO '||p_owner||';';
EXECUTE v_sql USING v_first_date,v_last_date;
END IF;
RETURN 1;
END;
$$ LANGUAGE plpgsql;