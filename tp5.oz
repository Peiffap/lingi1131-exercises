% 1.a
declare
fun {Numbers N I J}
   {Delay 500}
   if N == 0 then nil
   else {OS.rand} mod (J - I + 1) + I|{Numbers N-1 I J}
   end
end

{Browse {Numbers 13 42 69}}

% 1.b
declare
fun {SumAndCount L}
   fun {Aux L AccL AccS}
      {Delay 250}
      case L
      of nil then AccL|AccS|nil
      [] H|T then {Aux T AccL+1 AccS+H}
      end
   end
in
   {Aux L 0 0}
end

{Browse {SumAndCount [1 2 3 4 5 6 7 8 9 10]}}

% 1.c
local L R in
   thread L = {Numbers 13 42 69} end
   thread R = {SumAndCount L} end

   {Browse L}
   {Browse R}
end

% This little producer-consumer takes 0.5N,
% as {SumAndCount L} executes while {Numbers} is building the list.
% {Numbers} is the producer function while {SumAndCount} is the consumer.

% 1.d
declare
fun {FilterList Xs Ys}
   fun {Contains X L}
      case L
      of nil then false
      [] H|T then
	 if X==H then true
	 else {Contains X T}
	 end
      end
   end
in
   case Xs
   of nil then nil
   [] H|T then
      if {Contains H Ys} then {FilterList T Ys}
      else H|{FilterList T Ys}
      end
   end
end

{Browse {FilterList [1 2 3 4 5 6 7 8 9 10] [2 4 6 8 10]}}

% 1.e
local X Y Z in
   thread X = {Numbers 5 0 10} end
   thread Y = {FilterList X [0 2 4 6 8 10]} end
   thread Z = {SumAndCount Y} end

   {Browse X}
   {Browse Y}
   {Browse Z}
end

% 2.a
declare
fun {NotGate Xs}
   fun {Not X}
      1 - X
   end
in
   case Xs
   of nil then nil
   [] H|T then thread {Not H}|{NotGate T} end
   end
end

local L in
   L = 1|0|1|_
   {Browse {NotGate L}}
end

% 2.b
declare
fun {AndGate Xs Ys}
   fun {And X Y}
      X * Y
   end
in
   case Xs#Ys
   of nil#nil then nil
   [] (H1|T1)#(H2|T2) then thread {And H1 H2}|{AndGate T1 T2} end
   end
end

local L1 L2 in
   L1 = 1|0|1|_
   L2 = 0|0|1|_
   {Browse {AndGate L1 L2}}
end

declare
fun {OrGate Xs Ys}
   fun {Or X Y}
      X + Y - X * Y
   end
in
   case Xs#Ys
   of nil#nil then nil
   [] (H1|T1)#(H2|T2) then thread {Or H1 H2}|{OrGate T1 T2} end
   end
end

local L1 L2 in
   L1 = 1|0|1|_
   L2 = 0|0|1|_
   {Browse {OrGate L1 L2}}
end

% 2.c
declare
fun {Simulate G Ss}
   case G
   of input(X) then Ss.X
   [] Y then
      if Y.value == 'and' then {AndGate {Simulate Y.1 Ss} {Simulate Y.2 Ss}}
      elseif Y.value == 'or' then {OrGate {Simulate Y.1 Ss} {Simulate Y.2 Ss}}
      elseif Y.value == 'not' then {NotGate {Simulate Y.1 Ss}}
      end
   end
end

declare G Ss
G = gate(value:'or'
	 gate(value:'and'
	      input(x)
	      input(y))
	 gate(value:'not'
	      input(z)))
Ss = input(x:1|0|1|0|_
	   y:0|1|0|1|_
	   z:1|1|0|0|_)
{Browse {Simulate G Ss}}

% 2.d
% Logic gates are consumers.

% 3.a
declare
L1 L2 F

L1 = [1 2 3]
F = fun {$ X} {Delay 200} X*X end
thread L2 = {Map L1 F} end
{Wait L2}
{Show L2}

% 3.b
declare
L1 L2 L3 L4
L1 = [1 2 3]
thread L2 = {Map L1 fun {$ X} {Delay 200} X*X end} end
thread L3 = {Map L1 fun {$ X} {Delay 200} 2*X end} end
thread L4 = {Map L1 fun {$ X} {Delay 200} 3*X end} end
{Wait L2}
{Wait L3}
{Wait L4}
{Show L2#L3#L4}

% 3.c.i + 3.c.ii
declare
proc {MapRecord R1 F ?Extra ?R2}
   A = {Record.arity R1}
   proc {Loop L}
      case L
      of nil then
	 Extra = unit
      [] H|T then
	 thread R2.H={F R1.H} end
	 {Wait R2.H}
	 {Loop T}
      end
   end   
in
   R2={Record.make {Record.label R1} A}
   {Loop A}
end

local E in
   {Show {MapRecord
	  '#'(a:1 b:2 c:3 d:4 e:5 f:6 g:7)
	  fun {$ X} {Delay 1000} 2*X end E}}
end

% 3.d.i
% Cf. tp4.oz

% 3.d.ii
% Using bounded buffers, we can limit the rate at which the producer produces,
% hence stopping it from making the memory overflow.
% Memory overflow can happen if one consumer is faster
% because the producer will have to keep producing for the fast consumer
% while still keeping the other results in memory for the slower consumer.
% If no bounded buffer is used, then the gap will always get bigger,
% and the memory will overflow eventually.

% We can set the buffer size to 1500,
% since that is the largest the difference can possibly get.
% Alternatively, we can use a bounded buffer for each consumer.
% This fixes the issues with memory overflow
% without hindering the faster consumers too much.
