# mxquery
XQuery library for MusicXML databases

### About

This repository contains files related to the paper:

Joachim Ganseman, Paul Scheunders, and Wim D’haes: "Using xquery on musicxml databases for musicological analysis". In *Proc. 9th International Conference on Music Information Retrieval (ISMIR 2008)*, pages 433–438, Philadelphia, USA, September 2008. Available online: http://ismir2008.ismir.net/papers/ISMIR2008_217.pdf

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
- A running instance of *eXist-db* (http://exist-db.org). The initial paper was written using *eXist 1.2.0-rev7233* . The 2008 files uploaded here have been tested to work with *eXist 1.4.3* . The files in the main directory are reworked versions of those queries, tested to work with *eXist 2.2*.
- A set of MusicXML files. The online database mentioned in the paper, Wikifonia, does not exist anymore. See http://www.musicxml.com/music-in-musicxml/ for possible alternatives, or convert it from a database in another format. 

### Contents
- mxquery.xqm : reworked version of the 2008 queries in the form of an XQuery 3.0 module, as a true function library with its own namespace. Some of the functions are slightly more generic now, and some performance improvements have been implemented. *xqDoc*-style comments have been added. 
- mxquery-test : a few test routines to verify that the XQuery function library works as intended. Tested to work with *eXist 2.2* and the May 2010 Wikifonia database.
- Folder 'data' : 3 zip files with Wikifonia data. These files are provided for reasons of research reproducibility. They are password-protected; the password is equal to the filename without extension. This data can be imported into *eXist* to run the queries in the other files.
  - wikifonia2008.zip : Dump of the Wikifonia database, made on 31 march 2008, containing contains 220 scores joined together in a single file. This is the data used for the original ISMIR 2008 paper. 
  - wikifonia2009.zip : Dump of the Wikifonia database, made on 19 June 2009, containing 1381 files.
  - wikifonia2010.zip : Dump of the Wikifonia database, made on 03 May 2010, containing 2265 files.
- Folder '2008' : original files used in the experiments leading up to the ISMIR 2008 paper. They are somewhat cleaned up, but should be considered legacy and are not meant to be used anymore.
  - mxqueries2008.xq : List of queries in one single file, the query to be used needs to be uncommented. 
  - mxqueries2008b.xq : Contains an additional query that had not been finished at the time, but is now.

### Future work
- I'd love to see the list of queries expanded, e.g. including more of the functionality that is present in the *HumDrum* or *music21* toolkits. Contributions are most welcomed!
- It'd be great to have a version for MEI-encoded documents as well

### Thanks
- Michael Good for the code to convert MusicXML pitch elements to MIDI note numbers, from  http://michaelgood.info/publications/music/musicxml-in-practice-issues-in-translation-and-analysis/ 
- Chris Wallace for an improved version of that code, kindly borrowed from his XQuery Wikibook chapter on MusicXML and Arduino: https://en.wikibooks.org/wiki/XQuery/MusicXML_to_Arduino
- All authors of referenced papers in http://ismir2008.ismir.net/papers/ISMIR2008_217.pdf 
