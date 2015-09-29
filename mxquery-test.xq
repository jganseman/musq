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
    
</musq:all-tests>
