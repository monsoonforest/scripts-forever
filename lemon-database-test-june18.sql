## bring csvsql into postgresql on command line using sudo su - postgres

createdb lemontest

csvsql --db postgresql:///lemontest --tables sites --insert /home/user/documents/lemon-india/database-creation/LEMON-SITES.csv 

csvsql --db postgresql:///lemontest --tables gridid --insert /home/user/documents/lemon-india/database-creation/GRIDID-table.csv

## then type

psql lemontest

## created a primary key column of the gridid table because it has to be unique for every row
ALTER TABLE gridid ADD COLUMN key_column BIGSERIAL PRIMARY KEY;

## assign primary key for sites
ALTER TABLE "public"."sites" ADD PRIMARY KEY("siteid");

## add constraint and foreign key for gridid (child table) to reference sites (parent table) keep column name in double quotes!!
ALTER TABLE gridid ADD CONSTRAINT gridid_SITEID_fkey FOREIGN KEY ("siteid") REFERENCES sites ("siteid");
