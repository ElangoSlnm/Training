/*
2020-01-21 15:06:16.122965: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS user_asset_details(id SERIAL PRIMARY KEY NOT NULL, asset_type character varying(45) NULL, operating_system character varying(45) NULL, ram character varying(45) NULL, created_by character varying(45) NULL, created_date date NULL, last_modified_by character varying(45) NULL, last_modified_date date NULL, user_id integer REFERENCES user(id) NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25227_id_unique ON hrms.user_asset_details USING btree (id);
CREATE INDEX IF NOT EXISTS idx_25227_fk_user_asset_details_user1 ON hrms.user_asset_details USING btree (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25227_primary ON hrms.user_asset_details USING btree (id);
