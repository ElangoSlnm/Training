/*
2020-01-21 15:06:16.122965: Auto generated by get_trigger_ddl API v1
*/
CREATE trigger hrms_user_aud_trig
BEFORE INSERT OR DELETE OR UPDATE
ON user
 FOR EACH ROW
EXECUTE PROCEDURE aud_user_trigger_fn();
