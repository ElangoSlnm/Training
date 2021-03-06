/*
2020-01-21 15:06:16.122965: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS office_location(id SERIAL PRIMARY KEY NOT NULL, office_location character varying(100) NOT NULL, address character varying(200) NOT NULL, created_by character varying(45) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, last_modified_date timestamp with time zone NOT NULL, location_url character varying(300) NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25142_id_unique ON hrms.office_location USING btree (id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25142_primary ON hrms.office_location USING btree (id);
