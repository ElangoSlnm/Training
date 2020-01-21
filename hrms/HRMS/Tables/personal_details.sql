/*
2020-01-21 15:06:16.122965: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS personal_details(id SERIAL PRIMARY KEY NOT NULL, first_name character varying(50) NOT NULL, middle_name character varying(50) NULL, last_name character varying(50) NOT NULL, gender character varying(30) NOT NULL, blood_group character varying(30) NOT NULL, nationality character varying(50) NOT NULL, fathers_name character varying(50) NOT NULL, mothers_name character varying(50) NOT NULL, marital_status character varying(30) NOT NULL, spouse_name character varying(50) NULL, date_of_birth date NOT NULL, differently_abled character varying(50) NOT NULL, profile_picture character varying(2500) NULL, age integer NOT NULL, gender_other character varying(100) NULL, blood_group_other character varying(100) NULL, nationality_other character varying(100) NULL, differently_abled_category_other character varying(100) NULL, marital_status_other character varying(100) NULL, user_id integer REFERENCES user(id) NOT NULL, created_by character varying(45) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, last_modified_date timestamp with time zone NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25157_user_id_unique ON hrms.personal_details USING btree (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25157_id_unique ON hrms.personal_details USING btree (id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25157_primary ON hrms.personal_details USING btree (id);
