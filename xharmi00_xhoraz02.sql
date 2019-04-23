-- SQL skript s několika dotazy SELECT.
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


-------------------------------- CREATE ----------------------------------------


CREATE TABLE "programmer" (
	"id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
	"github" VARCHAR(255) NOT NULL,
	"admin" SMALLINT DEFAULT 0 NOT NULL
);

CREATE TABLE "user" (
	"id" INT DEFAULT NULL,
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


-------------------------------- INSERT ----------------------------------------


INSERT INTO "programmer" ("github", "admin")
VALUES ('https://github.com/harmim', 0);
INSERT INTO "programmer" ("github", "admin")
VALUES ('https://github.com/foobar', 1);
INSERT INTO "programmer" ("github", "admin")
VALUES ('https://github.com/programator', 0);

INSERT INTO "user" ("first_name", "last_name", "birthdate", "email", "password", "programmer_id")
VALUES ('Jan', 'Novák', TO_DATE('1972-07-30', 'yyyy/mm/dd'), 'novak@gmail.com', 'dfDFS789dS2fd', NULL);
INSERT INTO "user" ("first_name", "last_name", "birthdate", "email", "password", "programmer_id")
VALUES ('Dominik', 'Harmim', TO_DATE('1997-05-29', 'yyyy/mm/dd'), 'harmim6@gmail.com', 'fd@Jfd2po223', 1);
INSERT INTO "user" ("first_name", "last_name", "birthdate", "email", "password", "programmer_id")
VALUES ('Petr', 'Svoboda', TO_DATE('1992-03-15', 'yyyy/mm/dd'), 'svoboda@gmail.com', 'dfji**#$#DF', 2);
INSERT INTO "user" ("first_name", "last_name", "birthdate", "email", "password", "programmer_id")
VALUES ('Nahodny', 'Programator', TO_DATE('1922-02-2', 'yyyy/mm/dd'), 'programator@kezniceni.com', 'lamala**#$#DF', 3);

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
INSERT INTO "module" ("name", "language_id", "programmer_id")
VALUES ('MyModule', 1, 3);

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


-------------------------------- SELECT ----------------------------------------


-- Které moduly jsou implementovány v jazyce Java?
-- (modul)
-- spojení dvou tabulek --
SELECT "m"."name" AS "modul"
FROM "module" "m"
JOIN "language" "l" ON "l"."id" = "m"."language_id"
WHERE "l"."name" = 'Java'
ORDER BY "modul";

-- Které patche opravují bugy obsahující bezpečnostní hrozbu?
-- (id, popis, zavaznost_hrozby)
-- spojení dvou tabulek --
SELECT
	"p"."id" AS "id",
	"p"."description" AS "popis",
	"b"."severity_security" AS "zavaznost_hrozby"
FROM "patch" "p"
JOIN "bug" "b" ON "b"."patch_id" = "p"."id"
WHERE "b"."severity_security" IS NOT NULL
ORDER BY "zavaznost_hrozby", "id";

-- Jaké jazyky ovládají jednotliví uživatelé?
-- (jmeno, prijmeni, email, jazyk)
-- spojení tří tabulek --
SELECT
	"u"."first_name" AS "jmeno",
	"u"."last_name" AS "prijmeni",
	"u"."email" AS "email",
	"l"."name" AS "jazyk"
FROM "user_language" "ul"
JOIN "user" "u" ON "u"."id" = "ul"."user_id"
JOIN "language" "l" ON "l"."id" = "ul"."language_id"
ORDER BY "prijmeni", "jmeno", "jazyk";

-- Kteří uživatelé ovládají více než jeden jazyk a kolik jich ovládají?
-- (jmeno, prijmeni, email, pocet)
-- klauzule GROUP BY s použitím agregační funkce --
SELECT
	"u"."first_name" AS "jmeno",
	"u"."last_name" AS "prijmeni",
	"u"."email" AS "email",
	COUNT("ul"."language_id") AS "pocet"
FROM "user" "u"
JOIN "user_language" "ul" ON "ul"."user_id" = "u"."id"
GROUP BY "u"."id", "u"."first_name", "u"."last_name", "u"."email"
HAVING COUNT("ul"."language_id") > 1
ORDER BY "prijmeni", "jmeno";

-- Který modul obsahuje nejvíce bugů a kolik jich obsahuje?
-- (modul, pocet)
-- klauzule GROUP BY s použitím agregační funkce --
SELECT
	"m"."name" AS "modul",
	COUNT("mb"."bug_id") AS "pocet"
FROM "module" "m"
JOIN "module_bug" "mb" ON "mb"."module_id" = "m"."id"
GROUP BY "m"."id", "m"."name"
HAVING COUNT("mb"."bug_id") >= ALL (
	SELECT COUNT("mb"."bug_id")
	FROM "module_bug" "mb"
	GROUP BY "mb"."module_id"
)
ORDER BY "modul";

-- Které tickety neobsahují žádný specifický bug?
-- (id, popis)
-- predikát EXISTS
SELECT
	"t"."id" AS "id",
	"t"."description" AS "popis"
FROM "ticket" "t"
WHERE NOT EXISTS (
	SELECT *
	FROM "ticket_bug" "tb"
	WHERE "tb"."ticket_id" = "t"."id"
)
ORDER BY "id";

-- Které moduly neobsahují žádné bugy?
-- (modul)
-- predikát IN s vnořeným SELECT
SELECT
	"m"."name" AS "modul"
FROM "module" "m"
WHERE "m"."id" NOT IN (
	SELECT DISTINCT "mb"."module_id"
	FROM "module_bug" "mb"
)
ORDER BY "modul";



------------------------------- TRIGGER ---------------------------------------

--sekvence pro následující trigger
CREATE SEQUENCE user_position;

-- trigger na vytvoření pořadí přidání se (PK) 
CREATE OR REPLACE TRIGGER user_number BEFORE
	INSERT ON "user"
	FOR EACH ROW
	BEGIN
		SELECT user_position.NEXTVAL
		INTO : NEW.id
		FROM dual;
	END;
/

-- Předvedení: Jan Novák by měl podle výše uvedených insertů mít id 1, Dominik Harmim 2 a Petr Svoboda 3
SELECT "u"."first_name","u"."id" FROM "user" "u" ORDER BY "id";

-- při rušení programátora se všechny moduly, o které se staral automaticky přiřadí náhodným jiným programátorům
CREATE OR REPLACE TRIGGER module_spare_programmer BEFORE
	DELETE ON "programmer"
	FOR EACH ROW
	BEGIN
		UPDATE "module"
		SET "programmer_id" = 	(SELECT "id" FROM  
									(SELECT "id" FROM "programmer"
									ORDER BY DBMS_RANDOM.VALUE)  
								WHERE ROWNUM = 1)
		WHERE "programmer_id" = :old.id;
	END;
/

-- Předvedení
SELECT "programmer_id" FROM "module" WHERE "name" = "MyModule"
DELETE FROM "user" WHERE "last_name" = "Programator"
SELECT "programmer_id" FROM "module" WHERE "name" = "MyModule"


----------------------------- EXPLAIN PLAN ------------------------------------
-- explain dotaz na jména uživatelů a počet ticketů podaných někým s tímto jménem
-- nedává smysl, ale jako příklad poslouží
EXPLAIN PLAN FOR
SELECT "first_name"."u", COUNT("t".*) 
FROM "user" "u", "ticket" "t"
WHERE "u"."id" = "t"."user_id"
GROUP BY "first_name";
-- výpis
SELECT * FROM TABLE(dbms_xplan.display());
-- index pro jména (seřazení podle jmen a rychlejší vyhledávání v nich
CREATE INDEX first_name_index ON user (first_name);
-- druhý pokus
EXPLAIN PLAN OR
SELECT "first_name"."u", COUNT("t".*) 
FROM "user" "u", "ticket" "t"
WHERE "u"."id" = "t"."user_id"
GROUP BY "first_name";

SELECT * FROM TABLE(dbms_xplan.display());

DROP INDEX first_name_index;


------------------------------ PROCEDURE --------------------------------------

-- Procedura vypíše přehled celkově zadaných ticketů, chyb v nich a celkový počet uživatelů
CREATE OR REPLACE PROCEDURE user_bug_ticket_count_summary AS
BEGIN	
	avg_bug_count_on_user NUMBER;
	avg_ticket_count_on_user NUMBER;
	avg_bug_count_on_ticket NUMBER;
	num_tickets NUMBER;
	num_bugs NUMBER;
	num_users NUMBER;
	
	BEGIN
		SELECT COUNT(*) INTO num_users FROM "user";
		SELECT COUNT(*) INTO num_bugs FROM "bug";
		SELECT COUNT(*) INTO num_tickets FROM "ticket";
		
		avg_bug_count_on_user := num_bugs / num_users;
		avg_bug_count_on_ticket := num_bugs / num_tickets;
		avg_ticket_count_on_user := num_tickets / num_users;
		
		DBMS_OUTPUT.put_line('there are total of ' || num_users || ' users, ' || num_tickets || ' tickets and ' || num_bugs || 'bugs');
		DBMS_OUTPUT.put_line('its ' || avg_bug_count_on_user || ' bugs and ' || avg_ticket_count_on_user || ' tickets on 1 user. That means ' || avg_bug_count_on_ticket || ' average bugs in 1 ticket.');
		
		EXCEPTION WHEN ZERO_DIVIDE THEN
		BEGIN
		IF num_users = 0 THEN
			DBMS_OUTPUT.put_line('There are no record of users!');
		ELSIF num_tickets = 0 THEN
			DBMS_OUTPUT.put_line('There are no record of any issues!');
		END IF;
		END;
	END;
END;
/
-- příklad spuštění
EXECUTE user_bug_ticket_count_summary();

-- Procedura počítá, kolik celkově uživatelů ovládá daný jazyk
CREATE OR REPLACE PROCEDURE language_knowledge (lang_name IN VARCHAR) AS
BEGIN
	DECLARE CURSOR cursor_languages is
	SELECT "UL"."language_id"
	FROM  "user_language" "UL";
	language_id "user_language"."language_id"%TYPE;
	language_id_arg "user_language"."language_id"%TYPE
	target_users NUMBER;
	all_users NUMBER;
	BEGIN
		SELECT COUNT(*) INTO all_users FROM "user";
		target_users := 0;
		SELECT "id" INTO "language_id_arg" FROM "language" WHERE "name" = lang_name;
		OPEN cursor_languages;
		LOOP
			FETCH cursor_users INTO language_id;
			EXIT WHEN cursor_users%NOTFOUND;
			if language_id = language_id_arg THEN
				target_users := target_users + 1;
			END IF;
		END LOOP;
		CLOSE cursor_languages;
		DBMS_OUTPUT.put_line('Language ' || lang_name || ' knowns ' || target_users || ' users out of ' || all_users || ' users total');
		EXCEPTION WHEN NO_DATA_FOUND THEN
		BEGIN
			DBMS_OUTPUT.put_line('This name of language was not found!' );
		END;
	END;
END;
/
-- příklad spuštění
EXECUTE language_knowledge("Java");


-------------------------------- PRÁVA ----------------------------------------

GRANT ALL ON "ticket"      	TO xhoraz02;
GRANT ALL ON "module"     	TO xhoraz02;
GRANT ALL ON "language"   	TO xhoraz02;
GRANT ALL ON "bug"        	TO xhoraz02;
GRANT ALL ON "patch" 		TO xhoraz02;
GRANT ALL ON "user" 		TO xhoraz02;
GRANT ALL ON "programmer" 	TO xhoraz02;
GRANT ALL ON "ticket_bug"   TO xhoraz02;
GRANT ALL ON "module_bug" 	TO xhoraz02;
GRANT ALL ON "user_language" TO xhoraz02;


GRANT EXECUTE ON user_bug_ticket_count_summary TO xhoraz02;
GRANT EXECUTE ON language_knowledge TO xhoraz02;


--------------------------- MATERIALIZED VIEW ----------------------------------

-- pohled na všechny uživatele a počet jejich ticketů
CREATE MATERIALIZED VIEW user_ticket_count AS
SELECT "u"."first_name", "u"."last_name", count("t"."user_id") FROM "user" "u"
RIGHT JOIN "ticket" "t" on "u"."id" = "t"."user_id";


GRANT ALL ON user_ticket_count TO xhoraz02;

DROP MATERIALIZED VIEW user_ticket_count;
