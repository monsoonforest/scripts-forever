## bring csvsql into postgresql on command line using sudo su - postgres

createdb lemontest

csvsql --db postgresql:///lemontest --tables ADULTSTEM_DATA --insert /home/user/documents/lemon-india/database-creation/testing_staging/ADULTSTEM_DATA.csv
csvsql --db postgresql:///lemontest --tables ADULTSTEM_ID --insert /home/user/documents/lemon-india/database-creation/testing_staging/ADULTSTEM_ID.csv
csvsql --db postgresql:///lemontest --tables ADULTTREE_CENSUS_DATA --insert /home/user/documents/lemon-india/database-creation/testing_staging/ADULTTREE_CENSUS_DATA.csv
csvsql --db postgresql:///lemontest --tables ADULTTREE_HEIGHT_CENSUS_DATA --insert /home/user/documents/lemon-india/database-creation/testing_staging/ADULTTREE_HEIGHT_CENSUS_DATA.csv
csvsql --db postgresql:///lemontest --tables ADULTTREE_HEIGHT --insert /home/user/documents/lemon-india/database-creation/testing_staging/ADULTTREE_HEIGHT.csv
csvsql --db postgresql:///lemontest --tables ADULTTREE_ID --insert /home/user/documents/lemon-india/database-creation/testing_staging/ADULTTREE_ID.csv
csvsql --db postgresql:///lemontest --tables DENDROBAND_CENSUS_DATA --insert /home/user/documents/lemon-india/database-creation/testing_staging/DENDROBAND_CENSUS_DATA.csv
csvsql --db postgresql:///lemontest --tables DENDROBAND_DATA --insert /home/user/documents/lemon-india/database-creation/testing_staging/DENDROBAND_DATA.csv
csvsql --db postgresql:///lemontest --tables SITE_DATA --insert /home/user/documents/lemon-india/database-creation/testing_staging/SITE_DATA.csv
csvsql --db postgresql:///lemontest --tables LITTERFALL_DATA --insert /home/user/documents/lemon-india/database-creation/testing_staging/LITTERFALL_DATA.csv
csvsql --db postgresql:///lemontest --tables TRAP_CENSUSDATES --insert /home/user/documents/lemon-india/database-creation/testing_staging/TRAP_CENSUS.csv
csvsql --db postgresql:///lemontest --tables TRAP_ID --insert /home/user/documents/lemon-india/database-creation/testing_staging/TRAP_ID.csv
csvsql --db postgresql:///lemontest --tables SEEDTRAP_DATA --insert /home/user/documents/lemon-india/database-creation/testing_staging/SEEDTRAP_DATA.csv
csvsql --db postgresql:///lemontest --tables SPECIES_DATA --insert /home/user/documents/lemon-india/database-creation/testing_staging/SPECIES_DATA.csv

## then type

psql lemontest

## created a primary key column of the gridid table because it has to be unique for every row
ALTER TABLE gridid ADD COLUMN key_column BIGSERIAL PRIMARY KEY;

## assign primary key for sites
ALTER TABLE "public"."sites" ADD PRIMARY KEY("siteid");

## add constraint and foreign key for gridid (child table) to reference sites (parent table) keep column name in double quotes!!
ALTER TABLE gridid ADD CONSTRAINT gridid_SITEID_fkey FOREIGN KEY ("siteid") REFERENCES sites ("siteid");
