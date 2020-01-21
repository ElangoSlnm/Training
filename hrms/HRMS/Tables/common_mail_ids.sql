/*
2020-01-21 15:06:16.122965: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS common_mail_ids(id SERIAL PRIMARY KEY NOT NULL, mail_id character varying(200) NULL, password character varying(45) NULL, role character varying(45) NULL, created_by character varying(45) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, location character varying(255) NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25017_id_unique ON hrms.common_mail_ids USING btree (id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25017_primary ON hrms.common_mail_ids USING btree (id);
