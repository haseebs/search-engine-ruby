CREATE TABLE docRefs (
  docID INT PRIMARY KEY,
  title varchar(250),
  wordCount INT
);

CREATE INDEX title_index ON docRefs(title);
