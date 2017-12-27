# Simple Wikipedia Search Engine
This implementation of a search engine similar to [The Anatomy of a Large-Scale Hypertextual Web Search Engine](http://infolab.stanford.edu/~backrub/google.html) written in Ruby and MySQL
## Recommended OS:
Preferrably Ubuntu 16.04 or any other compatible debian based distro.

## Mini Dataset:
Dataset can be obtained from wikimedia data dumps.
We used the file simplewiki-20161220-pages-meta-current.xml

## How to run
A bash script for executing all these files is not provided as there a various different ways of setting up ruby, and the script may not work properly.
1. Execute sqlCode/createUserAndDB.sql
2. Execute the remaining .sql scripts in any order
3. Execute rubyCode/repositoryGenerator.rb
4. Execute rubyCode/wordIDGenerator.rb
5. Execute rubyCode/generateDocIdToTitle.rb
6. Execute rubyCode/forwardIndexGenerator.rb    	<-Creates the forward Index
7. Execute rubyCode/invertedIndexGenerator.rb   	<-Creates the inverted Index
8. Execute rubyCode/server.rb                     <-Starts the server

## Notes
* It is recommended to use Linux based OS because some functionality is OS dependent.

* Ruby and MySQL must be set up in the system prior to executing the code.

* The server is written in sinatra

* Inverted Index is indexed by wordID to ensure quick retrieval. However
this index can be dropped and created again when inserting large amounts of 
data to ensure quick insertion.

* The creation of Forward Index for entire simple wikipedia took 26 minutes and < 1gb of ram (screenshot of profiler in folder)
This can be further optimized. However forward indexing is a one-time process, unless the dataset is expanded.
