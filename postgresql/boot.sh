#!/bin/sh
set -e

# This script is in charge of installing the event store table
# and default data for debugging purposes.

echo "Installing default scripts...."

for filename in /go-social/sql/**/*.plpgsql; do
    [ -e "$filename" ] || continue
  echo "Installing $filename";
  sqlScript=`cat $filename`;
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "$sqlScript"
done