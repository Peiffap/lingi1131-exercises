% 1
% 20/20 never doing this shit again.

% 2.1 & 2.2
declare
fun {NewPortObject F Init}
   Xs
   P = {NewPort Xs}
   proc {Loop State Ms}
      M|Mr = Ms
   in
      {Loop {F State M} Mr}
   end
in
   thread {Loop Init Xs} end
   P
end
fun {RecordToList R I}
   [R.1 R.2 R.3 R.4]
end
fun {MakeAgent Val Neighbours}
   fun {FindNonMember Path Vertices L}
      case Vertices
      of nil then L
      [] H|T then
	 if {List.member H Path} then
	    {FindNonMember Path T L}
	 else
	    {FindNonMember Path T H|L}
	 end
      end
   end
   fun {FindPos X T I}
      if T.1 == X then 1
      elseif T.2 == X then 2
      elseif T.3 == X then 3
      else 4
      end
   end
   fun {Remove L Elem}
      case L
      of nil then nil
      [] H|T then
	 if H == Elem then
	    {Remove T Elem}
	 else
	    H|{Remove T Elem}
	 end
      end
   end
   fun {F State Message}
      run(X L S) = Message
      Vertices
      Found
   in
      {Browse L}
      Vertices = {FindNonMember L {RecordToList Neighbours 1} nil}
      Found = {Length Vertices}
      if Found >= 2 then B1 B2 Rand1 Rand2 in
	 Rand1 = ({OS.rand} mod Found) + 1
	 Rand2 = ({OS.rand} mod (Found-1)) + 1
	 B1 = {FindPos {Nth Vertices Rand1} Neighbours 1}
	 B2 = {FindPos {Nth {Remove Vertices B1} Rand2} Neighbours 1}
	 {Send Neighbours.B1 run(X Val|L S)}
	 {Send Neighbours.B2 run(X Val|L S)}
      elseif Found == 1 then
	 {Send {FindPos Vertices.1 Neighbours 1} run(X Val|L S)}
      else
	 if {List.member Val|L S} then
	    X = S
	 else Rand in
	    Rand = ({OS.rand} mod 4) + 1
	    {Send Neighbours.Rand run(X nil (Val|L)|S)}
	 end
      end
      lily
   end
in
   {NewPortObject F lily}
end
fun {Encode X}
   if X == 1 then [0 0 0 0]
   elseif X == 2 then [0 0 0 1]
   elseif X == 3 then [0 0 1 0]
   elseif X == 4 then [0 0 1 1]
   elseif X == 5 then [0 1 0 0]
   elseif X == 6 then [0 1 0 1]
   elseif X == 7 then [0 1 1 0]
   elseif X == 8 then [0 1 1 1]
   elseif X == 9 then [1 0 0 0]
   elseif X == 10 then [1 0 0 1]
   elseif X == 11 then [1 0 1 0]
   elseif X == 12 then [1 0 1 1]
   elseif X == 13 then [1 1 0 0]
   elseif X == 14 then [1 1 0 1]
   elseif X == 15 then [1 1 1 0]
   elseif X == 16 then [1 1 1 1]
   end
end
fun {Decode L}
   8*L.1 + 4*L.2.1 + 2*L.2.2.1 + L.2.2.2.1 + 1
end
fun {NeighbourList L}
   [[1-L.1 L.2.1 L.2.2.1 L.2.2.2.1] [L.1 1-L.2.1 L.2.2.1 L.2.2.2.1] [L.1 L.2.1 1-L.2.2.1 L.2.2.2.1] [L.1 L.2.1 L.2.2.1 1-L.2.2.2.1]]
end

proc {MakeTesseract}
   Vertices = {MakeTuple tesseract 16}
   X
in
   for I in 1..16 do
      Neighbours = {MakeTuple neigh 4}
      NList = {NeighbourList {Encode I}}
   in
      for J in 1..4 do
	 {Browse I#J}
	 Neighbours.J = Vertices.({Decode {Nth NList J}})
      end
      Vertices.I = {MakeAgent I Neighbours}
   end
   {Send Vertices.1 run(X nil nil)}
end

{MakeTesseract}

% 2.3
% The program should never terminate,
% since all agents keep waiting for messages,
% but after a certain (very long) amount of time,
% the messages should stop getting forwarded (probabilistically).

% 2.4
% No, it cannot be written in a deterministic paradigm,
% because ports cannot know where the next message will come from.

% 3.1
declare
class Counter
   attr val
   meth init
      val := {NewCell 0}
   end
   meth inc
      @val := @@val + 1
   end
   meth get(X)
      X = @@val
   end
end

fun {NewActive Class Init}
   Obj = {New Class Init}
   P
in
   thread S in
      {NewPort S P}
      for M in S do {Obj M} end
   end
   proc {$ M} {Send P M} end
end

C = {New Counter init}
{C inc}
{Browse {C get($)}}
{C inc}
{Browse {C get($)}}

X1 X2
D = {NewActive Counter init}
thread {D inc} X1=unit end
thread {D inc} X2=unit end
{Wait X1} {Wait X2}
{Browse {D get($)}}


% 3.2 & 3.3 & 3.4
% Cf. paper.

% 3.5
declare
fun {NewCounter}
   C
   proc {Inc}
      Old New
   in
      {Exchange C Old New}
      New = Old + 1
   end
   proc {Get ?X}
      X = @C
   end
in
   C = {NewCell 0}
   count(inc:Inc get:Get)
end

X1 X2
C = {NewCounter}
thread {C.inc} X1=unit end
thread {C.inc} X2=unit end
{Wait X1} {Wait X2}
{Browse {C.get}}

% 3.6
declare
Lock = {NewLock}
class Counter
   attr val
   prop locking
   meth init
      val := {NewCell 0}
   end
   meth inc
      lock Lock then
	 @val := @@val+1
      end
   end
   meth get($)
      lock Lock then
	 @@val
      end
   end
end

X1 X2
C = {New Counter init}
thread {C inc} X1=unit end
thread {C inc} X2=unit end
{Wait X1} {Wait X2}
{Browse {C get($)}}
