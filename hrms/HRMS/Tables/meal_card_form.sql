/*
2020-01-21 15:06:16.122965: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS meal_card_form(id SERIAL PRIMARY KEY NOT NULL, date_of_submission date NOT NULL, employee_name character varying(50) NOT NULL, place character varying(50) NOT NULL, meal_card_form_enabled boolean NOT NULL, user_id integer REFERENCES user(id) NOT NULL, created_by character varying(45) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, last_modified_date timestamp with time zone NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25124_id_unique ON hrms.meal_card_form USING btree (id);
CREATE INDEX IF NOT EXISTS idx_25124_fk_meal_card_form_user1 ON hrms.meal_card_form USING btree (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25124_primary ON hrms.meal_card_form USING btree (id);
