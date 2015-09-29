xquery version "3.0";

(: mxquery.xqm
 : XQuery Function Library for use with MusicXML files 
 : Version 1.1 : working with eXist 2.2 and wrapped in a proper module.
 : @author Joachim Ganseman
:)

declare namespace musq="https://github.com/jganseman/mxquery";

(: Helper function to compute MIDI pitches
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

(: Exctract the title elements from one or more scores 
 : @param $scores a (list of) score element(s), partwise or timewise 
 : @return a MusicXML <movement-title> element
:)
declare function musq:GetTitle($score as node()* ) as node()* {
    $score//movement-title
} ;

(: Return the version of a score 
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


(: Get the note count of all songs, optionally order results 
 : @param scores a (list of) scores, partwise or timewise
 : @return a (list of) <musq:notecount> elements, 
 : optionally ordered from high to low
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


the-end (: eXide grumbles when there's not at least one XPath expression in this file... :)