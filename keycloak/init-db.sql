SELECT format('CREATE ROLE %I LOGIN', :'kc_user')
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'kc_user')
\gexec

SELECT format('ALTER ROLE %I WITH LOGIN PASSWORD %L', :'kc_user', :'kc_password')
\gexec

SELECT format('CREATE DATABASE %I OWNER %I', :'kc_db', :'kc_user')
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'kc_db')
\gexec

SELECT format('REVOKE ALL ON DATABASE %I FROM PUBLIC', :'kc_db')
\gexec
