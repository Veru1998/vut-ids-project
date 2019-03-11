CREATE TABLE `bug`
(
  `id`          int(11)      NOT NULL,
  `description` varchar(150) NOT NULL,
  `severity`    int(11) DEFAULT NULL,
  `moduleid`    int(11)      NOT NULL,
  `patchid`     int(11) DEFAULT NULL
);

CREATE TABLE `languages`
(
  `id`   int(11)     NOT NULL,
  `name` varchar(20) NOT NULL
);

CREATE TABLE `module`
(
  `id`         int(11)     NOT NULL,
  `name`       varchar(20) NOT NULL,
  `languageid` int(11)     NOT NULL,
  `userid`     int(11)     NOT NULL
);

CREATE TABLE `patch`
(
  `id`          int(11)      NOT NULL,
  `created`     datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deployed`    datetime              DEFAULT NULL,
  `description` varchar(150) NOT NULL,
  `authorid`    int(11)      NOT NULL,
  `deployerid`  int(11)      NOT NULL
);

CREATE TABLE `ticket`
(
  `id`          int(11)      NOT NULL,
  `description` varchar(120) NOT NULL,
  `userid`      int(11)      NOT NULL,
  `solverid`    int(11) DEFAULT NULL
);

CREATE TABLE `ticket_bug`
(
  `id`       int(11) NOT NULL,
  `ticketid` int(11) NOT NULL,
  `bugid`    int(11) NOT NULL
);

CREATE TABLE `user`
(
  `id`         int(11)     NOT NULL,
  `login`      varchar(20) NOT NULL,
  `password`   varchar(20) NOT NULL,
  `name`       varchar(20) NOT NULL,
  `surname`    varchar(20) NOT NULL,
  `created`    datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `birthday`   date                 DEFAULT NULL,
  `contact`    varchar(14)          DEFAULT NULL,
  `address`    varchar(20)          DEFAULT NULL,
  `programmer` tinyint(1)  NOT NULL DEFAULT '0',
  `admin`      tinyint(1)  NOT NULL DEFAULT '0',
  `rodcis`     int(11)              DEFAULT NULL,
  `device`     int(11)              DEFAULT NULL
);

INSERT INTO `user` (`id`, `login`, `password`, `name`, `surname`, `created`, `birthday`, `contact`, `address`,
                    `programmer`, `admin`, `rodcis`, `device`)
VALUES
(1, 'user', 'user', 'Uzivatel', 'Obecny', '2018-11-28 15:29:04', '2018-12-01', '+420606', NULL, 0, 0, 123, 123456),
(2, 'prog', 'prog', 'Programator', 'Veliky', '2018-11-28 15:29:04', NULL, NULL, NULL, 1, 0, NULL, NULL),
(3, 'admin', 'admin', 'Administrator', 'Uzasny', '2018-11-28 15:29:23', NULL, NULL, NULL, 0, 1, NULL, NULL);

CREATE TABLE `user_language`
(
  `id`         int(11) NOT NULL,
  `userid`     int(11) NOT NULL,
  `languageid` int(11) NOT NULL
);

ALTER TABLE `bug`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `languages`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `module`
  ADD KEY `id` (`id`);

ALTER TABLE `patch`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `ticket`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `ticket_bug`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `user_language`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `bug`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `languages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `module`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `patch`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `ticket`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `ticket_bug`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,
  AUTO_INCREMENT = 3;

ALTER TABLE `user_language`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;
