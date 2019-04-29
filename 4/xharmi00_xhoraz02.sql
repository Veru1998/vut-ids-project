-- SQL skript pro vytvoření pokročilých objektů schématu databáze.
-- Zadání č. 49. – Bug Tracker.
--------------------------------------------------------------------------------
-- Autor: Dominik Harmim <xharmi00@stud.fit.vutbr.cz>.
-- Autor: František Horázný <xhoraz02@stud.fit.vutbr.cz>.


-------------------------------- DROP ------------------------------------------


DROP TABLE "ticket_bug";
DROP TABLE "ticket";
DROP TABLE "module_bug";
DROP TABLE "module";
DROP TABLE "user_language";
DROP TABLE "language";
DROP TABLE "bug";
DROP TABLE "patch";
DROP TABLE "user";
DROP TABLE "programmer";
DROP SEQUENCE "user_id";
DROP MATERIALIZED VIEW "user_ticket_count";


-------------------------------- CREATE ----------------------------------------


CREATE TABLE "programmer" (
	"id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
	"github" VARCHAR(255) NOT NULL,
	"admin" SMALLINT DEFAULT 0 NOT NULL
);

CREATE TABLE "user" (
	-- AUTO_INCREMENT přes trigger definovaný níže
	"id" INT DEFAULT NULL PRIMARY KEY,
	"first_name" VARCHAR(80) NOT NULL,
	"last_name" VARCHAR(80) NOT NULL,
	"birthdate" DATE DEFAULT NULL,
	"email" VARCHAR(255) NOT NULL
		CHECK(REGEXP_LIKE(
			"email", '^[a-z]+[a-z0-9\.]*@[a-z0-9\.-]+\.[a-z]{2,}$', 'i'
		)),
	"password" VARCHAR(255) NOT NULL,
	"programmer_id" INT DEFAULT NULL,
	CONSTRAINT "user_programmer_id_fk"
		FOREIGN KEY ("programmer_id") REFERENCES "programmer" ("id")
		ON DELETE SET NULL
);

CREATE TABLE "patch" (
	"id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
	"description" VARCHAR(500) NOT NULL,
	"created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"deployed" TIMESTAMP DEFAULT NULL,
	"user_id" INT NOT NULL, -- creates
	"programmer_id" INT DEFAULT NULL, -- implements
	CONSTRAINT "patch_user_id_fk"
		FOREIGN KEY ("user_id") REFERENCES "user" ("id")
		ON DELETE CASCADE,
	CONSTRAINT "patch_programmer_id_fk"
		FOREIGN KEY ("programmer_id") REFERENCES "programmer" ("id")
		ON DELETE SET NULL
);

