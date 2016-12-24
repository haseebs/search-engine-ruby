CREATE USER 'test'@'localhost' IDENTIFIED BY '12345';
CREATE DATABASE wikiDatabase;
GRANT ALL PRIVILEGES ON wikiDatabase.* TO 'test'@'localhost';
