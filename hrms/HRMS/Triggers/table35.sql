/*
2020-01-21 15:06:16.122965: Auto generated by get_trigger_ddl API v1
*/
CREATE trigger hrms_table35_aud_trig
BEFORE INSERT OR DELETE OR UPDATE
ON table35
 FOR EACH ROW
EXECUTE PROCEDURE aud_table35_trigger_fn();
