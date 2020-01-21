/*
05:58:47.532029: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS medical_insurance_policy(id SERIAL PRIMARY KEY NOT NULL, name character varying(50) NOT NULL, relationship character varying(50) NOT NULL, gender character varying(50) NOT NULL, date_of_birth date NOT NULL, created_by character varying(45) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, last_modified_date timestamp with time zone NOT NULL, user_id integer REFERENCES user(id) NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25136_id_unique ON hrms.medical_insurance_policy USING btree (id);
CREATE INDEX IF NOT EXISTS idx_25136_fk_medical_insurance_policy_user1 ON hrms.medical_insurance_policy USING btree (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25136_primary ON hrms.medical_insurance_policy USING btree (id);