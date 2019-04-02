% 1
declare
proc {ReadList L}
   case L
   of nil then skip
   [] H|T then
      {Browse H}
      {ReadList T}
   end
end

% 2
declare P S
{NewPort S P}

{Send P foo}
{Send P bar}
{Browse S}

% The port adds everything that it receives with the {Send P ...} procedure
% to the stream that is associated with it.
% In this case, since we first sent foo, then bar,
% the stream S contains foo|bar|_<future>.
% The _<future> means that the port is still up,
% but hasn't received anything else to add yet.

% 3
declare P S
{NewPort S P}
thread {ReadList S} end
{Send P foo}
{Send P bar}

% 4
declare
proc {RandomSenderManiac N P}
   proc {RSM N P I}
      if N == 0 then skip
      else
	 thread
	    local X in
	       {Delay 1000}
	       X = {OS.rand} mod 2001
	       {Delay X}
	    end
	    {Send P I}
	 end
	 {RSM N-1 P I+1}
      end
   end
in
   {RSM N P 1}
end

% 5
declare P S
{NewPort S P}
{RandomSenderManiac 10 P}
thread {ReadList S} end

% This function is observably nondeterministic:
% different choices made by the scheduler (and with {OS.rand})
% have an unpredictable effect on the output of the program.
% As proof of this, simply execute the same code twice;
% you will not get the same result twice.
% If you did, consider yourself very lucky:
% the odds of that happening are approximately 1/(10!).

% 6
declare
fun {WaitTwo X Y}
   local P S in
      thread {Wait X} {Send P x} end
      thread {Wait Y} {Send P y} end
      {NewPort S P}
      case S
      of x|_ then 1
      [] y|_ then 2
      end
   end
end

local X Y in
   thread {Browse {WaitTwo X Y}} end
   thread {Delay {OS.rand} mod 1000} X = x end
   thread {Delay {OS.rand} mod 1000} Y = y end
end

% 7
declare
proc {Server M}
   case M
   of Msg#Ack then
      {Delay {OS.rand} mod 1001 + 500}
      Ack = unit
   end
end

local S in
   S = x#_
   {Server S}
   {Browse S}
end

% 8
declare
fun {SafeSend P M T}
   local Ack NP S in
      {NewPort S NP}
      {Send P M#Ack}
      thread {Delay T} {Send NP x} end
      thread {Wait Ack} {Send NP y} end
      case S
      of x|_ then false
      of y|_ then true
      end
   end
end

% 9
declare
fun {AddOcc Xs C}
   case Xs
   of nil then [C#1]
   of (H#N)|T then
      if H == C then H#(N+1)|T
      else H#N|{AddOcc T C}
      end
   end
end
proc {Pipe Acc ?Result}
   local S in
      thread
	 fun {Loop Xs X}
	    case Xs
	    of Msg|Xr then A in
	       A = {AddOcc Acc Msg}
	       A|{Loop Xr A}
	    end
	 end
      in
	 Result = {Loop S Acc}
      end
      {NewPort S}
   end
end

% 9.a
% There are multiple possible outputs because the order in which each pipe
% sends messages to the port is observably nondeterministic.
% Depending on which order these arrive in,
% the output stream changes.
% If we however sort this stream, the user would not see this nondeterminism.
% The output stream can have the following values for the example input pipes:
%
% 1. [e#1]|[e#1 m#1]|[e#2 m#1]|[e#2 m#1 c#1]|...
% 2. [e#1]|[e#1 m#1]|[e#1 m#1 c#1]|[e#2 m#1 c#1]|...
% 3. [e#1]|[e#1 c#1]|[e#2 c#1]|[e#2 c#1 m#1]|...
% 4. [e#1]|[e#1 c#1]|[e#1 c#1 m#1]|[e#2 c#1 m#1]|...
% 5. [e#1]|[e#2]|[e#2 c#1]|[e#2 c#1 m#1]|...
% 6. [e#1]|[e#2]|[e#2 m#1]|[e#2 m#1 c#1]|...
% 7. [m#1]|[m#1 e#1]|[m#1 e#2]|[m#1 e#2 c#1]|...
% 8. [m#1]|[m#1 e#1]|[m#1 e#1 c#1]|[m#1 e#2 c#1]|...
%
% In general, the output stream can choose which pipe it handles first,
% meaning the number of possible output streams grows exponentially.

% 9.b
% 42

% 10.a
declare
fun {StreamMerger S1 S2}
   if {WaitTwo S1 S2} == 1 then S1.1|{StreamMerger S1.2 S2}
   else then S2.1|{StreamMerger S1 S2.2}
   end
end

% In order to implement this function for N clients,
% we would have to use WaitTwo N-1 times,
% yielding a very hard implementation.
% Difficult programs are the main drawback of the {WaitTwo} function.

% 10.b
% {WaitTwo} is not deterministic; the output of the function
% depends on the choices made by the scheduler.

% 10.c
declare
proc {StreamMerger S1 S2 ?S}
   local P in
      P = {NewPort S}
      thread {Wait S1.1} {Send P S1.1} {StreamMerger S1.2 S2} end
      thread {Wait S2.1} {Send P S2.1} {StreamMerger S1 S2.2} end
   end
end