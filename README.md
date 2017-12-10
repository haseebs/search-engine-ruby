# Simple Wikipedia Search Engine
This repo contains the implementation of [The Anatomy of a Large-Scale Hypertextual Web Search Engine](http://infolab.stanford.edu/~backrub/google.html) written in Ruby and MySQL
## Recommended OS:
Any Linux distribution for entire functionality

## Mini Dataset:
Dataset can be obtained from wikimedia data dumps.
We used the file simplewiki-20161220-pages-meta-current.xml

## Order of execution
1. Execute sqlCode/createUserAndDB.sql
2. Execute the remaining .sql scripts in any order
3. Execute rubyCode/repositoryGenerator.rb
4. Execute rubyCode/wordIDGenerator.rb
5. Execute rubyCode/generateDocIdToTitle.rb
6. Execute rubyCode/forwardIndexGenerator.rb    	<-Creates the forward Index
7. Execute rubyCode/invertedIndexGenerator.rb   	<-Creates the inverted Index

## Notes
* It is recommended to use Linux based OS because some functionality is OS dependent.

* Ruby and MySQL must be set up in the system prior to executing the code.

* The server is written in sinatra
