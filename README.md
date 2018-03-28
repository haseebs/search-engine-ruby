# Simple Wikipedia Search Engine
WikiHunt is made as a search engine for [Simple Wikipedia](https://simple.wikipedia.org/wiki/Main_Page) similar to [The Anatomy of a Large-Scale Hypertextual Web Search Engine](http://infolab.stanford.edu/~backrub/google.html) written in Ruby and MySQL.

## How to run
1. Execute sqlCode/createUserAndDB.sql
2. Execute the remaining .sql scripts in any order
3. Execute rubyCode/repositoryGenerator.rb
4. Execute rubyCode/wordIDGenerator.rb
5. Execute rubyCode/generateDocIdToTitle.rb
6. Execute rubyCode/forwardIndexGenerator.rb    	<-Creates the forward Index
7. Execute rubyCode/invertedIndexGenerator.rb   	<-Creates the inverted Index
8. Execute rubyCode/server.rb                     <-Starts the server

## Detailed Description
### Parsing
The data was obtained in form of a single XML file in which each page is
separated by <page> tag. This file is read by repositoryGenerator.rb
which uses Nokogiri gem for parsing the XML. The content of each page
is separated and stored in files and named as
Page_id-Page_title-Number_of_words.

### Generation of Lexicon
Afterwards, a Lexicon is generated as a table in MySQL database. We
iterate through each page in the repository and using regex, we:
1. Split the content string based on any whitespace or non-word character
2. Select the elements from the resulting array that consist of word
characters.
3. These are pushed into Lexicon with Insert Ignore, which automatically
   rejects duplicate word entries, and each word is mapped to a unique
   word ID.

### Generation of Forward Index
For the generation of forward index, we follow the following steps:
1. Load the entire Lexicon from the database into RAM. It is usually
   small so it can be loaded entirely into the RAM easily. This is done
   because otherwise we would have to send queries for each word
   separately, and if we do that, it would take us 10-30 weeks longer to
   complete the generation of forward index.

2. We iterate over each page, and in each page, we iterate over all the
   words. Each word's hit type is determined an stored as the respective
   hit in array. Each hit is encoded into 32-bit integer using bitwise
   operators. A hit contains information about the capitalization,
   importance and the position of the word.
   
3. The array is then parsed and converted into a MySQL file which contains
   multiple MySQL statements, each containing 5000 row entries. This was
   done instead of using the mysql library because generation of forward
   index by executing the generated mySQL file resulted in creation of
   forward index 80 times faster than the library method. This is believed
   to be because multiple hits are appended to be inserted as one query as
   compared to a separate query for each new hit.
   
### Generation of Inverted Index
For the generation of inverted index, we follow the following steps:  
1. Get the max Word ID from the database.
2. Add index on Word ID in the forward index to ensure faster retrieval
3. For each Word ID, retrieve the hits containing it.
4. Generate the mySQL file for inverted index
5. Drop index from the inverted index and the forward index before executing
   the mySQL file.
   
### Search Process
When a query arrives, it is first determined whether the query is a single word
or a multi-word query, then it is processed accordingly:
#### Single Word Search
1. We retrieve wordID of the word
2. Hit information is extracted for that word
3. IR score is calculated by dot product of Hit vector with Typeweight vector.
4. Top 100 results are returned when sorted by IR scores.

#### Multi-Word Search
1. We retrieve wordID of the each word
2. Hit information is extracted for each word
3. Only those documents are kept which have all the query words.
4. Proximity vector (contains distance between the query words)
and Hit vectors dot products with Proximity-weight vector
and Typeweight vector are calculated respectively.
3. IR score is calculated from the dot product of resulting proximity and type
weights.
4. Top 100 results are returned when sorted by IR scores.

## Notes
* It is recommended to use Linux based OS because some functionality is OS dependent.
* Ruby and MySQL must be set up in the system prior to executing the code.
* The server is written in sinatra
* Inverted Index is indexed by wordID to ensure quick retrieval. However
this index can be dropped and created again when inserting large amounts of 
data to ensure quick insertion.
* The creation of Forward Index for entire simple wikipedia took 26 minutes and < 1gb of ram (screenshot of profiler in folder)
This can be further optimized. However forward indexing is a one-time process, unless the dataset is expanded.

