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
	let $remaininglist := remove($this, min(index-of($this,$element)))    (: 'min' use to that index-of returns only one value :)
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



(: Searching for a chord and all its inversions in a specific song :)
(: A chord inversion is any permutation of the MIDI pitches :)
(: This may return overlapping chords if an arpeggiated chord is continued :)
(: All notes must occur after each other without rests in between :)
(: All MIDI pitches in the chord must be distinct :)
let $songtitle := 'Blue Danube'
let $chordsize := 3					(: nr of notes in chord :)
let $intervals := (4 , 3)		(: intervals: 4 + 3 semitones :)
let $db := doc("wikifonia-formatted.xml")//score-partwise[movement-title = $songtitle]
let $notes := $db//note[empty(rest)]	 (: select all notes, no rests. Document order is preserved :)
		
for $i in (1 to (count($notes)-$chordsize))				
		(: reformat this into a set of n-note sequences :)
let $s := subsequence($notes, $i, $chordsize)			
let $p := $s/pitch			(: get all n pitch values in a row  :)
let $v := distinct-values($s/voice)			
where count($v) = (0,1)		(: enforce all notes in the same voice :)
	and count(distinct-values($p)) = $chordsize				
	(: now, the pitches must relate to eachother as a large triad. :)
	(: some permutation must exist so that it is such a triad :)
	and ( some $perm in local:Permute(($p[1],$p[2],$p[3])) satisfies (
		local:MidiNote(($perm//pitch)[1])+$intervals[1] 
			eq local:MidiNote(($perm//pitch)[2])
		and local:MidiNote(($perm//pitch)[2])+$intervals[2] 
			eq local:MidiNote(($perm//pitch)[3])
		(: and local:MidiNote(($perm//pitch)[3])+$intervals[3] 
			eq local:MidiNote(($perm//pitch)[4]) :)
		(: add more lines with updated arguments 
			according to the length of the chord :)
	))
return
<found-chord>
	<measure-start>{$s[1]/../@number/string()}</measure-start>
	<note-start>{index-of($s[1]/..//pitch,$p[1])}</note-start>
	<pitch-1>{local:MidiNote($p[1])}</pitch-1>
	<pitch-2>{local:MidiNote($p[2])}</pitch-2>
	<pitch-3>{local:MidiNote($p[3])}</pitch-3>
</found-chord>
(: more output can be added for longer chords :)
