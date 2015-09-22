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
- A running instance of eXist-db (http://exist-db.org). The initial paper was written using eXist 1.2.0-rev7233 . The latest stable release of eXist, at the moment of writing, is 2.2. 
- A set of MusicXML files. The online database mentioned in the paper, Wikifonia, does not exist anymore. See http://www.musicxml.com/music-in-musicxml/ for possible alternatives, or convert it from a database in another format.
