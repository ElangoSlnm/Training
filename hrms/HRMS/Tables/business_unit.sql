/*
05:58:47.532029: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS business_unit(id SERIAL PRIMARY KEY NOT NULL, business_unit character varying(100) NOT NULL, created_by character varying(45) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, last_modified_date timestamp with time zone NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_24996_id_unique ON hrms.business_unit USING btree (id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_24996_primary ON hrms.business_unit USING btree (id);
