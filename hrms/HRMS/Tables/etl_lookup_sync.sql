/*
2020-01-21 15:06:16.122965: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS etl_lookup_sync(ID SERIAL PRIMARY KEY NOT NULL, local_data_type character varying(255) NULL, qb_db_name character varying(255) NULL);
CREATE UNIQUE INDEX IF NOT EXISTS etl_lookup_sync_pkey ON hrms.etl_lookup_sync USING btree ("ID");
