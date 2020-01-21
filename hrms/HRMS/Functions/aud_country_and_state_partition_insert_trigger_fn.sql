/*
05:58:47.532029: Auto generated by get_function_ddl API v1
*/
CREATE OR REPLACE FUNCTION aud_country_and_state_partition_insert_trigger_fn()
RETURNS trigger AS $$
DECLARE
v_current_date timestamp without time zone:=now()::timestamp without time zone;

v_first_date date:=date_trunc('month', v_current_date)::date;
v_p_key text:=to_char(v_first_date,'YYYYMM');
v_last_date date:=(date_trunc('month', v_current_date) + interval '1 month - 1 day')::date;
v_sql text;

BEGIN 
/*
2020-01-14 09:39:35.736957+00: Auto generated by enable_audit API
*/

PERFORM create_partition_table_if_not_exists('audit','hrms','country_and_state',v_current_date,'hrms');

IF TG_OP='INSERT' THEN 
    v_sql:='INSERT INTO audit.aud_hrms_country_and_state_'||v_p_key||' SELECT $1.*';
    execute v_sql using NEW;
    RETURN NULL;
END IF;
END;
$$ LANGUAGE plpgsql;