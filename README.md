# mxquery
XQuery library for MusicXML repositories

### About

This repository contains files related to the paper:

Joachim Ganseman, Paul Scheunders, and Wim D’haes. Using xquery on musicxml databases for musicological analysis. In Proc. 9th International Conference on Music Information Retrieval (ISMIR 2008), pages 433–438, Philadelphia, USA, September 2008. Available online: http://ismir2008.ismir.net/papers/ISMIR2008_217.pdf

BibTeX:
```latex
@INPROCEEDINGS{Ganseman2008a,
  author = {Ganseman, Joachim and Scheunders, Paul and D'haes, Wim},
  title = {Using XQuery on MusicXML Databases for Musicological Analysis},
  booktitle = {Proc. 9th International Conference on Music Information Retrieval (ISMIR 2008)},
  year = {2008},
  pages = {433-438},
  address = {Philadelphia, USA},
  month = {September},
  editor = {Dannenberg, Roger and Lemstr\"om, Kjell and Tindale, Adam},  
  isbn = {0-615-24849-7}
}
  ```

### Requirements
- A running instance of eXist-db (http://exist-db.org). The initial paper was written using eXist 1.2.0-rev7233 . The 2008 files uploaded here have been tested to work with eXist 1.4.3 . The files in the main directory are reworked versions of those queries, tested to work with the eXist 2.2.
- A set of MusicXML files. The online database mentioned in the paper, Wikifonia, does not exist anymore. See http://www.musicxml.com/music-in-musicxml/ for possible alternatives, or convert it from a database in another format. 

### Contents
- Folder '2008'
  - mxqueries2008.xq : List of queries used for the initial ISMIR 2008 paper. This is a single file, the query to be used needs to be uncommented. 
  - mxqueries2008b.xq : This file contains an additional query that had not been finished at the time, but is now.
- Folder 'data' : 3 zip files with Wikifonia data. These files are provided for reasons of research reproducibility. They are password-protected; the password is equal to the filename without extension. This data can be loaded into eXist to run the queries in the files above.
  - wikifonia2008.zip : Dump of the Wikifonia database, made on 31 march 2008, containing contains 220 scores joined together in a single file. This is the data used for the original ISMIR 2008 paper. 
  - wikifonia2009.zip : Dump of the Wikifonia database, made on 19 June 2009, containing 1381 files.
  - wikifonia2010.zip : Dump of the Wikifonia database, made on 03 May 2010, containing 2265 files.
- mxquery.xqm : reworked version of the 2008 queries in the form of an XQuery 3.0 module, as a true function library with its own namespace. Some genericity has been added, too. Tested to work with eXist 2.2 and the May 2010 Wikifonia data.
- mxquery-test : a few test routines to verify that the XQuery function library works as intended.
