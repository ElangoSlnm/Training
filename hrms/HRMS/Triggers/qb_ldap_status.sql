/*
2020-01-21 15:06:16.122965: Auto generated by get_trigger_ddl API v1
*/
CREATE trigger hrms_qb_ldap_status_aud_trig
BEFORE INSERT OR DELETE OR UPDATE
ON qb_ldap_status
 FOR EACH ROW
EXECUTE PROCEDURE aud_qb_ldap_status_trigger_fn();
