/*
05:58:47.532029: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS employee_details_vw(first_name character varying(50) NOT NULL, middle_name character varying(50) NOT NULL, user_id integer NOT NULL, PRIMARY KEY(first_name, middle_name, user_id));
CREATE UNIQUE INDEX IF NOT EXISTS idx_25069_primary ON hrms.employee_details_vw USING btree (first_name, middle_name, user_id);
