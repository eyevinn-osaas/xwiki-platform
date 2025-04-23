#!/bin/bash

if [ -z "$DATABASE_URL" ]; then
  echo "DATABASE_URL is not set. Exiting."
  exit 1
fi

# Parse the DATABASE_URL
export DB_USER=$(echo "$DATABASE_URL" | sed -E 's|postgres://([^:]+):.*|\1|')
export DB_PASSWORD=$(echo "$DATABASE_URL" | sed -E 's|postgres://[^:]+:([^@]+)@.*|\1|')
export DB_HOST=$(echo "$DATABASE_URL" | sed -E 's|postgres://[^@]+@([^:]+):.*|\1|')
export DB_PORT=$(echo "$DATABASE_URL" | sed -E 's|postgres://[^:]+:[^@]+@[^:]+:([^/]+)/.*|\1|')
export DB_DATABASE=$(echo "$DATABASE_URL" | sed -E 's|postgres://[^/]+/([^?]+).*|\1|')

# Output the parsed values
echo "Database connection details:"
echo "User: $DB_USER"
echo "Password: ********"
echo "Host: $DB_HOST"
echo "Port: $DB_PORT"
echo "Database: $DB_DATABASE"

function safesed {
  # Don't use "sed -i" as it creates a temporary file and perform a rename (thus changing the inode of the initial file)
  # which makes it fail if you map the initial file as a Docker volume mount.
  sed "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" "$3" > "$3.old"
  cp "$3.old" "$3"
  rm "$3.old"
}

safesed "5432" $DB_PORT /usr/local/tomcat/webapps/ROOT/WEB-INF/hibernate.cfg.xml
cat /usr/local/tomcat/webapps/ROOT/WEB-INF/hibernate.cfg.xml

/usr/local/bin/docker-entrypoint.sh "$@"