CREATE TABLE "bug" (
	"id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
	"description" VARCHAR(500) NOT NULL,
	"severity" VARCHAR(10) NOT NULL
		CHECK("severity" IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
	"severity_security" VARCHAR(10) DEFAULT NULL
		CHECK("severity_security" IN ('WARNING', 'ERROR', 'CRITICAL')),
	"patch_id" INT DEFAULT NULL,
	CONSTRAINT "bug_patch_id_fk"
		FOREIGN KEY ("patch_id") REFERENCES "patch" ("id")
		ON DELETE SET NULL
);

CREATE TABLE "language" (
	"id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
	"name" VARCHAR(80) NOT NULL
);

CREATE TABLE "user_language" (
	"user_id" INT NOT NULL,
	"language_id" INT NOT NULL,
	CONSTRAINT "user_language_pk"
		PRIMARY KEY ("user_id", "language_id"),
	CONSTRAINT "user_language_user_id_fk"
		FOREIGN KEY ("user_id") REFERENCES "user" ("id")
		ON DELETE CASCADE,
	CONSTRAINT "user_language_language_id_fk"
		FOREIGN KEY ("language_id") REFERENCES "language" ("id")
		ON DELETE CASCADE
);

CREATE TABLE "module" (
	"id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
	"name" VARCHAR(80) NOT NULL,
	"language_id" INT NOT NULL,
	"programmer_id" INT NOT NULL,
	CONSTRAINT "module_language_id_fk"
		FOREIGN KEY ("language_id") REFERENCES "language" ("id")
		ON DELETE CASCADE,
	CONSTRAINT "module_programmer_id_fk"
		FOREIGN KEY ("programmer_id") REFERENCES "programmer" ("id")
		ON DELETE CASCADE
);

CREATE TABLE "module_bug" (
	"module_id" INT NOT NULL,
	"bug_id" INT NOT NULL,
	CONSTRAINT "module_bug_pk"
		PRIMARY KEY ("module_id", "bug_id"),
	CONSTRAINT "module_bug_module_id_fk"
		FOREIGN KEY ("module_id") REFERENCES "module" ("id")
		ON DELETE CASCADE,
	CONSTRAINT "module_bug_bug_id_fk"
		FOREIGN KEY ("bug_id") REFERENCES "bug" ("id")
		ON DELETE CASCADE
);

CREATE TABLE "ticket" (
	"id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
	"description" VARCHAR(500) NOT NULL,
	"resolved" SMALLINT DEFAULT 0 NOT NULL,
	"user_id" INT NOT NULL, -- creates
	"programmer_id" INT DEFAULT NULL, -- opens
	CONSTRAINT "ticket_user_id_fk"
		FOREIGN KEY ("user_id") REFERENCES "user" ("id")
		ON DELETE CASCADE,
	CONSTRAINT "ticket_programmer_id_fk"
		FOREIGN KEY ("programmer_id") REFERENCES "programmer" ("id")
		ON DELETE SET NULL
);

CREATE TABLE "ticket_bug" (
	"ticket_id" INT NOT NULL,
	"bug_id" INT NOT NULL,
	CONSTRAINT "ticket_bug_pk"
		PRIMARY KEY ("ticket_id", "bug_id"),
	CONSTRAINT "ticket_bug_ticket_id_fk"
		FOREIGN KEY ("ticket_id") REFERENCES "ticket" ("id")
		ON DELETE CASCADE,
	CONSTRAINT "ticket_bug_bug_id_fk"
		FOREIGN KEY ("bug_id") REFERENCES "bug" ("id")
		ON DELETE CASCADE
);


------------------------------- TRIGGER ----------------------------------------


-- (1) Trigger pro automatické generování hodnot primárního klíče tabulky user.
CREATE SEQUENCE "user_id";
CREATE OR REPLACE TRIGGER "user_id"
	BEFORE INSERT ON "user"
	FOR EACH ROW
BEGIN
	IF :NEW."id" IS NULL THEN
		:NEW."id" := "user_id".NEXTVAL;
	END IF;
END;

-- (2) Trigger pro vytvoření otisku hesla (hash) při vložení uživatele.
CREATE OR REPLACE TRIGGER "user_hash"
	BEFORE INSERT ON "user"
	FOR EACH ROW
BEGIN
	:NEW."password" :=
		DBMS_OBFUSCATION_TOOLKIT.MD5(
			input => UTL_I18N.STRING_TO_RAW(:NEW."password")
		);
END;


-------------------------------- INSERT ----------------------------------------


INSERT INTO "programmer" ("github", "admin")
VALUES ('https://github.com/harmim', 0);
INSERT INTO "programmer" ("github", "admin")
VALUES ('https://github.com/foobar', 1);

INSERT INTO "user" ("first_name", "last_name", "birthdate", "email", "password", "programmer_id")
VALUES ('Jan', 'Novák', TO_DATE('1972-07-30', 'yyyy/mm/dd'), 'novak@gmail.com', 'heslo1', NULL);
INSERT INTO "user" ("first_name", "last_name", "birthdate", "email", "password", "programmer_id")
VALUES ('Dominik', 'Harmim', TO_DATE('1997-05-29', 'yyyy/mm/dd'), 'harmim6@gmail.com', 'heslo2', 1);
INSERT INTO "user" ("first_name", "last_name", "birthdate", "email", "password", "programmer_id")
VALUES ('Petr', 'Svoboda', TO_DATE('1992-03-15', 'yyyy/mm/dd'), 'svoboda@gmail.com', 'heslo3', 2);

INSERT INTO "patch" ("description", "deployed", "user_id", "programmer_id")
VALUES ('Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', TO_DATE('2019-03-20', 'yyyy/mm/dd'), 1, 1);
INSERT INTO "patch" ("description", "deployed", "user_id", "programmer_id")
VALUES ('Integer malesuada. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', TO_DATE('2019-03-24', 'yyyy/mm/dd'), 2, 2);

INSERT INTO "bug" ("description", "severity", "severity_security", "patch_id")
VALUES ('Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 'HIGH', 'ERROR', 1);
INSERT INTO "bug" ("description", "severity", "severity_security", "patch_id")
VALUES ('Integer malesuada. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 'NORMAL', NULL, 2);
INSERT INTO "bug" ("description", "severity", "severity_security", "patch_id")
VALUES ('Pellentesque arcu.', 'LOW', 'WARNING', NULL);

INSERT INTO "language" ("name")
VALUES ('Java');
INSERT INTO "language" ("name")
VALUES ('C++');

INSERT INTO "user_language" ("user_id", "language_id")
VALUES (1, 1);
INSERT INTO "user_language" ("user_id", "language_id")
VALUES (2, 1);
INSERT INTO "user_language" ("user_id", "language_id")
VALUES (2, 2);
INSERT INTO "user_language" ("user_id", "language_id")
VALUES (3, 2);

INSERT INTO "module" ("name", "language_id", "programmer_id")
VALUES ('HTTP', 1, 1);
INSERT INTO "module" ("name", "language_id", "programmer_id")
VALUES ('Log', 2, 2);
INSERT INTO "module" ("name", "language_id", "programmer_id")
VALUES ('API', 1, 2);

INSERT INTO "module_bug" ("module_id", "bug_id")
VALUES (1, 1);
INSERT INTO "module_bug" ("module_id", "bug_id")
VALUES (1, 2);
INSERT INTO "module_bug" ("module_id", "bug_id")
VALUES (2, 1);
INSERT INTO "module_bug" ("module_id", "bug_id")
VALUES (2, 2);
INSERT INTO "module_bug" ("module_id", "bug_id")
VALUES (2, 3);

INSERT INTO "ticket" ("description", "resolved", "user_id", "programmer_id")
VALUES ('Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 0, 1, NULL);
INSERT INTO "ticket" ("description", "resolved", "user_id", "programmer_id")
VALUES ('Integer malesuada. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 1, 1, 2);

INSERT INTO "ticket_bug" ("ticket_id", "bug_id")
VALUES (2, 1);
INSERT INTO "ticket_bug" ("ticket_id", "bug_id")
VALUES (2, 2);
INSERT INTO "ticket_bug" ("ticket_id", "bug_id")
VALUES (2, 3);


------------------------------ TRIGGER DEMONSTRATION ---------------------------


-- Předvedení triggeru (1): Jan Novák by měl podle výše vložených dat mít
-- ID 1, Dominik Harmim 2 a Petr Svoboda 3.
SELECT "id", "first_name", "last_name"
FROM "user"
ORDER BY "id";

-- Předvedení triggeru (2): uživatelé Jan Novák, Dominik Harmim a Petr Svoboda
-- by podle výše vložených hesel test1, test2 a test3 měli mít v databázi
-- uložené patřičné otisky těchto hesel.
SELECT "first_name", "last_name", "password"
FROM "user"
ORDER BY "id";


------------------------------ PROCEDURE ---------------------------------------

-- Procedura vypíše přehled celkově zadaných ticketů, chyb v nich a celkový
-- počet uživatelů.
CREATE OR REPLACE PROCEDURE "user_bug_ticket_count_summary"
AS
	"avg_bug_count_on_user" NUMBER;
	"avg_ticket_count_on_user" NUMBER;
	"avg_bug_count_on_ticket" NUMBER;
	"num_tickets" NUMBER;
	"num_bugs" NUMBER;
	"num_users" NUMBER;
BEGIN
	SELECT COUNT(*) INTO "num_users" FROM "user";
	SELECT COUNT(*) INTO "num_bugs" FROM "bug";
	SELECT COUNT(*) INTO "num_tickets" FROM "ticket";

	"avg_bug_count_on_user" := "num_bugs" / "num_users";
	"avg_ticket_count_on_user" := "num_tickets" / "num_users";
	"avg_bug_count_on_ticket" := "num_bugs" / "num_tickets";

	DBMS_OUTPUT.put_line(
		'There is a total of '
		|| "num_users" || ' users, '
		|| "num_tickets" || ' tickets and '
		|| "num_bugs" || ' bugs.'
	);
	DBMS_OUTPUT.put_line(
		'It is '
		|| "avg_bug_count_on_user" || ' bugs and '
		|| "avg_ticket_count_on_user" || ' tickets per one user and '
		|| "avg_bug_count_on_ticket" || ' average bugs per one ticket.'
	);

	EXCEPTION WHEN ZERO_DIVIDE THEN
	BEGIN
		IF "num_users" = 0 THEN
			DBMS_OUTPUT.put_line('There are no users!');
		END IF;

		IF "num_tickets" = 0 THEN
			DBMS_OUTPUT.put_line('There are no tickets!');
		END IF;
	END;
END;
-- příklad spuštění
BEGIN "user_bug_ticket_count_summary"; END;

-- Procedura počítá, kolik celkově uživatelů ovládá daný jazyk.
CREATE OR REPLACE PROCEDURE "language_knowledge"
	("lang_name" IN VARCHAR)
AS
	"all_users" NUMBER;
	"target_users" NUMBER;
	"language_id" "language"."id"%TYPE;
	"target_language_id" "language"."id"%TYPE;
	CURSOR "cursor_languages" IS SELECT "language_id" FROM "user_language";
BEGIN
	SELECT COUNT(*) INTO "all_users" FROM "user";

	"target_users" := 0;

	SELECT "id" INTO "target_language_id"
	FROM "language"
	WHERE "name" = "lang_name";

	OPEN "cursor_languages";
	LOOP
		FETCH "cursor_languages" INTO "language_id";

		EXIT WHEN "cursor_languages"%NOTFOUND;

		IF "language_id" = "target_language_id" THEN
			"target_users" := "target_users" + 1;
		END IF;
	END LOOP;
	CLOSE "cursor_languages";

	DBMS_OUTPUT.put_line(
		'Language ' || "lang_name" || ' is known by ' || "target_users"
		|| ' users out of ' || "all_users" || ' users in total.'
	);

	EXCEPTION WHEN NO_DATA_FOUND THEN
	BEGIN
		DBMS_OUTPUT.put_line(
			'Language ' || "lang_name" || ' has not been found!'
		);
	END;
END;
-- příklad spuštění
BEGIN "language_knowledge"('Java'); END;


----------------------------- EXPLAIN PLAN -------------------------------------


-- Kteří uživatelé, kteří jsou programátoři ovládají více než jeden jazyk
-- a kolik jich ovládají?
EXPLAIN PLAN FOR
SELECT
	"u"."email" AS "email",
	COUNT("ul"."language_id") AS "count"
FROM "user" "u"
JOIN "user_language" "ul" ON "ul"."user_id" = "u"."id"
WHERE "u"."programmer_id" IS NOT NULL
GROUP BY "u"."id", "u"."email"
HAVING COUNT("ul"."language_id") > 1
ORDER BY "email";
-- výpis
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Index pro email uživatele (seskupení podle emailu a rychlejší vyhledávání).
CREATE INDEX "user_programmer" ON "user" ("programmer_id");

-- druhý pokus
EXPLAIN PLAN FOR
SELECT
	"u"."email" AS "email",
	COUNT("ul"."language_id") AS "count"
FROM "user" "u"
JOIN "user_language" "ul" ON "ul"."user_id" = "u"."id"
WHERE "u"."programmer_id" IS NOT NULL
GROUP BY "u"."id", "u"."email"
HAVING COUNT("ul"."language_id") > 1
ORDER BY "email";
-- výpis
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


--------------------------- MATERIALIZED VIEW ----------------------------------


-- Materializovaný pohled na všechny uživatele a počet jejich tiketů.
CREATE MATERIALIZED VIEW "user_ticket_count" AS
SELECT
	"u"."id",
	"u"."first_name",
	"u"."last_name",
	COUNT("t"."user_id") AS "tickets_count"
FROM "user" "u"
LEFT JOIN "ticket" "t" ON "t"."user_id" = "u"."id"
GROUP BY "u"."id", "u"."first_name", "u"."last_name";

-- Výpis materializovaného pohledu.
SELECT * FROM "user_ticket_count";

-- Aktualizace dat, které jsou v materializovaném pohledu.
UPDATE "ticket" SET "user_id" = 2 WHERE "id" = 1;

-- Data se v materializovaném pohledu neaktualizují.
SELECT * FROM "user_ticket_count";


-------------------------------- PRIVILEGES ------------------------------------


GRANT ALL ON "ticket_bug" TO xhoraz02;
GRANT ALL ON "ticket" TO xhoraz02;
GRANT ALL ON "module_bug" TO xhoraz02;
GRANT ALL ON "module" TO xhoraz02;
GRANT ALL ON "user_language" TO xhoraz02;
GRANT ALL ON "language" TO xhoraz02;
GRANT ALL ON "bug" TO xhoraz02;
GRANT ALL ON "patch" TO xhoraz02;
GRANT ALL ON "user" TO xhoraz02;
GRANT ALL ON "programmer" TO xhoraz02;

GRANT EXECUTE ON "user_bug_ticket_count_summary" TO xhoraz02;
GRANT EXECUTE ON "language_knowledge" TO xhoraz02;

GRANT ALL ON "user_ticket_count" TO xhoraz02;
