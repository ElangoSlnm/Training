/*
05:58:47.532029: Auto generated by get_table_ddl API v1
*/
CREATE TABLE IF NOT EXISTS table33(id SERIAL PRIMARY KEY NOT NULL, test_date date NOT NULL, updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP );
CREATE UNIQUE INDEX IF NOT EXISTS idx_25187_primary ON hrms.table33 USING btree (id);