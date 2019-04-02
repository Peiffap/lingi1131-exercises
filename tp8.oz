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