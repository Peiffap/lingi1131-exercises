% 1
declare
fun {GenericServer P}
   In in
   thread
      for Msg in In do
	 thread {P Msg} end
      end
   end
   {Port.new In}
end

fun {LaunchServer}
   {GenericServer proc {$ Msg}
		     case Msg
		     of add(X Y R) then
			R = X+Y
		     [] pow(X Y R) then
			R = {Number.pow X Y}
		     [] 'div'(X Y R) then
			try R = (X div Y) catch _ then R = error(x:X y:Y) end
		     else
			{Show 'message not understood'}
		     end
		  end
   }
end

declare
A B N S
Res1 Res2 Res3 Res4 Res5 Res6

S = {LaunchServer}
{Send S add(321 345 Res1)}
{Wait Res1} {Show Res1}

{Send S pow(2 N Res2)}
N = 8
{Wait Res2} {Show Res2}

{Send S add(A B Res3)}
{Send S add(10 20 Res4)}
{Send S foo}
{Wait Res4} {Show Res4}
A = 3
B = 0-A
{Send S 'div'(90 Res3 Res5)}
{Send S 'div'(90 Res4 Res6)}
{Wait Res3} {Show Res3}
{Wait Res5} {Show Res5}
{Wait Res6} {Show Res6}

% The protocol is asynchronous RMI with server-side threads.

% 2
% This version uses the RMI protocol.
declare
fun {CreateUniversity Size}
   fun {StudentRMI}
      S
   in
      thread
	 for ask(howmany:Beers) in S do
	    Beers = {OS.rand} mod 24
	 end
      end
      {NewPort S}
   end
   fun {CreateLoop I}
      if I =< Size then
	 {StudentRMI}|{CreateLoop I+1}
      else
	 nil
      end
   end
in
   {CreateLoop 1}
end

declare
fun {Stats University}
   fun {StatsLoop University State}
      case University#State
      of nil#_ then {AdjoinAt State average {IntToFloat State.beers}/{IntToFloat State.students}}
      [] (Student|Ur)#stats(students:S beers:B average:A minimum:Minimum maximum:Maximum)
      then Beers in
	 {Send Student ask(howmany:Beers)}
	 {Wait Beers}
	 {StatsLoop Ur stats(students:S+1
			     beers:B+Beers
			     average:A
			     minimum:{Min Beers Minimum}
			     maximum:{Max Beers Maximum})
	 }
      end
   end
in
   {StatsLoop University stats(students:0 beers:0 average:0.0 minimum:23 maximum:0)}
end

{Browse {Stats {CreateUniversity 7}}}

% This version uses asynchronous RMI with callback.
declare
fun {CreateUniversity Size}
   fun {StudentCallBack}
      S
   in
      thread
	 for ask(howmany:P) in S do
	    {Send P {OS.rand} mod 24}
	 end
      end
      {NewPort S}
   end
   fun {CreateLoop I}
      if I =< Size then
	 {StudentCallBack}|{CreateLoop I+1}
      else
	 nil
      end
   end
in
   {CreateLoop 1}
end

declare
fun {Stats University}
   fun {StatsLoop In State}
      case In#State
      of (Beers|Inr)#stats(students:S beers:B av:A min:Mi max:Ma)
      then NewState in
	 NewState = stats(
		       students:S+1
		       beers:B+Beers
		       av:(A*{IntToFloat S}+{IntToFloat Beers})/{IntToFloat (S+1)}
		       min:{Min Mi Beers}
		       max:{Max Ma Beers})
	 if S+1 == NOS then
	    NewState
	 else
	    {StatsLoop Inr NewState}
	 end
      end
   end
   fun {AskLoop}
      for Student in University do
	 {Send Student ask(howmany:P)}
      end
      {Length University}
   end
   P In R NOS
in
   thread R = {StatsLoop In stats(students:0 beers:0 av:0.0 min:23 max:0)} end
   P = {NewPort In}
   NOS = {AskLoop}
   {Wait R}
   R
end

