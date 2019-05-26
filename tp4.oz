% 1.a
% The first program blocks because "+" is a blocking call,
% meaning the program waits
% until the values of Y and Z are bound before continuing.
% Since these values are only bound later in the same thread,
% nothing can happen and the program stays stuck.

% The second program however uses "plus", which is not a blocking call.
% The program continues with its execution flow,
% eventually assigning a value to X.

% 1.b
local X Y Z in
   thread X = Y + Z end
   Y = 1
   Z = 2
   {Browse X}
end

% 2
declare
fun {Counter InS}
   fun {ListAdd L E}
      case L of nil then [E#1]
      [] H|T then
	 if H.1 == E then
	    E#(H.2+1)|T
	 else
	    H|{ListAdd T E}
	 end
      end
   end
   fun {Count InS Acc}
      case InS of nil then nil
      [] H|T then Acc2 in
	 Acc2 = {ListAdd Acc H}
	 Acc2|{Count T Acc2}
      end
   end
in
   thread {Count InS nil} end
end

local InS in
   {Browse {Counter InS}}
   InS = e|m|e|c|a|y|e|t|e|e|e|p|_
end

% 3
declare
proc {PassingTheToken Id Tin Tout}
   case Tin of H|T then X in
      {Show Id#H}
      {Delay 1000}
      Tout = H|X
      {PassingTheToken Id T X}
   [] nil then skip
   end
end

local X Y Z in
   thread {PassingTheToken 1 X Y} end
   thread {PassingTheToken 2 Y Z} end
   thread {PassingTheToken 3 Z X} end
end

% 4
% At 36 seconds, Bar has to stop putting beers on the table,
% as he is about to put the fifth beer on the table.

% The table is a bounded buffer of size four.

% In one hour, Foo drank 299 beers.
declare
fun {Foo Beers Table N}
   case Beers of H|T then
      local Ta in
	 {Delay 1200}
	 Table = (N+1)|Ta
	 empty|{Foo T Ta N+1}
      end
   end
end

fun {Bar Table}
   case Table of H|T then
      {Delay 500}
      full|{Bar T}
   end
end

Table = 1|2|3|4|_
Beers = thread {Bar Table} end
Ground = thread {Foo Beers {List.drop Table 4} 4} end
{Browse Table}
{Browse Beers}
{Browse Ground}

% 5.a
declare
proc {MapRecord R1 F R2}
   A = {Record.arity R1}
   proc {Loop L}
      case L of nil then skip
      [] H|T then
	 thread R2.H = {F R1.H} end
	 {Loop T}
      end
   end
in
   R2 = {Record.make {Record.label R1} A}
   {Loop A}
end

{Browse {MapRecord '#'(a:1 b:2 c:3 d:4 e:5 f:6 g:7)
	 fun {$ X} {Delay 1000} 2*X end}}

% When using Browse, the program prints output,
% but does not do so when we use Show.
% The reason for this is that the call to Show is blocking,
% while the call to Browse is not.

declare
proc {MapRecord R1 F ?R2}
   A = {Record.arity R1}
   proc {Loop L}
      case L of nil then skip
      [] H|T then
	 thread R2.H = {F R1.H} end
	 {Loop T}
      end
   end
in
   R2 = {Record.make {Record.label R1} A}
   {Loop A}
end

{Show {MapRecord '#'(a:1 b:2 c:3 d:4 e:5 f:6 g:7)
       fun {$ X} {Delay 1000} 2*X end}}

% 5.b
declare
proc {MapRecord R1 F ?R2 ?Done}
   A = {Record.arity R1}
   proc {Loop L}
      case L of nil then thread {Delay 5000} Done = unit end
      [] H|T then
	 thread R2.H = {F R1.H} end
	 {Loop T}
      end
   end
in
   R2 = {Record.make {Record.label R1} A}
   {Loop A}
end

local Done in
   {Browse {MapRecord '#'(a:1 b:2 c:3 d:4 e:5 f:6 g:7)
	    fun {$ X} {Delay 1000} 2*X end $ Done}}
   {Browse Done}
end

% 5.c
declare
proc {MapRecord R1 F ?R2 ?Done}
   A = {Record.arity R1}
   proc {Loop L}
      case L of nil then thread {Delay 5000} Done = unit end
      [] H|T then
	 thread R2.H = {F R1.H} end
	 {Loop T}
      end
   end
in
   R2 = {Record.make {Record.label R1} A}
   {Loop A}
   {Wait Done}
end

local Done in
   {Browse {MapRecord '#'(a:1 b:2 c:3 d:4 e:5 f:6 g:7)
	    fun {$ X} {Delay 1000} 2*X end $ Done}}
   {Browse Done}
end
