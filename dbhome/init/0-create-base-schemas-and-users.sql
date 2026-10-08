-- Creates one database and one owner role per service.
-- Start from this file only on a fresh volume.
-- The passwords here must match the ones in ../.env and in the .env files of the
-- individual services. Replace every 'change-me' before the first start.

CREATE DATABASE n8n;
CREATE USER n8n WITH ENCRYPTED PASSWORD 'change-me';
GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;
GRANT ALL PRIVILEGES ON DATABASE n8n TO admin;
GRANT ALL ON SCHEMA public TO n8n;
GRANT ALL ON SCHEMA public TO admin;
ALTER DATABASE n8n OWNER TO n8n;
CREATE DATABASE common;
GRANT ALL PRIVILEGES ON DATABASE common TO n8n;
GRANT ALL PRIVILEGES ON DATABASE common TO admin;
ALTER DATABASE common OWNER TO n8n;
GRANT CONNECT ON DATABASE common TO n8n;
GRANT USAGE ON SCHEMA public TO n8n;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO n8n;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO n8n;
CREATE DATABASE firefly;
CREATE USER firefly WITH ENCRYPTED PASSWORD 'change-me';
GRANT ALL PRIVILEGES ON DATABASE firefly TO firefly;
GRANT ALL PRIVILEGES ON DATABASE firefly TO admin;
GRANT ALL ON SCHEMA public TO admin;
ALTER DATABASE firefly OWNER TO firefly;
ALTER ROLE firefly SET search_path TO public;
GRANT CREATE ON SCHEMA public TO firefly;
GRANT ALL ON SCHEMA public TO firefly;
GRANT CREATE ON SCHEMA public TO PUBLIC;
CREATE DATABASE paperless;
CREATE USER paperless WITH ENCRYPTED PASSWORD 'change-me';
GRANT ALL PRIVILEGES ON DATABASE paperless TO paperless;
GRANT ALL PRIVILEGES ON DATABASE paperless TO admin;
GRANT ALL ON SCHEMA public TO paperless;
GRANT ALL ON SCHEMA public TO admin;
ALTER DATABASE paperless OWNER TO paperless;
CREATE DATABASE mealie;
CREATE USER mealie WITH ENCRYPTED PASSWORD 'change-me';
GRANT ALL PRIVILEGES ON DATABASE mealie TO mealie;
GRANT ALL PRIVILEGES ON DATABASE mealie TO admin;
GRANT ALL ON SCHEMA public TO mealie;
GRANT ALL ON SCHEMA public TO admin;
ALTER DATABASE mealie OWNER TO mealie;