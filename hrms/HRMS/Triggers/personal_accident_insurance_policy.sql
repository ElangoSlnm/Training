/*
05:58:47.532029: Auto generated by get_trigger_ddl API v1
*/
CREATE trigger hrms_personal_accident_insurance_policy_aud_trig
BEFORE INSERT OR DELETE OR UPDATE
ON personal_accident_insurance_policy
 FOR EACH ROW
EXECUTE PROCEDURE aud_personal_accident_insurance_policy_trigger_fn();