/*
2020-01-21 15:06:16.122965: Auto generated by get_trigger_ddl API v1
*/
CREATE trigger hrms_user_test_aud_trig
BEFORE INSERT OR DELETE OR UPDATE
ON user_test
 FOR EACH ROW
EXECUTE PROCEDURE aud_user_test_trigger_fn();
