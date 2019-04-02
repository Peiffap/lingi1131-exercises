% 1.a
declare
fun lazy {Ints N}
   N|{Ints N+1}
end

fun lazy {Sum2 Xs Ys}
   case Xs#Ys
   of (X|Xr)#(Y|Yr) then (X+Y)|{Sum2 Xr Yr}
   end
end

S = 0|{Sum2 S {Ints 1}}
{Browse S.2.2.1}
% We can see that S.1 = 0, hence S.2.1 = 1 + 0 = 1 and S.2.2.1 = 1 + 2 = 3.

% 1.b
% We can use the fact that s_i = i(i+1)/2, but we don't do that here.
declare
fun {Nth S N}
   if N < 0 then error
   elseif N == 0 then S.1
   else {Nth S.2 N-1}
   end
end

% 1.c
declare
proc {Ints N ?R}
   local R1 N1 in
      thread
	 {WaitNeeded R}
	 N1 = N+1
	 R = N|{Ints N1 R1}
      end
   end
end
proc {Sum2 Xs Ys ?R}
   local R1 R2 R3 in
      thread
	 {WaitNeeded R}
	 R1 = Xs#Ys
	 case R1
	 of (X|Xr)#(Y|Yr) then
	    R2 = X+Y
	    R = R2|{Sum2 Xr Yr R3}
	 end
      end
   end
end
proc {Nth S N ?R}
   local Zero N1 R1 in
      if N < Zero then R = error
      elseif N == Zero then R = S.1
      else
	 N1 = N-1
	 {Nth S.2 N1 R1}
      end
   end
end

% 1.d
% Lazy suspensions occur when a function does not need to keep executing
% because it has given all the results that it needed to give.
% Threads are then suspended until more results need to be computed.
% The variables that we call {WaitNeeded} on
% are the results of the lazy functions.

% When calling S.2.1, the program starts by setting S.1 to 0.
% It then needs to compute {Sum2} on 0|... and {Ints 1}.
% For the computation, we need to know the first element of both lists.
% {Ints 1} is lazily evaluated until that first element is known, that is,
% it executes once to yield 1.
% The program then adds the two together which yields 1, hence S.2.1 = 1.
% The threads of the program are then suspended
% until more results are asked for.

% 2.a
% A time-varying signal can be represented as a stream of integers,
% where each integer represents the value of the signal at time t.

% 2.b
% Combinational logic is logic where no memory is involved, i.e.,
% the output at time t only depends on the input at time t.

% An example of a combinational logic operation
% that uses at least two gates is the NAND operation (1 NOT, 1 AND).
%
%      - - - - - - - - - - - -
%     |    _____    _____     |
% X --|---|     |  |     |    |
%     |   | AND |--| NOT |----|-- Z = X NAND Y
% Y --|---|_____|  |_____|    |
%     |                       |
%      - - - - - - - - - - - -

% 2.c
% Sequential logic is logic with memory, that is,
% the output at time t can depend on every input that came before it.

% An example of a sequential logic circuit is a that does the and operation between a signal and that same signal shifted into the future by one.
%
%      - - - - - - - - - - - -
%     |          _____        |
% X --|---------|     |       |
%     |  |      | AND |-------|-- Y
%     | Delay --|_____|       |
%     |                       |
%      - - - - - - - - - - - -
%
% The difference is that sequential logic uses delays (read: has memory),
% whereas combinational logic does not.

% 2.d
declare
fun {Osc Last}
   1-Last|{Osc 1-Last}
end

% 2.e
% If we use lazy functions, the stream will only be 0|_

% 3
declare
proc {Job Type ?Flag}
   {Delay {OS.rand} mod 1000}
   {Browse Type}
   Flag = unit
end

proc {BuildPs N ?Ps}
   Ps = {Tuple.make '#' N}
   for I in 1..N do
      Type = {OS.rand} mod 10
      Flag
   in
      Ps.I = ps(type:Type job:proc {$} {Job Type Flag} end flag:Flag)
   end
end

N = 100
Ps = {BuildPs N}
for I in 1..N do
   thread {Ps.I.job} end
end

proc {WatchPs I Ps}
   for J in 1..100 do
      if Ps.J.type == I then {Wait Ps.J.flag}
      else skip
      end
   end
   {Browse 'all the threads of type I are finished'}
end

{WatchPs {OS.rand} mod 10 Ps}

% 4
declare
proc {WaitOr X Y}
       {Record.waitOr '#'(X Y)}
end

% 5
declare
fun {WaitOrValue X Y}
   local Z in
      Z = {WaitOr X Y}
      if Z == 1 then X
      else Y
      end
   end
end

% 6
declare
fun {Counter InS}
   fun {ListAdd L E}
      case L
      of nil then [E#1]
      [] H|T then
	 if H.1 == E then
	    E#(H.2+1)|T
	 else
	    H|{ListAdd T E}
	 end
      end
   end
   fun {Count Curr Next NextEnd Acc}
      case Curr
      of nil then
	 NextEnd = nil
	 if Next == nil then nil
	 else Next2 in {Count Next Next2 Next2 Acc}
	 end
      [] InSi|InSr then
	 case InSi
	 of nil then {Count InSr Next NextEnd Acc}
	 [] H|T then Acc2 NextEnd2 in
	    NextEnd = T|NextEnd2
	    Acc2 = {ListAdd Acc H}
	    Acc2|{Count InSr Next NextEnd2 Acc2}
	 end
      end
   end
   Next
in
   thread {Count InS Next Next nil} end
end

% If one of the pipes stops rescuing with nil, then we just skip over it.
% If it stops with an unbound tail, then the program blocks.

% The solution already works for any number of pipes.