#!/bin/sh

set -e

if [ "${DEBUG}" = "true" ]; then
  set -x
fi

# If command is provided run that
if [ "${1:0:1}" != '-' ]; then
  exec "$@"
fi

# Detect linked PostgreSQL instance
if [ -n "${POSTGRESQL_PORT_5432_TCP_ADDR}" ]; then
  JDBC_DRIVER=${JDBC_DRIVER:-postgresql}
  PGSQL_HOST=${PGSQL_HOST:-${POSTGRESQL_PORT_5432_TCP_ADDR}}
  PGSQL_PORT=${PGSQL_PORT:-${POSTGRESQL_PORT_5432_TCP_PORT}}

  # support for linked official postgres image
  PGSQL_USER=${PGSQL_USER:-${POSTGRESQL_ENV_POSTGRES_USER}}
  PGSQL_PASS=${PGSQL_PASS:-${POSTGRESQL_ENV_POSTGRES_PASSWORD}}
  PGSQL_NAME=${PGSQL_NAME:-${POSTGRESQL_ENV_POSTGRES_DB}}
  PGSQL_NAME=${PGSQL_NAME:-${POSTGRESQL_ENV_POSTGRES_USER}}

  # support for linked sameersbn/postgresql image
  PGSQL_USER=${PGSQL_USER:-${POSTGRESQL_ENV_DB_USER}}
  PGSQL_PASS=${PGSQL_PASS:-${POSTGRESQL_ENV_DB_PASS}}
  PGSQL_NAME=${PGSQL_NAME:-${POSTGRESQL_ENV_DB_NAME}}

  # support for linked orchardup/postgresql image
  PGSQL_USER=${PGSQL_USER:-${POSTGRESQL_ENV_POSTGRESQL_USER}}
  PGSQL_PASS=${PGSQL_PASS:-${POSTGRESQL_ENV_POSTGRESQL_PASS}}
  PGSQL_NAME=${PGSQL_NAME:-${POSTGRESQL_ENV_POSTGRESQL_DB}}

  # support for linked paintedfox/postgresql image
  PGSQL_USER=${PGSQL_USER:-${POSTGRESQL_ENV_USER}}
  PGSQL_PASS=${PGSQL_PASS:-${POSTGRESQL_ENV_PASS}}
  PGSQL_NAME=${PGSQL_NAME:-${POSTGRESQL_ENV_DB}}
fi

# Setup for postgresql database
if [ "${JDBC_DRIVER}" = "postgresql" ]; then
  # Connection settings
  JDBC_URL="jdbc:postgresql://${PGSQL_HOST:-postgresql}:${PGSQL_PORT:-5432}/${PGSQL_NAME:-postgres}"
  JBDC_USERNAME=${PGSQL_USER:-postgres}
  JBDC_PASSWORD=${PGSQL_PASS}
fi

# Set the default JDBC values
JDBC_DRIVER=${JDBC_DRIVER:-h2}
JBDC_USERNAME=${JBDC_USERNAME:-sonar}
JBDC_PASSWORD=${JBDC_PASSWORD:-sonar}

# Set the URL, USERNAME and PASSWORD to use unless manually overriden.
SONARQUBE_JDBC_URL=${SONARQUBE_JDBC_URL:-${JDBC_URL}}
SONARQUBE_JDBC_USERNAME=${SONARQUBE_JDBC_USERNAME:-${JBDC_USERNAME}}
SONARQUBE_JDBC_PASSWORD=${SONARQUBE_JDBC_PASSWORD:-${JBDC_PASSWORD}}

# Start SonarQube
exec java -jar "lib/sonar-application-$SONAR_VERSION.jar" \
  -Dsonar.log.console=true \
  -Dsonar.jdbc.url="$SONARQUBE_JDBC_URL" \
  -Dsonar.jdbc.username="$SONARQUBE_JDBC_USERNAME" \
  -Dsonar.jdbc.password="$SONARQUBE_JDBC_PASSWORD" \
  -Dsonar.web.javaAdditionalOpts="$SONARQUBE_WEB_JVM_OPTS -Djava.security.egd=file:/dev/./urandom" \
  "$@"
