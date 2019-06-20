% 1
declare
proc {NewPort S P}
   P = {NewCell S}
end
proc {Send P Msg}
   NewTail
in
   @P = Msg|NewTail
   P := NewTail
end

% This implementation is not correct as the two operations in {Send} need to be atomic.
% In order to do this, one can replace them using the atomic Exchange operation,
% hence there is no need to use locks.
declare
proc {Send P Msg}
   NewTail
in
   {Exchange P Msg|NewTail NewTail}
end

% 2
declare
fun {IncrementBad C}
   X
in
   X = C := X+1
   C
end

% In the kernel language, this becomes
declare
proc {IncrementBad C ?R}
   X Tmp
in
   Tmp = X+1
   X = C := Tmp
   R = C
end
% This shows that one needs to know X before the exchange operation, which is impossible.
% Instead, we have to do it the other way around.
declare
fun {Increment C}
   X New
in
   X = C := New
   New = X + 1
   C
end

C = {NewCell 0}
{Browse @{Increment C}}

% 3
declare
class BankAccount
   attr bal
   meth init
      bal := {NewCell 0}
   end
   meth deposit(Amount)
      Old New
   in
      Old = @bal := New
      New = Old + Amount
   end
   meth withdraw(Amount)
      {self deposit(~Amount)}
   end
   meth getBalance($)
      @@bal
   end
end

Account = {New BankAccount init}
X1 X2
thread {Account deposit(420)} X1 = unit end
thread {Account deposit(69)}  X2 = unit end
{Wait X1} {Wait X2}
{Browse {Account getBalance($)}}

% 4
declare
Lock = {NewLock}
class BankAccount
   attr bal
   meth init
      bal := {NewCell 0}
   end
   meth deposit(Amount)
      Old New
   in
      Old = @bal := New
      New = Old + Amount
   end
   meth withdraw(Amount)
      {self deposit(~Amount)}
   end
   meth getBalance($)
      @@bal
   end
   meth transfer(Acc Amount)
      lock Lock then
	 {self withdraw(Amount)}
	 {Acc deposit(Amount)}
      end
   end
end

Acc1 = {New BankAccount init}
Acc2 = {New BankAccount init}
X1 X2 X3
thread {Acc1 deposit(420)} X1 = unit end
thread {Acc2 deposit(69)}  X2 = unit end
{Wait X1} {Wait X2}
thread {Acc1 transfer(Acc2 100)} X3 = unit end
{Wait X3}
{Browse {Acc1 getBalance($)}}
{Browse {Acc2 getBalance($)}}

% 5
% Only the first implementation is correct.
% Instead of using two separate actions,
% one should use atomic exchange, so that no scheduling errors can occur.
% In the first case, the lock makes sure that even if
% the running thread switches between the atomic operations,
% it still won't enter the critical section twice,
% but using two different locks does nothing to stop other threads
% erasing the work of the current thread as soon as the scheduler switches.