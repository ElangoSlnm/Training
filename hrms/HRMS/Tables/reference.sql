/*
2020-01-21 15:06:16.122965: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS reference(id SERIAL PRIMARY KEY NOT NULL, name character varying(50) NULL, designation character varying(50) NULL, organisation character varying(50) NULL, email character varying(50) NULL, phone_number character varying(50) NULL, user_id integer REFERENCES user(id) NOT NULL, created_by character varying(45) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, last_modified_date timestamp with time zone NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25175_id_unique ON hrms.reference USING btree (id);
CREATE INDEX IF NOT EXISTS idx_25175_fk_reference_user1 ON hrms.reference USING btree (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25175_primary ON hrms.reference USING btree (id);
