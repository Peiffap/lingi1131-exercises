% 1a
% After execution, X = 1, Y = 2, Z = 2.

local X Y Z in
   thread if X == 1 then Y = 2 else Z = 2 end end
   thread if Y == 1 then X = 1 else Z = 2 end end
   X = 1
   {Browse X}
   {Browse Y}
   {Browse Z}
end

% 1b
% After execution, X = 2, Y = _, Z = 2.

local X Y Z in
   thread if X == 1 then Y = 2 else Z = 2 end end
   thread if Y == 1 then X = 1 else Z = 2 end end
   X = 2
   {Browse X}
   {Browse Y}
   {Browse Z}
end

% 2
% The program waits until X is bound,
% checks whether X is equal to 42 then executes <s>.

% 3
declare A B C D in
thread D = C + 1 end % 1
thread C = B + 1 end % 2
thread A = 1 end % 3
thread B = A + 1 end % 4
{Browse D}

% Threads are created in the order 1 - 2 - 3 - 4
% (but they are not necessarily executed in this order).
% Threads are evaluated in the order 3 - 4 - 2 - 1.

% 4
declare
proc {Split L ?L1 ?L2}
   case L of nil then
      L1 = nil
      L2 = nil
   [] H|nil then
      L1 = [H]
      L2 = nil
   [] H1|H2|T then T1 T2 in
      L1 = H1|T1
      L2 = H2|T2
      {Split T T1 T2}
   end
end
fun {Merge1 L1 L2}
   case L1|L2 of (H1|T1)|(H2|T2) andthen H1 < H2 then H1|{Merge1 T1 L2}
   [] (H1|T1)|(H2|T2) then H2|{Merge1 L1 T2}
   [] L|nil then L
   [] nil|L then L
   [] nil|nil then nil
   end
end
fun {MergeSort L}
   L1 L2
in
   case L
   of nil then nil
   [] [X] then [X]
   else
      {Split L L1 L2}
      {Merge1 thread {MergeSort L1} end thread {MergeSort L2} end}
   end
end

{Browse {MergeSort [9 8 7 6 5 4 3 2 1]}}

% Number of threads at each length:
%                 0 |            0
%                 1 |            0
%                 2 |            2
%                 3 |            4
%                 4 |            6
%                 5 |            8
%                 6 |            10
%                 7 |            12
%                 : |            :
%                 n |            max(2n-2, 0)

% The number of created threads is equal to 2n-2.
% Theoretically, we'd expect it to be 1 + 2 + 4 + ... + n = 2n - 1,
% but since lists of length 1 don't require the creation of an extra thread,
% we are always one thread below that prediction.

% 5
declare
fun {Prod N Curr}
   {Delay 100}
   if Curr == N+1 then nil
   else Curr|{Prod N Curr+1}
   end
end
fun {Cons S Acc}
   case S of X|T then
   X+Acc|{Cons T X+Acc}
   [] nil then
      nil
   end
end

declare S1 S2 in
thread S1 = {Prod 25 1} end
thread S2 = {Cons S1 0} end
{Browse S1}
{Browse S2}

% 6
declare
fun {Prod N Curr}
   {Delay 100}
   if Curr == N+1 then nil
   else Curr|{Prod N Curr+1}
   end
end
fun {Filter L}
   case L of nil then nil
   [] H|T then
      if H mod 2 == 0 then {Filter T}
      else H|{Filter T}
      end
   end
end
fun {Cons S Acc}
   case S of X|T then
   X+Acc|{Cons T X+Acc}
   [] nil then
      nil
   end
end

declare S1 S2 S3 in
thread S1 = {Prod 10000 1} end
thread S2 = {Filter S1} end
thread S3 = {Cons S2 0} end
{Browse S1}
{Browse S2}
{Browse S3}

% 7
% A lot, probably.

% 8
declare
proc {Ping L}
   case L of H|T then T2 in
      {Delay 500} {Browse ping}
      T = _|T2
      {Ping T2}
   end
end

proc {Pong L}
   case L of H|T then T2 in
      {Browse pong}
      T = _|T2
      {Pong T2}
   end
end

declare L in
thread {Ping L} end
thread {Pong L.2} end
L = _|_
{Browse L}

% The statement is wrong,
% presumably the error was to write "thread {Pong L} end".
% When you do this, both threads can execute once before becoming blocked,
% hence the program output is "pong ping".
% The fix is to write "thread {Pong L.2} end",
% which makes the program run correctly.