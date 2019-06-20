% 1
declare
A = {NewCell 0}
B = {NewCell 0}
T1 = @A
T2 = @B
{Browse A == B} % Prints false.
{Browse T1 == T2} % Prints true.
{Browse T1 = T2} % Prints 0.

A := @B
{Browse A == B} % Prints false.

% 2
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

fun {NewCell Init}
   fun {F X State}
      case X
      of access(R) then R = State
      [] assign(E) then E
      end
   end
in
   {NewPortObject F Init}
end

proc {Access C ?R}
   {Send C access(R)}
end

proc {Assign C E}
   {Send C assign(E)}
end

% 3
declare
fun {NewPort Xs}
   {NewCell Xs}
end
proc {Send P M}
   Xr
in
   {Exchange P M|Xr Xr}
end

% 4
declare
fun {NewPortClose Xs}
   {NewCell Xs}
end
proc {Send P M}
   Xr
in
   {Exchange P M|Xr Xr}
end
proc {Close P}
   @P = nil
end

% 5
declare
fun {Q A B}
   local C in
      C = {NewCell 0}
      for I in A..B do
	 C := @C + I
      end
      @C
   end
end

{Browse {Q 3 5}}

% 6.a
declare
class Counter
   attr C
   meth init
      C := 0
   end
   meth add(N)
      C := @C + N
   end
   meth read($)
      @C
   end
end

fun {Q A B}
   local C in
      C = {New Counter init}
      for I in A..B do
	 {C add(I)}
      end
      {C read($)}
   end
end

{Browse {Q 3 5}}

% 6.b
declare
class Port
   attr msg
   meth init(Msg)
      msg := {NewCell Msg}
   end
   meth send(M)
      Mr
   in
      {Exchange @msg M|Mr Mr}
   end
end

fun {NewPort Msg}
   {New Port init(Msg)}   
end

proc {Send P M}
   {P send(M)}
end

% 6.c
declare
class PortClose from Port
   meth close
      @@msg = nil
   end
end

fun {NewPortClose Msg}
   {New PortClose init(Msg)}
end
proc {Close P}
   {P close}
end

% 7
declare
fun {NewCell X}
   X|_
end

proc {Access C R}
   if {Value.isDet C.2} then {Access C.2 R}
   else  R = C.1
   end
end

proc {Assign C E}
   if {Value.isDet C.2} then {Assign C.2 E}
   else C.2 = E|_
   end
end







