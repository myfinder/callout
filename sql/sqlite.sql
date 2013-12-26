CREATE TABLE member (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    api_id       INTEGER      NOT NULL,
    name         VARCHAR(255) NOT NULL,
    mention_name VARCHAR(255) NOT NULL,
    email        VARCHAR(255) NOT NULL,
    photo_url    VARCHAR(255) DEFAULT NULL,
    group_id     INTEGER      NOT NULL,
    modified     datetime default null
);
CREATE INDEX name   ON member(name);
CREATE INDEX api_id ON member(api_id);

CREATE TABLE syllabary (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    name         VARCHAR(1)   NOT NULL
);

CREATE TABLE syllabary_member (
    syllabary_id INTEGER      NOT NULL,
    member_id    INTEGER      NOT NULL UNIQUE,
    PRIMARY KEY (syllabary_id,member_id)
);
