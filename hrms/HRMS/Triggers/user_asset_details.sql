/*
05:58:47.532029: Auto generated by get_trigger_ddl API v1
*/
CREATE trigger hrms_user_asset_details_aud_trig
BEFORE INSERT OR DELETE OR UPDATE
ON user_asset_details
 FOR EACH ROW
EXECUTE PROCEDURE aud_user_asset_details_trigger_fn();