xquery version "3.0";

(: ~
 : XQuery Function Library for use with MusicXML files 
 : Version 0.1 : working with eXist 2.2 and wrapped in a proper module with a namespace.
 : @author Joachim Ganseman
:)

declare namespace musq="https://github.com/jganseman/musq";


(: ~
 : Helper function to compute MIDI pitches
 : Borrowed from Chris Wallace's XQuery WikiBook 
 : @param $pitches a (list of) MusicXML pitch element(s)
 : @return a (list of) integer(s) representing the corresponding MIDI pitch 
:)
declare variable $musq:step2offset := (9,11,0,2,4,5,7);
declare function musq:MidiNote($pitches as element(pitch)* ) as xs:integer* {
    for $thispitch in $pitches
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
 : @return a (list of) <musq:timestats> element containing statistics on all time signatures occuring in $scores
:)
declare function musq:TimeStats($scores as node()*) as node()* {
    let $t := count($scores//time)
    for $i in distinct-values($scores//beats)
    for $j in distinct-values($scores//beat-type)
    let $c := count($scores//time[beats = $i][beat-type = $j])
    let $p := $c div $t * 100
    order by $p descending
    return (<musq:timestats>
        <time>
            <beats>{$i}</beats>
            <beat-type>{$j}</beat-type>
        </time>
        <musq:count>{$c}</musq:count>
        <musq:percentage>{$p}</musq:percentage>
    </musq:timestats>)[$c > 0]
} ;


(: ~
 : Key signature statistics
 : @param scores a (list of) score(s), partwise or timewise
 : @return a (list of) <musq:keystats> element containing statistics on all key signatures occuring in $scores
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
    return (<musq:keystats>
        <key>
            <fifths>{$i}</fifths>
            <mode>{$j}</mode>
        </key>
        <musq:count>{$c}</musq:count>
        <musq:percentage>{$p}</musq:percentage>
    </musq:keystats>)[$c > 0]

} ;


(: ~
 : Create library of lyrics
 : @param scores a (list of) score(s), partwise or timewise
 : @return a <musq:lyriclibrary> element containing concatenated lyrics for every verse of every score
:)
declare function musq:LyricLibrary($scores as node()*) as node()* {
<musq:lyriclibrary>
    {
    for $i in $scores
    let $tit := $i//movement-title
    let $aut := $i//creator[not(empty(./text()))]   (: do not display empty creator tags :)
    return
    <musq:song>{$tit}{$aut}
        {
        	let $lyr := $i//lyric						(: all lyrics :)
        	let $nrv := if(empty($lyr/@number)) then 1 else xs:integer(max($lyr/@number))			(: nr of verses :)
        											(: special case: only one verse, then no number argument present :)
        	for $cur in (1 to $nrv)			(: current verse. watch it: if $nrv=1, then no number argument needs to be present :)
        	let $ver := $lyr[ if($nrv gt 1) then @number = $cur else true() ]/text		(: all <text> elements :)
        	let $s := string-join( for $syl in $ver return concat($syl/text(), if ($syl/../syllabic = ('begin','middle')) then '' else ' '), '')
        	return 
        		<musq:lyric>{attribute{"verse"}{$cur}}{$s}</musq:lyric> [not(empty($lyr))]		(: only print if there are lyrics :)
        }
    </musq:song>
    }
</musq:lyriclibrary>
} ;


(: ~
 : Helper function to decide whether two series of numbers are scaled versions of each other
 : @param seq1 a list of numbers
 : @param seq2 a second list of numbers, as long as seq1
 : @return xs:boolean expressing whether the two lists differ by only a factor.
:)
declare function musq:isScaled($seq1 as xs:decimal+, $seq2 as xs:decimal+) as xs:boolean {
    if (count($seq1) = 1 or count($seq1) != count($seq2))
    then true()
    else ( 
        (: Compute ratios of series elements, normalize to 1, reduce precision to 4 digits after comma :)
        let $ratios := (for $i in (1 to count($seq1)) return round-half-to-even($seq1[$i] div $seq2[$i] * $seq2[1] div $seq1[1] , 4))
        return (count(distinct-values($ratios))=1)
    )
} ;


(: ~
 : Extract rhytmical patterns
 : @param scores a (list of) score(s), partwise or timewise
 : @param pattern a list of relative note durations. Express e.g. as (4, 1, 1, 1, 1) for 1x4th and 4x16th notes
 : Warning: searching for a small pattern in a large database may return extremely many results
 : @return a (list of) <musq:rhythmpattern> element(s) containing measure and note indices of where the pattern was found
:)
declare function musq:FindRhythm($scores as node()*, $pattern as xs:decimal+) as node()* {
    let $patternlength := count($pattern)
    for $score in $scores
    let $notes := $score//note
    
    for $i in (1 to count($notes)-$patternlength)
    let $s := subsequence($notes, $i, $patternlength)   (: get all sequences of 5 notes :)
    (: now select those whose duration follow the pattern :)
    let $durs := $s/duration
    let $voic := distinct-values($s/voice)
    
    where count($s/rest) = 0        (: eliminate subsequences that contain any rests :)
    and count($voic) = (0,1)		(: eliminate subsequences that cross voices :)
    and musq:isScaled($durs, $pattern)
    
    return <musq:rhythmpattern>
        {$score//movement-title}
        <musq:measureindex>{$s[1]/../@number/string()}</musq:measureindex>
        <musq:noteindex>{index-of($s[1]/../note,$s[1])}</musq:noteindex>
    </musq:rhythmpattern>

} ;


(: ~
 : Helper function to create a pitch contour out of a set of MusicXML pitch elements
 : @param pitches a list of MusicXML pitch elements
 : @return xs:integer* a pitch contour representing the subsequent intervals between the given pitches.
 : The length of this list is one less than the length of the pitches sequence
:)
declare function musq:MakeContour($pitches as element(pitch)+ ) as xs:integer* {
    let $midi := musq:MidiNote($pitches)
    for $i in (1 to count($midi)-1)
    return ($midi[$i+1]-$midi[$i])
} ;
    

(: ~
 : Extract melodic patterns
 : @param scores a (list of) score(s), partwise or timewise
 : @param contour a list of subsequent intervals. Express e.g. as (+4, +3, 0) for a major chord with last note repeated
 : Warning: searching for a small contour in a large database may return extremely many results
 : @return a (list of) <musq:melodypattern> element(s) containing measure and note indices of where the contour was found and the first pitch
:)
declare function musq:FindMelody($scores as node()*, $contour as xs:decimal+) as node()* {
    let $patternlength := count($contour)+1
    for $score in $scores
    let $notes := $score//note
    
    for $i in (1 to count($notes)-$patternlength)
    let $s := subsequence($notes, $i, $patternlength)   (: get all sequences of n+1 notes :)
    let $p := $s/pitch			(: all pitch values in a row :)
    let $voic := distinct-values($s/voice)
        
    where count($s/rest) = 0        (: eliminate subsequences that contain any rests :)
    and count($voic) = (0,1)		(: eliminate subsequences that cross voices :)
    (: now calculate the MIDI pitch difference between the notes in the pattern:)
    and deep-equal(musq:MakeContour($p), $contour)        (: Do not use = when comparing sequences :)
    
    return <musq:melodypattern>
        {$score//movement-title}
        <musq:measureindex>{$s[1]/../@number/string()}</musq:measureindex>
        <musq:noteindex>{index-of($s[1]/../note,$s[1])}</musq:noteindex>
        {$p[1]}
    </musq:melodypattern>

} ;


(: ~
 : Helper function to recursively generate all permutations of a list
 : @param this a list of items
 : @return a series of <musq:perm> nodes each containing a permutation of the list's items
:)
declare function musq:Permute($this as item()*) as item()*
{
    (: Work with temporary nodes in the recursion to avoid lists of strings or integers to be converted to atomic types :)
    for $element in $this
	let $remaininglist := remove($this, min(index-of($this,$element)))    (: 'min' use to that index-of returns only one value :)
	let $recursionresults := if (count($remaininglist) eq 1) then <temp>{$remaininglist}</temp> else musq:Permute($remaininglist)
	for $suffix in $recursionresults
	return <musq:perm>{$element}{$suffix/node()}</musq:perm>
	(: previous else clauses have wrapped the suffix already in musq:perm elements, use node() to remove those first :)
};


(: ~
 : Find all occurrences of a specific chord, in any inversion, in the note sequences occurring in the data
 : A chord is defined by its subsequent intervals, which must be all-positive and non-zero. 
 : An inversion is any permutation of MIDI pitches that correspond to the particular chord.
 : This may return overlapping chords if an arpeggiated chord is continued.
 : @param scores a (list of) score(s), partwise or timewise
 : @param contour a list of subsequent intervals. Express e.g. as (+3, +3, +3) for a 4-note diminished chord.
 : Warning: searching for a common chord in a large database may return extremely many results.
 : @return a (list of) <musq:foundchord> element(s) containing measure and note indices of where the contour was found and the first pitch
:)
declare function musq:FindChord($scores as node()*, $contour as xs:decimal+) as node()* {
    let $patternlength := count($contour)+1
    for $score in $scores
    let $notes := $score//note
    
    for $i in (1 to count($notes)-$patternlength)
    let $s := subsequence($notes, $i, $patternlength)   (: get all sequences of n+1 notes :)
    let $p := $s/pitch			(: all pitch values in a row :)
    let $voic := distinct-values($s/voice)
    (:let $perm := musq:Permute($p):)
    
    where count($s/rest) = 0        (: eliminate subsequences that contain any rests :)
    and count($voic) = (0,1)		(: eliminate subsequences that cross voices :)
    and count(distinct-values($p)) = $patternlength  (: eliminate subsequences with repeated notes :)
    and ( some $perm in musq:Permute($p) satisfies (
        deep-equal(musq:MakeContour($perm//pitch), $contour) )
    )
    return 
    <musq:foundchord>
        {$score//movement-title}
    	<musq:measureindex>{$s[1]/../@number/string()}</musq:measureindex>
    	<musq:noteindex>{index-of($s[1]/..//pitch,$p[1])}</musq:noteindex>
    	{$p[1]}
    </musq:foundchord>

} ;


(: ~
 : Extract motive, where both rhythm and melody are defined by patterns
 : @param scores a (list of) score(s), partwise or timewise
 : @param rhythm a list of relative note durations. Express e.g. as (4, 1, 1, 1, 1) for 1x4th and 4x16th notes
 : @param contour a list of subsequent intervals. Express e.g. as (+4, +3, 0) for a major chord with last note repeated
 : the length of contour must be one less than the length of the rhythm
 : Warning: searching for a small contour in a large database may return extremely many results
 : @return a (list of) <musq:melodypattern> element(s) containing measure and note indices of where the contour was found and the first pitch
:)
declare function musq:FindMotive($scores as node()*, $rhythm as xs:decimal+, $contour as xs:decimal*) as node()* {
    let $patternlength := count($rhythm)
    for $score in $scores
    let $notes := $score//note
    
    for $i in (1 to count($notes)-$patternlength)
    let $s := subsequence($notes, $i, $patternlength)   (: get all sequences of n+1 notes :)
    let $p := $s/pitch			(: all pitch values in a row :)
    let $durs := $s/duration
    let $voic := distinct-values($s/voice)
        
    where count($s/rest) = 0        (: eliminate subsequences that contain any rests :)
    and count($voic) = (0,1)		(: eliminate subsequences that cross voices :)
    
    and musq:isScaled($durs, $rhythm)
    and deep-equal(musq:MakeContour($p), $contour)        (: Do not use = when comparing sequences :)
    
    return <musq:motive>
        {$score//movement-title}
        <musq:measureindex>{$s[1]/../@number/string()}</musq:measureindex>
        <musq:noteindex>{index-of($s[1]/../note,$s[1])}</musq:noteindex>
        {$p[1]}
    </musq:motive>

} ;

(: more output can be added for longer chords :)
false() (: eXide grumbles when there's not at least one XPath expression in this file... :)
