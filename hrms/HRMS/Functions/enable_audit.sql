/*
05:58:47.532029: Auto generated by get_function_ddl API v1
*/
CREATE OR REPLACE FUNCTION enable_audit(p_schema_name text, p_table_name text, p_owner text DEFAULT CURRENT_USER)
RETURNS integer AS $$
DECLARE
v_sql text;
v_table_columns text;
v_p_key text:=to_char(now()::date,'YYYYMM');
p_aud_schema text:='audit';
p_aud_tab_name_with_schema text:=p_aud_schema||'.aud_'||p_schema_name||'_'||p_table_name;

BEGIN
/*
1. aneesh.balakrishnan@imaginea.com 14-Jan-2020: First version for enabling auditing table
select *from enable_audit(p_schema_name:='public',p_table_name:='traffic',p_owner:='aneeshk');
*/

--creating auditschema
v_sql:='CREATE SCHEMA IF NOT EXISTS '||p_aud_schema||' AUTHORIZATION '||p_owner;
raise notice 'creating auditschema : %',p_aud_schema;

execute v_sql;
--creating audit table
v_sql:='
    CREATE TABLE IF NOT EXISTS '||p_aud_tab_name_with_schema||'(
        id serial primary key,
        new_data json,
        old_data json,
        changed_columns character varying[],
        created_timestamp timestamp without time zone default now(),
        query text,
        username text,
        operation_mode text,
        p_key date
        );
    ALTER TABLE '||p_aud_tab_name_with_schema||' OWNER TO '||p_owner||';
        ';
raise notice 'creating audit table : %',p_aud_tab_name_with_schema;

--creating aud trigger function for main table
EXECUTE v_sql;
v_sql:='
CREATE OR REPLACE FUNCTION '||p_schema_name||'.aud_'||p_table_name||'_trigger_fn() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
AS $_$
DECLARE

v_p_key text:=to_char(now()::date,''YYYYMM'');

BEGIN 
/*
'||now()||': Auto generated by enable_audit API
*/
--create partition table if not exists


IF TG_OP=''INSERT'' THEN 
    INSERT INTO '||p_aud_tab_name_with_schema||' (
        new_data,
        old_data,
        changed_columns,
        created_timestamp,
        query,
        username,
        operation_mode,
        p_key) 
    SELECT 
        row_to_json(NEW.*),
        null::json,
        null::character varying[],
        now(),
        substring(current_query(),1,1000)::TEXT,
        session_user,TG_OP,now()::date;
    RETURN NEW;
ELSIF TG_OP=''UPDATE'' THEN 
    INSERT INTO '||p_aud_tab_name_with_schema||' (
        new_data,
        old_data,
        changed_columns,
        created_timestamp,
        query,username,
        operation_mode,
        p_key) 
    SELECT row_to_json(NEW.*),
        row_to_json(OLD.*),
        --(select array_agg(od.key) as changed_columns from jsonb_each(row_to_jsonb(NEW.*)) nd, jsonb_each(row_to_jsonb(OLD.*)) od where od.key=nd.key and nd.value != od.value),
        null::character varying[],
        now(),
        substring(current_query(),1,1000),
        session_user,TG_OP,now()::date;
    RETURN NEW;
ELSE 
    INSERT INTO '||p_aud_tab_name_with_schema||' (
        new_data,
        old_data,
        changed_columns,
        created_timestamp,
        query,
        username,
        operation_mode,
        p_key) 
    SELECT 
        null::json,
        row_to_json(OLD.*),
        null::character varying[],
        now(),
        substring(current_query(),1,1000),
        session_user,TG_OP,now()::date;
    RETURN OLD;
END IF;
END;
$_$;
ALTER FUNCTION '||p_schema_name||'.aud_'||p_table_name||'_trigger_fn() OWNER TO '||p_owner||';';

raise notice 'creating aud trigger function for main table : %',p_schema_name||'.aud_'||p_table_name||'_trigger_fn()';
execute v_sql;

--creating partition trigger for aud table 
v_sql:='

CREATE OR REPLACE FUNCTION '||p_schema_name||'.aud_'||p_table_name||'_partition_insert_trigger_fn() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
AS 
$_$
DECLARE
v_current_date timestamp without time zone:=now()::timestamp without time zone;

v_first_date date:=date_trunc(''month'', v_current_date)::date;
v_p_key text:=to_char(v_first_date,''YYYYMM'');
v_last_date date:=(date_trunc(''month'', v_current_date) + interval ''1 month - 1 day'')::date;
v_sql text;

BEGIN 
/*
'||now()||': Auto generated by enable_audit API
*/

PERFORM create_partition_table_if_not_exists('''||p_aud_schema||''','''||p_schema_name||''','''||p_table_name||''',v_current_date,'''||p_owner||''');

IF TG_OP=''INSERT'' THEN 
    v_sql:=''INSERT INTO '||p_aud_tab_name_with_schema||'_''||v_p_key||'' SELECT $1.*'';
    execute v_sql using NEW;
    RETURN NULL;
END IF;
END;
$_$;
ALTER FUNCTION '||p_schema_name||'.aud_'||p_table_name||'_partition_insert_trigger_fn() OWNER TO '||p_owner||'';

raise notice 'creating partition trigger for aud table  : %',p_schema_name||'.aud_'||p_table_name||'_partition_insert_trigger_fn()';
execute v_sql;


--creating triggers

v_sql:='
DROP TRIGGER IF EXISTS '||p_schema_name||'_'||p_table_name||'_aud_trig ON  '||p_schema_name||'.'||p_table_name||';
CREATE TRIGGER '||p_schema_name||'_'||p_table_name||'_aud_trig BEFORE INSERT OR UPDATE OR DELETE ON '||p_schema_name||'.'||p_table_name||' FOR EACH ROW  EXECUTE PROCEDURE '||p_schema_name||'.aud_'||p_table_name||'_trigger_fn()';

raise notice 'creating audit triggers : %',p_schema_name||'_'||p_table_name||'_aud_trig';
execute v_sql;

v_sql:='
DROP TRIGGER IF EXISTS '||p_schema_name||'_'||p_table_name||'_aud_insert_trig ON '||p_aud_tab_name_with_schema||';
CREATE TRIGGER '||p_schema_name||'_'||p_table_name||'_aud_insert_trig BEFORE INSERT OR UPDATE OR DELETE ON '||p_aud_tab_name_with_schema||' FOR EACH ROW  EXECUTE PROCEDURE '||p_schema_name||'.aud_'||p_table_name||'_partition_insert_trigger_fn()';

raise notice 'creating partition insert trigger %',p_schema_name||'_'||p_table_name||'_aud_insert_trig';
execute v_sql;

RETURN 1;
END;
$$ LANGUAGE plpgsql;