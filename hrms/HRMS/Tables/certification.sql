/*
2020-01-21 15:06:16.122965: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS certification(id SERIAL PRIMARY KEY NOT NULL, course_name character varying(100) NULL, institute_name character varying(100) NULL, issue_date date NULL, expiry_date date NULL, no_expiration_date boolean NULL, user_id integer REFERENCES user(id) NOT NULL, created_by character varying(45) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, last_modified_date timestamp with time zone NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25002_id_unique ON hrms.certification USING btree (id);
CREATE INDEX IF NOT EXISTS idx_25002_fk_certification_user1 ON hrms.certification USING btree (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25002_primary ON hrms.certification USING btree (id);
