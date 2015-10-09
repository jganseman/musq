xquery version "3.0";

import module namespace musq = "https://github.com/jganseman/musq" at "musq.xqm";

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
    
    <musq:test-findrhythm>
        {
            musq:FindRhythm($entiredb[.//movement-title = 'Blue Danube'], (4, 4, 4, 12) )
        }
    </musq:test-findrhythm> 
    
    <musq:test-findmelody>
        {
            musq:FindMelody($entiredb[.//movement-title = 'Blue Danube'], (4, 3, 0) )
        }
    </musq:test-findmelody> 
    
    <musq:test-permute>
        {
            for $i in musq:Permute(("A","B","C","D"))
            return $i
        }
        {
            let $s := subsequence($entiredb[.//movement-title = 'Blue Danube']//pitch, 1, 3)
            return musq:Permute($s)
        }
    </musq:test-permute>
    
    <musq:test-findchord>
        {
            musq:FindChord($entiredb[.//movement-title = 'Blue Danube'], (4, 3) )
        }
    </musq:test-findchord>
    
    <musq:test-findmotive>
        {
            musq:FindMotive($entiredb[.//movement-title = 'Blue Danube'], (4, 4, 4, 12), (4, 3, 0) )
        }
    </musq:test-findmotive>

</musq:all-tests>
