create table forwardIndex
(
  docID int,
  wordID int,
  nHits  tinyint unsigned,
  hit smallint unsigned
);

create table invertedIndex
(
  wordID int,
  nDocs int,
  docID int,
  nHits tinyint unsigned,
  hit smallint unsigned
);



