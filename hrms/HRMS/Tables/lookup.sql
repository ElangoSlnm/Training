/*
05:58:47.532029: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS lookup(id SERIAL PRIMARY KEY NOT NULL, lookup_type character varying(45) NOT NULL, data_value character varying(250) NOT NULL, status character varying(45) NOT NULL DEFAULT 'Active'::character varying , created_by character varying(45) NOT NULL DEFAULT 'admin'::character varying , created_date timestamp with time zone NOT NULL DEFAULT now() , last_modified_by character varying(45) NOT NULL DEFAULT 'admin'::character varying , last_modified_date timestamp with time zone NOT NULL DEFAULT now() , qb_lookup_value character varying(100) NULL, attribute integer NULL, qb_value character varying(255) NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25106_id_unique ON hrms.lookup USING btree (id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25106_primary ON hrms.lookup USING btree (id);
