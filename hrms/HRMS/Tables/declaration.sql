/*
2020-01-21 15:06:16.122965: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS declaration(id SERIAL PRIMARY KEY NOT NULL, name character varying(50) NOT NULL, date date NOT NULL, any_personnel_at_pramati character varying(1000) NOT NULL, submitted_employment_application character varying(1000) NOT NULL, worked_in_any_pramati character varying(1000) NOT NULL, agree boolean NOT NULL, user_id integer REFERENCES user(id) NOT NULL, created_by character varying(45) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, last_modified_date timestamp with time zone NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25038_user_id_unique ON hrms.declaration USING btree (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25038_id_unique ON hrms.declaration USING btree (id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25038_primary ON hrms.declaration USING btree (id);
