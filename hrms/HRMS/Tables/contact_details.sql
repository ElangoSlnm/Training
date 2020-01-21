/*
05:58:47.532029: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS contact_details(id SERIAL PRIMARY KEY NOT NULL, personal_email character varying(50) NOT NULL, mobile_number character varying(50) NOT NULL, secondary_phone character varying(50) NULL, current_address_line1 character varying(1000) NOT NULL, current_address_line2 character varying(1000) NULL, current_address_pincode character varying(50) NOT NULL, current_address_country character varying(50) NOT NULL, current_address_state character varying(50) NOT NULL, current_address_city character varying(50) NOT NULL, permanent_address_line1 character varying(1000) NOT NULL, permanent_address_line2 character varying(1000) NULL, permanent_address_pincode character varying(50) NOT NULL, permanent_address_country character varying(50) NOT NULL, permanent_address_state character varying(50) NOT NULL, permanent_address_city character varying(50) NOT NULL, emergency_contact_name character varying(50) NOT NULL, emergency_contact_mobile_number character varying(50) NOT NULL, emergency_contact_relationship character varying(30) NOT NULL, emergency_contact_address_line1 character varying(1000) NOT NULL, emergency_contact_address_line2 character varying(1000) NULL, emergency_contact_pincode character varying(50) NOT NULL, emergency_contact_country character varying(50) NOT NULL, emergency_contact_state character varying(50) NOT NULL, emergency_contact_city character varying(50) NOT NULL, user_id integer REFERENCES user(id) NOT NULL, created_by character varying(45) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, last_modified_date timestamp with time zone NOT NULL, same_as_current_address boolean NULL, emergency_contact_selected_address character varying(50) NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25023_user_id_unique ON hrms.contact_details USING btree (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25023_id_unique ON hrms.contact_details USING btree (id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25023_primary ON hrms.contact_details USING btree (id);