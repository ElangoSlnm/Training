/*
2020-01-21 15:06:16.122965: Auto generated by get_trigger_ddl API v1
*/
CREATE trigger hrms_user_upload_files_aud_trig
BEFORE INSERT OR DELETE OR UPDATE
ON user_upload_files
 FOR EACH ROW
EXECUTE PROCEDURE aud_user_upload_files_trigger_fn();
