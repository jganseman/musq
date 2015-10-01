xquery version "3.0";

import module namespace musq = "https://github.com/jganseman/mxquery" at "mxquery.xqm";

declare variable $entiredb := collection("/db/wikifonia");
declare variable $partofdb := $entiredb[contains (.//movement-title, 'Night')];

<musq:all-tests>
 
    <musq:test-gettitle>
        {
            musq:GetTitle($partofdb)
        }
    </musq:test-gettitle>
    
    <musq:test-getversion>
        {
            musq:GetVersion($partofdb)
        }
    </musq:test-getversion>
    
    <musq:test-notecount>
        {
            musq:NoteCount($partofdb, true())
        }
    </musq:test-notecount>
    
    <musq:test-smallestscore>
        {
            musq:SmallestScore($entiredb, true())
        }
    </musq:test-smallestscore>
   
    <musq:test-scoreswithout>
        {
            musq:ScoresWithout($partofdb, "rest")//movement-title
        }
    </musq:test-scoreswithout>
    
    <musq:test-partcount>
        {
            musq:MultiParts($entiredb)
        }
    </musq:test-partcount>
    
    <musq:test-measurecount>
        {
            musq:MeasureCount($partofdb)
        }
    </musq:test-measurecount>
    
    <musq:test-duplicatetitles>
        {
            musq:DuplicateTitles($partofdb)
        }
    </musq:test-duplicatetitles> 
    
    <musq:test-duplicateauthors>
        {
            musq:DuplicateCreators($partofdb, "composer" )
        }
    </musq:test-duplicateauthors> 
    
    <musq:test-scoresinkey>
        {
            musq:ScoresInKey($partofdb, 1, () )//movement-title
        }
    </musq:test-scoresinkey>   
    
    <musq:test-timestats>
        {
            musq:TimeStats($partofdb)
        }
    </musq:test-timestats> 
    
    <musq:test-keystats>
        {
            musq:KeyStats($partofdb)
        }
    </musq:test-keystats> 
    
    <musq:test-lyriclibrary>
        {
            musq:LyricLibrary($partofdb)
        }
    </musq:test-lyriclibrary> 
    
</musq:all-tests>
