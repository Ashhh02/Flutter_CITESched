BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "schedule" DROP COLUMN "loadType";
ALTER TABLE "schedule" ADD COLUMN "loadTypes" json;
--
-- ACTION DROP TABLE
--
DROP TABLE "subject" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "subject" (
    "id" bigserial PRIMARY KEY,
    "code" text NOT NULL,
    "name" text NOT NULL,
    "units" bigint NOT NULL,
    "yearLevel" bigint,
    "term" bigint,
    "types" json NOT NULL,
    "program" text NOT NULL,
    "studentsCount" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR citesched
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('citesched', '20260218053453200', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260218053453200', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260109031533194', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260109031533194', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20250825102351908-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250825102351908-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
