/*
SQL script for building from scratch a new data warehouse
*/

--create tables from scratch.
.read 1_create_tables_dw.sql
--load the previous table with data coming from csv files as source.
.read 2_schema_dw.sql