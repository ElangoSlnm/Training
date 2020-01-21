/*
05:58:47.532029: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS accommodation_location(id SERIAL PRIMARY KEY NOT NULL, accommodation_place_name character varying(100) NOT NULL, user_id integer UNIQUE REFERENCES user(id) NOT NULL, accommodation_address character varying(200) NOT NULL, created_by character varying(50) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, last_modified_date timestamp with time zone NOT NULL, accommodation_status character varying(45) NULL, location_other character varying(45) NULL, address_other character varying(45) NULL);
CREATE UNIQUE INDEX IF NOT EXISTS "UK_accommodation_locationHW2X" ON hrms.accommodation_location USING btree (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_24981_id_unique ON hrms.accommodation_location USING btree (id);
CREATE INDEX IF NOT EXISTS idx_24981_fk_accommodation_location_user1 ON hrms.accommodation_location USING btree (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_24981_primary ON hrms.accommodation_location USING btree (id);