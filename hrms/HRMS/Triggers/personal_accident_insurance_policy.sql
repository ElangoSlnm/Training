/*
2020-01-21 15:06:16.122965: Auto generated by get_trigger_ddl API v1
*/
CREATE trigger hrms_personal_accident_insurance_policy_aud_trig
BEFORE INSERT OR DELETE OR UPDATE
ON personal_accident_insurance_policy
 FOR EACH ROW
EXECUTE PROCEDURE aud_personal_accident_insurance_policy_trigger_fn();
