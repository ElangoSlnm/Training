/*
05:58:47.532029: Auto generated by get_trigger_ddl API v1
*/
CREATE trigger hrms_office_location_aud_trig
BEFORE INSERT OR DELETE OR UPDATE
ON office_location
 FOR EACH ROW
EXECUTE PROCEDURE aud_office_location_trigger_fn();