(: This Xquery function finds all occurrences of a chord in a melody :)
(: Author: Joachim Ganseman :)
(: Based on an original in April 2008, fixed in September 2015 :)

(: Currently set up to search in Blue Danube in the wikifonia database :)
(: Currently set up to search for major triads, in any sequence of notes, in any permutation :)


(: copied from recordare - replaced define by declare, added ';' at end, and '(pitch)' to element param :)
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

(: generate all permutations of a given sequence :)
declare function local:Permute($this as item()*) as item()*
{
	for $element in $this
	let $remaininglist := remove($this, min(index-of($this,$element)))    (: index-of may return a sequence, we require only one value :)
	let $recursionresults := if (count($remaininglist) eq 1 ) then <t>{$remaininglist}</t> else local:Permute($remaininglist)
	for $suffix in $recursionresults
	return <perm>{insert-before($suffix//t, 0, <t>{$element}</t>)}</perm>
};

(: testing permutations :)
(:
for $i in local:Permute(("A","B","C","D"))
return $i
:)

(: testing to generate all permutations of a set of pitches :)
(:
for $bd in doc("wikifonia-formatted.xml")//score-partwise[movement-title = 'Blue Danube']
let $pitches := $bd//pitch
let $s := subsequence($pitches, 1, 3)
return local:Permute($s)
:)



(: searching for harmonic families: a chord and all its permutations :)
(: again use the same: find a large triad and all of its permutations :)
(: this includes overlapping if triads are repeated, but there must be no note in between and all notes must occur :)

let $bd := doc("wikifonia-formatted.xml")//score-partwise[movement-title = 'Blue Danube']
let $notes := $bd//note[empty(rest)]
for $i in (1 to (count($notes)-3))				(: document order is preserved anyway :)
let $s := subsequence($notes, $i, 3)			(: get all sequences of 3 notes :)
let $pitc := $s/pitch			(: all 3 pitch values in a row  - could be unpitched? :)
let $voic := distinct-values($s/voice)			(: only distinct voice values :)
let $meas := $s/..
(: let $perm := local:Permute($pitc) :)
where count($s/rest) = 0			(: no rests :)
and count($voic) = (0,1)			(: in the same voice :)
and count(distinct-values($pitc)) = 3				(: 3 distinct elements :)
	(: now, the pitches must relate to eachother as a large triad. :)
	(: some permutation must exist so that it is such a triad :)

and ( some $permval in local:Permute(($pitc[1],$pitc[2],$pitc[3])) satisfies (
		local:MidiNote(($permval//pitch)[1])+4 eq local:MidiNote(($permval//pitch)[2])
		and local:MidiNote(($permval//pitch)[2])+3 eq local:MidiNote(($permval//pitch)[3])
	))
return
<triad>
	<measure-start>{$s[1]/../@number/string()}</measure-start>
	<note-start>{index-of($s[1]/..//pitch,$pitc[1])}</note-start>
	<pitch-start>{local:MidiNote($pitc[1])}</pitch-start>
	<pitch-middle>{local:MidiNote($pitc[2])}</pitch-middle>
	<pitch-end>{local:MidiNote($pitc[3])}</pitch-end>
</triad>

