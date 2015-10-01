xquery version "3.0";

(: ~
 : XQuery Function Library for use with MusicXML files 
 : Version 1.1 : working with eXist 2.2 and wrapped in a proper module.
 : @author Joachim Ganseman
:)

declare namespace musq="https://github.com/jganseman/mxquery";


(: ~
 : Helper function to compute MIDI pitches
 : Borrowed from Chris Wallace's XQuery WikiBook 
 : @param $thispitch MusicXML pitch element
 : @return an integer representing the corresponding MIDI pitch 
:)
declare variable $musq:step2offset := (9,11,0,2,4,5,7);
declare function musq:MidiNote($thispitch as element(pitch) ) as xs:integer {
  let $step := $thispitch/step
  let $alter :=
    if (empty($thispitch/alter)) then 0
    else xs:integer($thispitch/alter)
  let $octave := xs:integer($thispitch/octave)
  let $pitchstep := $musq:step2offset [ string-to-codepoints($step) - 64]
  return 12 * ($octave + 1) + $pitchstep + $alter
} ;


(: ~
 : Exctract the title elements from one or more scores 
 : @param $scores a (list of) score element(s), partwise or timewise 
 : @return a MusicXML <movement-title> element
:)
declare function musq:GetTitle($scores as node()* ) as node()* {
    $scores//movement-title
} ;


