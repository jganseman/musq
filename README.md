# mxquery
XQuery library for MusicXML repositories

### About

This repository will contain files related to the paper:

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
- A running instance of eXist-db (http://exist-db.org). The initial paper was written using eXist 1.2.0-rev7233 . The files uploaded here have been tested to work with eXist 1.4.3 . The latest stable release of eXist, at the moment of writing, is 2.2. 
- A set of MusicXML files. The online database mentioned in the paper, Wikifonia, does not exist anymore. See http://www.musicxml.com/music-in-musicxml/ for possible alternatives, or convert it from a database in another format.

### Contents
- wikifonia2008.zip : Zip file containing the data used for the initial paper. This is a dump of the Wikifonia database at 31 march 2008 in a single file called wikifonia-formatted.xml . This file is provided for reasons of research reproducibility. It is password-protected; the password is equal to the filename without extension. It can be loaded into eXist to run the queries in the following files:
- mxqueries2008.xq : List of queries used for the initial paper. This is a single file, the query to be used needs to be uncommented.
- mxqueries2008b.xq : This file contains an additional query that had not been finished at the time, but is now.
