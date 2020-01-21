/*
05:58:47.532029: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS user_skill(id SERIAL PRIMARY KEY NOT NULL, user_id integer REFERENCES user(id) NOT NULL, basic_skill_id integer REFERENCES basic_skill(id) NOT NULL, created_by character varying(45) NOT NULL, created_date timestamp with time zone NOT NULL, last_modified_by character varying(45) NOT NULL, last_modified_date timestamp with time zone NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25240_id_unique ON hrms.user_skill USING btree (id);
CREATE INDEX IF NOT EXISTS idx_25240_fk_user_skill_basic_skill1 ON hrms.user_skill USING btree (basic_skill_id);
CREATE INDEX IF NOT EXISTS idx_25240_fk_skill_user1 ON hrms.user_skill USING btree (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_25240_primary ON hrms.user_skill USING btree (id);
