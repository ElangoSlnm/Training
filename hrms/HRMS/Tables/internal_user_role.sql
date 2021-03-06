/*
2020-01-21 15:06:16.122965: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS internal_user_role(id SERIAL PRIMARY KEY NOT NULL, role_id integer REFERENCES role(id) NOT NULL, email character varying(50) NULL, created_by character varying(45) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, last_modified_date timestamp with time zone NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25100_id_unique ON hrms.internal_user_role USING btree (id);
CREATE INDEX IF NOT EXISTS idx_25100_fk_user_role_role1 ON hrms.internal_user_role USING btree (role_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25100_primary ON hrms.internal_user_role USING btree (id);
