(: xqueries on the wikifonia database :)
(: by Joachim Ganseman, VisionLab, University of Antwerp :)
(: related to the paper : Using XQuery on MusicXML Databases for Musicological Analysis :)
(: presented at ISMIR 2008 :)

(: Tested to work with Wikifonia dd. 31 march 2008 and eXist-db v. 1.4.3 :)


(: Usage: uncomment the query that you want to see active :)
(: Or just copy and paste it into the eXist's XQuery searchbox :)

(: 1. retrieve titles of all songs :)
(: 
	doc("wikifonia-formatted.xml")//movement-title
:)


(: 2. count the number of songs :)
(:
count(doc("wikifonia-formatted.xml")//score-partwise)
:)


(: 3. print the musicxml version of all songs :)
(: necessary to enclose output in tags since attribute cannot exist on its own :)
(:
for $i in doc("wikifonia-formatted.xml")//score-partwise/@version
return <version>{$i}/text()</version>
:)


(: 4. get the note count of all songs, order results :)
(:
for $i in doc("wikifonia-formatted.xml")//score-partwise
let $j := count($i//note)
order by $j descending
return element{"song"}{attribute{"title"}{$i//movement-title/text()}, attribute{"note-count"}{$j}}
:)


(: 5. get the song with the fewest notes, print them :)
(:
for $i in doc("wikifonia-formatted.xml")//score-partwise
let $j := $i//movement-title [ count($i//note) eq min(
	for $x in doc("wikifonia-formatted.xml")//score-partwise
	return count($x//note)
)]
return $j
:)
(: return $j :)			(: give back the title only :)
(: return $j/../score-partwise :) (: give the whole score, through the parent node :)
(: return $j/..//note :)			(: give all notes :)


(: 6. get the songs with no rests :)
(:
for $i in doc("wikifonia-formatted.xml")//score-partwise
return $i[count($i//rest) eq 0]//movement-title
:)


(: 7. get the songs with multiple parts (for several instruments) :)
(:
for $i in doc("wikifonia-formatted.xml")//part-list
return $i[count($i//score-part) gt 1]/../movement-title
:)
(: return $i[count($i//score-part) gt 1]/../movement-title :)		(: return the titles :)
(: return count($i//score-part) :) 		(: get the counts themselves. Wrap whole function in max() to get max :)


(: 8. order the songs by measure count: same as note count - query 4 - but with measures :)
(:
for $i in doc("wikifonia-formatted.xml")//score-partwise
let $j := count($i//measure)
order by $j descending
return element{"song"}{attribute{"title"}{$i//movement-title/text()}, attribute{"measure-count"}{$j}}
:)


(: 9. find song titles that occur multiple times in the database :)
(: note to self: attributes must come before contents in element definition, attributes must be defined inside element :)
(:
for $i in distinct-values(doc("wikifonia-formatted.xml")//movement-title/text())
let $c := count(doc("wikifonia-formatted.xml")//movement-title[text() = $i])
order by $c descending, $i
return ( element{"song"}{attribute{"count"}{$c}, $i} )[$c gt 1]
:)

(: 10. find authors that occur multiple times in the database :)
(: note to self: attributes must come before contents in element definition, attributes must be defined inside element :)
(: added lower-case, marafioti occurs in both... :)
(:
for $i in distinct-values(doc("wikifonia-formatted.xml")//creator[@type="composer"]/lower-case(text()))
let $c := count(doc("wikifonia-formatted.xml")//creator[@type="composer"][lower-case(text()) = $i])
order by $c descending, $i
return ( element{"author"}{attribute{"count"}{$c}, $i} )[$c gt 1]
:)


(: 11. find all pieces in c minor :)
(:
for $i in doc("wikifonia-formatted.xml")//key
where ($i/fifths/text() eq "-3") and ($i/mode/text() eq "minor")
return $i/ancestor-or-self::score-partwise//movement-title
:)


(: 11b. equivalent but way faster in eXist :)
(:
for $i in doc("wikifonia-formatted.xml")//key[fifths/text() eq "-3"][mode/text() eq "minor"]
return $i/ancestor-or-self::score-partwise//movement-title
:)


(: 12. list all time signatures and occurrence statistics :)
(:
let $t := count(doc("wikifonia-formatted.xml")//time)
for $i in distinct-values(doc("wikifonia-formatted.xml")//beats)
for $j in distinct-values(doc("wikifonia-formatted.xml")//beat-type)
let $c := count(doc("wikifonia-formatted.xml")//time[beats eq $i][beat-type eq $j])
let $p := $c div $t * 100
order by $p descending
return element{"time"} {
attribute{"beats"}{$i},
attribute{"beat-type"}{$j},
element{"count"}{$c},
element{"percentage"}{$p}
} [$c gt 0]
:)
(: returns also signatures that do not exist, due to no link between beat and beat-type, so add count selection :)


(: 13. we can do the same for keys, finding major, minor and <fifths> values from -7 to 7 :)
(:
let $t := count(doc("wikifonia-formatted.xml")//key)
for $i in (-7 to 7)
for $j in ("minor","major")
let $c := count(doc("wikifonia-formatted.xml")//key[fifths eq string($i)][mode eq $j])
let $p := $c div $t * 100
order by $p descending
return element{"key"} {
attribute{"fifths"}{$i},
attribute{"mode"}{$j},
element{"count"}{$c},
element{"percentage"}{$p}
} [$c gt 0]
:)


(: 14. Now for a very complex one: extracting lyrics from each file and compiling them into a library :)
(:
<library>
{
for $i in doc("wikifonia-formatted.xml")//score-partwise
let $tit := $i//movement-title/text()
let $aut := $i//creator[@type="composer"]/text()
return
<song>{attribute{"title"}{$tit}}{attribute{"composer"}{$aut}}
{
	let $lyr := $i//lyric						(: all lyrics :)
	let $nrv := if(empty($lyr/@number)) then 1 else xs:integer(max($lyr/@number))			(: nr of verses :)
											(: special case: only one verse, then no number argument present :)
	for $cur in (1 to $nrv)			(: current verse. watch it: if $nrv=1, then no number argument needs to be present :)
	let $ver := $lyr[ if($nrv gt 1) then @number = $cur else true() ]/text		(: all <text> elements :)
	let $s := string-join( for $syl in $ver return concat($syl/text(), if ($syl/../syllabic = ('begin','middle')) then '' else ' '), '')
	return 
		<lyric>{attribute{"verse"}{$cur}}{$s}</lyric> [not(empty($lyr))]		(: only if there are lyrics :)
}
</song>
}
</library>
:)


(: 14b. Verification: make sure that every lyric number is integer :)
(:
for $i in distinct-values(doc("wikifonia-formatted.xml")//lyric/@number)
order by $i descending
return element{"nr"}{attribute{"nr"}{$i}}
:)


(: 15. searching for a rhytmical pattern. Use Blue Danube :)
(: extract the four note motive, and apply some extra constraints :)
(:
let $bd := doc("wikifonia-formatted.xml")//score-partwise[movement-title = 'Blue Danube']
let $notes := $bd//note
for $i in (0 to count($notes))				(: document order is preserved anyway :)
let $s := subsequence($notes, $i, 4)			(: get all sequences of 5 notes :)
(: now select those with the last note duration being 3 times that of the previous ones :)
let $durs := $s/duration
let $voic := distinct-values($s/voice)
let $meas := $s/..
where count($s/rest) = 0			(: no rests :)
and count($voic) = (0,1)			(: single voice :)
and $durs[1]/text() eq $durs[2]/text()		(: durations of first 3 notes the same :)
and $durs[2]/text() eq $durs[3]/text()			(: TODO incorporate divisions value :)
	(: a possible solution to presence/absence of divisions value is to recalc durations to quarter notes :)
	(: a function could be written for that :)
and number($durs[4]) eq number($durs[1]) * 3		(: casting to numerical value :)
return 
<motive>
	<measure-start>{$s[1]/../@number/string()}</measure-start>
	<note-start>{index-of($s[1]/../note,$s[1])}</note-start>
</motive>
:)


(: function declaration copied from recordare (replaced define by declare. Also added ';' to end, and '(pitch)' to element param) :)
declare function local:MidiNote($thispitch as element(pitch)) as xs:integer
{
  let $step := $thispitch/step
  let $alter :=
    if (empty($thispitch/alter)) then 0
    else xs:integer($thispitch/alter)
  let $octave := xs:integer($thispitch/octave)
  let $pitchstep :=
    if ($step = "C") then 0
    else if ($step = "D") then 2
    else if ($step = "E") then 4
    else if ($step = "F") then 5
    else if ($step = "G") then 7
    else if ($step = "A") then 9
    else if ($step = "B") then 11
    else 0
  return 12 * ($octave + 1) + $pitchstep + $alter
}; 


(: 16. searching a melodic pattern. using the Blue Danube to test :)
(: try finding large triad and repetition of last note :)
(: use midipitch function from recordare :)
(:
let $bd := doc("wikifonia-formatted.xml")//score-partwise[movement-title = 'Blue Danube']
let $notes := $bd//note
for $i in (0 to count($notes))				(: document order is preserved anyway :)
let $s := subsequence($notes, $i, 4)			(: get all sequences of 4 notes :)
let $pitc := $s/pitch			(: all pitch values in a row :)
let $voic := distinct-values($s/voice)			(: only distinct voice values :)
let $meas := $s/..
where count($s/rest) = 0			(: no rests :)
count($voic) = (0,1)
and count($pitc) = 4				(: 3 elements - avoid border cases :)
and local:MidiNote($pitc[1])+4 eq local:MidiNote($pitc[2])
and local:MidiNote($pitc[2])+3 eq local:MidiNote($pitc[3])
and local:MidiNote($pitc[3]) eq local:MidiNote($pitc[4])
return
<triad>
	<measure-start>{$s[1]/../@number/string()}</measure-start>
	<note-start>{index-of($s[1]/../note,$s[1])}</note-start>
	<pitch-start>{local:MidiNote($pitc[1])}</pitch-start>
</triad>
:)
(: note that "count(distinct-value($pitc)) = 3" may provide a better constrained thus faster search :)
