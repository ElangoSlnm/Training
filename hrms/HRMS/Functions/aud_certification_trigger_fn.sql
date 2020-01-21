/*
05:58:47.532029: Auto generated by get_function_ddl API v1
*/
CREATE OR REPLACE FUNCTION aud_certification_trigger_fn()
RETURNS trigger AS $$
DECLARE

v_p_key text:=to_char(now()::date,'YYYYMM');

BEGIN 
/*
2020-01-14 09:39:35.736957+00: Auto generated by enable_audit API
*/
--create partition table if not exists


IF TG_OP='INSERT' THEN 
    INSERT INTO audit.aud_hrms_certification (
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
ELSIF TG_OP='UPDATE' THEN 
    INSERT INTO audit.aud_hrms_certification (
        new_data,
        old_data,
        changed_columns,
        created_timestamp,
        query,username,
        operation_mode,
        p_key) 
    SELECT row_to_json(NEW.*),
        row_to_json(OLD.*),
        (
            select array_agg(od.key) as changed_columns 
            from jsonb_each(row_to_json(NEW.*)::jsonb) nd, 
            jsonb_each(row_to_json(OLD.*)::jsonb) od 
            where od.key=nd.key and nd.value != od.value
            and od.key not in ('last_modified_date')
        ),
        --null::character varying[],
        now(),
        substring(current_query(),1,1000),
        session_user,TG_OP,now()::date;
    RETURN NEW;
ELSE 
    INSERT INTO audit.aud_hrms_certification (
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
$$ LANGUAGE plpgsql;