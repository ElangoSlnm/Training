/*
05:58:47.532029: Auto generated by get_trigger_ddl API v1
*/
CREATE trigger hrms_educations_aud_trig
BEFORE INSERT OR DELETE OR UPDATE
ON educations
 FOR EACH ROW
EXECUTE PROCEDURE aud_educations_trigger_fn();
