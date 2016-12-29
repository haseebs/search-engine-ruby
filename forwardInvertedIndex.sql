create table forwardIndex
(
  docID int,
  wordID int,
  nHits  smallint unsigned,
  hit smallint unsigned
);

create table invertedIndex
(
  wordID int,
  nDocs int,
  docID int,
  nHits smallint unsigned,
  hit smallint unsigned
);