(: ~
 : Return the version of a score 
 : @param $scores a (list of) score(s), partwise or timewise
 : @return a <musq:mxmlversion> element with version info inside
:)
declare function musq:GetVersion($scores as node()* ) as node()* {
    for $score in $scores
    let $vers :=
        if (empty($score//score-timewise))
        then $score//score-partwise/@version
        else $score//score-timewise/@version
    return <musq:mxmlversion>{string($vers)}</musq:mxmlversion>        
} ;


(: ~
 : Get the note count of all songs, order results descending
 : @param scores a (list of) scores, partwise or timewise
 : @param increst when rests are to be counted as notes, set true(), else false()
 : @return a (list of) <musq:notecount> elements, ordered from high to low
:)
declare function musq:NoteCount($scores as node()*, $increst as xs:boolean) as node()* {
    for $score in $scores
    let $title := $score//movement-title
    let $j := 
        if ($increst)
        then count($score//note)
        else count($score//note[empty(./rest)])
    order by $j descending
    return <musq:notecount>{$title}
            <musq:total>{$j}</musq:total>
        </musq:notecount>
} ;


(: ~ 
 : Return the score with the fewest notes
 : @param scores a (list of) score(s), partwise or timewise
 : @param increst when rests are to be counted as notes, set true(), else false()
 : @return the score(s) with the fewest notes,
:)
declare function musq:SmallestScore($scores as node()*, $increst as xs:boolean) as node()* {
    let $allcounts := (
        for $score in $scores return 
            if ($increst)
            then count ($score//note)
            else count ($score//note[empty(./rest)])
        )
    for $index in index-of($allcounts, min($allcounts))
    return $scores[$index]
    (: note: indexing an array with a sequence seems to be a problematic at the moment :)
} ;


(: ~
 : Return scores that do not contain a certain element
 : @param scores a (list of) score(s), partwise or timewise
 : @param myname the element or attribute name that should not be present.
 : @return score(s) that do not contain the given element
:)
declare function musq:ScoresWithout($scores as node()*, $myname as xs:string) as node()* {
    (: we're doing this by element or attribute name comparison, 
    since passing dummy nodes as parameters seems not to work well :)
    let $allcounts := (
        for $score in $scores
        return count($score//*[./name() = $myname]) + count($score//@*[./name() = $myname])   
        )
    (: there seem to be some problems with having integer sequences as array argument? :)
    (:   return $scores[ index-of($allcounts, min($allcounts)) treat as xs:integer* ]   :)
    for $index in index-of($allcounts, 0)
    return $scores[$index]
} ;


(: ~
 : Return scores that have multiple parts
 : @param scores a (list of) score(s), partwise or timewise
 : @return score(s) that have multiple parts
:)
declare function musq:MultiParts($scores as node()*) as node()* {
    for $score in $scores[ count(.//score-part) gt 1 ]
    let $title := $score//movement-title
    return <musq:partcount>{$title}
        <musq:total>{count($score//score-part)}</musq:total>
        </musq:partcount>
} ;


(: ~
 : Get the measure count of all songs, order results descending
 : @param scores a (list of) scores, partwise or timewise
 : @return a (list of) <musq:measurecount> elements, ordered from high to low
:)
declare function musq:MeasureCount($scores as node()*) as node()* {
    for $score in $scores
    let $title := $score//movement-title
    let $j := count($score//measure) div count($score//score-part)
    order by $j descending
    return <musq:measurecount>{$title}
            <musq:total>{$j}</musq:total>
        </musq:measurecount>
} ;


(: ~
 : Find scores with duplicate titles
 : @param scores a (list of) scores, partwise or timewise
 : @return a (list of) <musq:duplicatetitles> elements, ordered from high to low
:)
declare function musq:DuplicateTitles($scores as node()*) as node()* {
    for $title in distinct-values(($scores)//movement-title/text())
    let $items := $scores//movement-title[text() = $title]
    let $total := count($items)
    order by $total descending, $title
    return (<musq:duplicatetitles>{$items[1]}
            <musq:total>{$total}</musq:total>
        </musq:duplicatetitles>)[$total > 1]
} ;


(: ~
 : Find multiple occurring authors
 : @param scores a (list of) score(s), partwise or timewise
 : @param type optional, a string specifying a function ("composer", "poet", ... ).
 : If defined, the search is restricted to names in this particular function.
 : @return a list of <musq:duplicatecreators> elements, ordered from high to low
 : If $type was not defined, only one of the potential function terms of an author is returned as type argument!
:)
declare function musq:DuplicateCreators($scores as node()*, $type as xs:string?) as node()* {
    for $author in distinct-values(($scores)//creator/lower-case(text()))
    let $items := if (empty($type) or $type = "")
        then $scores//creator[lower-case(text()) = $author]
        else $scores//creator[@type = lower-case($type)][lower-case(text()) = $author]
    let $total := count ($items)
    order by $total descending, $author
    return (<musq:duplicatecreators>{$items[1]}
            <musq:total>{$total}</musq:total>
        </musq:duplicatecreators>)[$total > 1]
    (: note: if $relator was not present, multiple creator types count towards the result but only one type is displayed! :)
} ;


(: ~
 : Find all pieces in a specific key
 : @param scores a (list of) score(s), partwise or timewise
 : @param fifths how many flats (negative nr) or sharps (positive nr) on the stave
 : @param mode the modality, "major" or "minor". When empty, returns results in any mode
 : @return titles of all score(s) in this particular key
 :)
declare function musq:ScoresInKey($scores as node()*, $fifths as xs:integer, $mode as xs:string?) as node()* {
    if (empty($mode) or $mode = "")
    then $scores//key[xs:integer(fifths/text()) = $fifths]/ancestor::*[name() = "score-partwise" or name() = "score-timewise"]
    else $scores//key[xs:integer(fifths/text()) = $fifths][mode/text() = $mode]/ancestor::*[name() = "score-partwise" or name() = "score-timewise"]
} ;


(: ~
 : Time signature statistics
 : @param scores a (list of) score(s), partwise or timewise
 : @return a (list of) <musq:TimeStats> element containing statistics on all time signatures occuring in $scores
:)
declare function musq:TimeStats($scores as node()*) as node()* {
    let $t := count($scores//time)
    for $i in distinct-values($scores//beats)
    for $j in distinct-values($scores//beat-type)
    let $c := count($scores//time[beats = $i][beat-type = $j])
    let $p := $c div $t * 100
    order by $p descending
    return (<musq:TimeStats>
        <time>
            <beats>{$i}</beats>
            <beat-type>{$j}</beat-type>
        </time>
        <musq:count>{$c}</musq:count>
        <musq:percentage>{$p}</musq:percentage>
    </musq:TimeStats>)[$c > 0]
} ;


(: ~
 : Key signature statistics
 : @param scores a (list of) score(s), partwise or timewise
 : @return a (list of) <musq:KeyStats> element containing statistics on all key signatures occuring in $scores
 : Note: currently does not support key signatures without mode specification
:)
declare function musq:KeyStats($scores as node()*) as node()* {
    let $t := count($scores//key)
    for $i in distinct-values($scores//fifths)
    let $cnm := count($scores//key[fifths = $i][empty(./mode)])
    let $pnm := $cnm div $t * 100
        (: TODO incorporate keys without mode :)
    for $j in distinct-values($scores//mode) 
    let $c := count($scores//key[fifths = $i][mode = $j])
    let $p := $c div $t * 100
    
    order by $p descending
    return (<musq:KeyStats>
        <key>
            <fifths>{$i}</fifths>
            <mode>{$j}</mode>
        </key>
        <musq:count>{$c}</musq:count>
        <musq:percentage>{$p}</musq:percentage>
    </musq:KeyStats>)[$c > 0]

} ;


(: ~
 : Create library of lyrics
 : @param scores a (list of) score(s), only partwise scores are supported for the moment
 : @return a <musq:library> element containing concatenated lyrics for every verse of every score
:)
declare function musq:LyricLibrary($scores as node()*) as node()* {
<musq:LyricLibrary>
    {
    for $i in $scores//score-partwise
    let $tit := $i//movement-title
    let $aut := $i//creator[not(empty(./text()))]
    return
    <musq:Song>{$tit}{$aut}
        {
        	let $lyr := $i//lyric						(: all lyrics :)
        	let $nrv := if(empty($lyr/@number)) then 1 else xs:integer(max($lyr/@number))			(: nr of verses :)
        											(: special case: only one verse, then no number argument present :)
        	for $cur in (1 to $nrv)			(: current verse. watch it: if $nrv=1, then no number argument needs to be present :)
        	let $ver := $lyr[ if($nrv gt 1) then @number = $cur else true() ]/text		(: all <text> elements :)
        	let $s := string-join( for $syl in $ver return concat($syl/text(), if ($syl/../syllabic = ('begin','middle')) then '' else ' '), '')
        	return 
        		<musq:Lyric>{attribute{"verse"}{$cur}}{$s}</musq:Lyric> [not(empty($lyr))]		(: only if there are lyrics :)
        }
    </musq:Song>
    }
</musq:LyricLibrary>
} ;


false() (: eXide grumbles when there's not at least one XPath expression in this file... :)