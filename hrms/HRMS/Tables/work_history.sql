/*
2020-01-21 15:06:16.122965: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS work_history(id SERIAL PRIMARY KEY NOT NULL, company_name character varying(50) NULL, designation character varying(50) NULL, date_of_joining date NULL, date_of_leaving date NULL, present_employer boolean NULL, user_id integer REFERENCES user(id) NOT NULL, created_by character varying(45) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, last_modified_date timestamp with time zone NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25282_id_unique ON hrms.work_history USING btree (id);
CREATE INDEX IF NOT EXISTS idx_25282_fk_work_history_user1 ON hrms.work_history USING btree (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25282_primary ON hrms.work_history USING btree (id);
