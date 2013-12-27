# dump database to file
ssh -l james childr.es "pg_dump -aU pdx911 -F c -f pdx911.dump pdx911_live"

# copy dumped file from server to local machine
scp james@childr.es:~/pdx911.dump ~/Desktop/pdx911.dump

# empty the tables on the local database
psql -a -f ~/Projects/pdx-911-fun/db/empty_tables.sql pdx911_dev

# restore the new data into the empty tables
pg_restore -a1d pdx911_dev ~/Desktop/pdx911.dump