{Browse {Stats {CreateUniversity 7}}}

% 3
declare
fun {NewPortObject Behaviour Init}
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then
	 {MsgLoop S2 {Behaviour Msg State}}
      [] nil then skip
      end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end
fun {Porter}
   fun {Transition Msg People}
      case Msg
      of getIn(N) then People+N
      [] getOut(N) then People-N
      [] getCount(N) then N = People People
      end
   end
in
   {NewPortObject Transition 0}
end

P = {Porter}
{Browse {Send P getCount($)}} % Should be 0.
{Send P getIn(3)}
{Browse {Send P getCount($)}} % Should be 3.
{Send P getOut(2)}
{Browse {Send P getCount($)}} % Should be 1.

% 4
declare
fun {NewPortObject Behaviour Init}
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then
	 {MsgLoop S2 {Behaviour Msg State}}
      [] nil then skip
      end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end
fun {NewStack}
   fun {Transition Msg Stack}
      case Msg
      of push(X) then X|Stack
      [] pop(?X) then
	 if Stack == nil then X = nil Stack
	 else X = Stack.1 Stack.2 end
      [] isempty(?X) then
	 if Stack == nil then X = true
	 else X = false
	 end
	 Stack
      end
   end
in
   {NewPortObject Transition nil}
end

proc {Push S X}
   {Send S push(X)}
end

fun {Pop S}
   local X in
      {Send S pop(X)}
      {Wait X}
      X
   end
end

fun {IsEmpty S}
   local X in
      {Send S isempty(X)}
      {Wait X}
      X
   end
end

S = {NewStack}
{Push S a}
{Push S b}
{Browse {IsEmpty S}} % false
{Browse {Pop S}} % b
{Browse {Pop S}} % a
{Browse {Pop S}} % nil
{Browse {IsEmpty S}} % true

% 5
declare
fun {NewPortObject Behaviour Init}
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then
	 {MsgLoop S2 {Behaviour Msg State}}
      [] nil then skip
      end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end
fun {NewQueue}
   fun {Transition Msg State}
      case Msg
      of enqueue(X) then
	 {Append State [X]}
      [] dequeue(?X) then
	 if State == nil then
	    X = nil
	    nil
	 else
	    X = State.1
	    State.2
	 end
      [] getelements(?X) then
	 X = State
	 State
      end
   end
in
   {NewPortObject Transition nil}
end

proc {Enqueue Q X}
   {Send Q enqueue(X)}
end

fun {Dequeue Q}
   local X in
      {Send Q dequeue(X)}
      {Wait X}
      X
   end
end

fun {GetElements Q}
   local Elems in
      {Send Q getelements(Elems)}
      {Wait Elems}
      Elems
   end
end

fun {IsEmpty Q}
   local X in
      {Send Q getelements(X)}
      {Wait X}
      X == nil
   end
end

Q = {NewQueue}
{Enqueue Q a}
{Enqueue Q b}
{Browse {IsEmpty Q}} % false
{Browse {GetElements Q}} % [a b]
{Browse {Dequeue Q}} % a
{Browse {Dequeue Q}} % b
{Browse {Dequeue Q}} % nil
{Browse {IsEmpty Q}} % true

% 6
declare
fun {NewPortObject Behaviour Init}
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then NewState in
	 NewState = {Behaviour Msg State}
	 {Send OutPort NewState}
	 {MsgLoop S2 NewState}
      [] nil then skip
      end
   end
   In Out OutPort
in
   thread {MsgLoop In Init} end
   OutPort = {NewPort Out}
   ports('in':{NewPort In} out:Out)
end

fun {AddOcc Xs O}
   case Xs
   of nil then [O#1]
   [] (R#Y)|Xr then
      if O == R then (R#Y+1)|Xr
      else (R#Y)|{AddOcc Xr O} end
   end
end

fun {Transition M State}
   {AddOcc State M}
end

fun {Counter ?Output}
   In Out in
   ports('in':In out:Out) = {NewPortObject Transition nil}
   Output = Out
   In
end

