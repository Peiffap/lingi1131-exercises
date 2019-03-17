% 1.a
declare
proc {Max L ?R1}
   proc {MaxLoop L M ?R2}
      case L of nil then R2 = M
      [] H|T then
	 if M > H then {MaxLoop T M R2}
	 else {MaxLoop T H R2}
	 end
      end
   end
in
   if L == nil then R1 = error
   else {MaxLoop L.2 L.1 R1}
   end
end

% 1.b
declare
fun {Fact N}
   fun {FactList N Acc1 Acc2}
      if N == Acc1-1 then nil
      else Acc2|{FactList N Acc1+1 Acc2*(Acc1+1)}
      end
   end
in
   {FactList N 1 1}
end

% 2.a.i
% No, it isn't tail recursive as all the additions get computed at the end of the recursive calls, meaning this call isn't the last computation to be made by the computer.

% 2.a.ii
declare
fun {Sum N}
   fun {SumAux N Acc}
      if N == 0 then Acc
      else {SumAux N-1 Acc+N}
      end
   end
in
   {SumAux N 0}
end

% 2.b.i

% The function is tail recursive since the last call is the recursive call.

% 2.b.ii

% The function is tail recursive, no adaptation needed.

% 2.c

% No need, it is already tail-recursive.

% 3.a
local
   X Y
in
   {Browse 'hello nurse'}
   X=2+Y
   {Browse X}
   Y = 40
end
% Does not work, since Y has no value associated to it at the time of the second line, which calls a blocking function (+)

% 3.b
local
   X Y
in
   {Browse 'hello nurse'}
   X= sum(2 Y)
   {Browse X}
   Y = 40
end
% Shows the sum as "sum(2 40)", meaning the values have been updated. The call to sum is not blocking.

% 4.a
declare
proc {ForAllTail Xs P}
   case Xs of nil then skip
   [] H|T then
      {P Xs}
      {ForAllTail T P}
   end
end

proc {Pairs L E}
   case L of nil then skip
   [] H|T then
      {Browse pair(H E)}
      {Pairs T E}
   end
end
{ForAllTail [a b c d] proc {$ Tail} {Pairs Tail.2 Tail.1} end}

% 4.b
declare
fun {GetElementsInOrder Tree}
   if Tree.left == nil andthen Tree.right == nil then [Tree.info]
   elseif Tree.left == nil then Tree.info|{GetElementsInOrder Tree.right}
   elseif Tree.right == nil then {Append {GetElementsInOrder Tree.left} [Tree.info]}
   else {Append {Append {GetElementsInOrder Tree.left} [Tree.info]} {GetElementsInOrder Tree.right}}
   end
end

Tree = tree(info:10
	    left:tree(info:7
		      left:nil
		      right:tree(info:9
				 left:nil
				 right:nil))
	    right:tree(info:18
		       left:tree(info:14
				 left:nil
				 right:nil)
		       right:nil))

{Browse {GetElementsInOrder Tree}}

% 5.a
declare
fun {Fib N}
   if N < 2 then 1
   else {Fib N-2} + {Fib N-1}
   end
end

{Browse {Fib 35}}

% 5.b
declare
fun {Fib N}
   fun {FibAux N Acc1 Acc2}
      if N == 2 then Acc1+Acc2
      else {FibAux N-1 Acc1+Acc2 Acc1}
      end
   end
in
   {FibAux N 1 1}
end

{Browse {Fib 35}}
{Browse {Fib 100}}

% 6
local Add AddDigits in
   fun {AddDigits D1 D2 CI}
      if D1+D2+CI == 3 then 'output'(sum:1 carry:1)
      elseif D1+D2+CI == 2 then 'output'(sum:0 carry:1)
      elseif D1+D2+CI == 1 then 'output'(sum:1 carry:0)
      else 'output'(sum:0 carry:0)
      end
   end

   fun {Add B1 B2}
      fun {AddReverse B1 B2 CI}
	 if B1 == nil andthen CI == 1 then CI|nil
	 else
	    local Res in
	       Res = {AddDigits B1.1 B2.1 CI}
	       Res.sum|{AddReverse B1.2 B2.2 Res.carry}
	    end
	 end
      end
   in
      {Reverse {AddReverse {Reverse B1} {Reverse B2} 0}}
   end
   {Browse {AddDigits 1 0 0}}
   {Browse {AddDigits 1 1 0}}
   {Browse {AddDigits 1 0 1}}
   {Browse {AddDigits 1 1 1}}
   {Browse {Add [1 1 0 1 1 0] [0 1 0 1 1 1]}}
end

% 7
declare
fun {Filter L F}
   case L of nil then nil
   [] H|T then
      if {F H} then H|{Filter T F}
      else {Filter T F}
      end
   end
end

{Browse {Filter [1 2 3 4 5 6 7 8] fun {$ X} X >= 3 end}}

% 8
fun {FilterEven L}
   {Filter L fun {$ X} X mod 2 == 0 end}
end

{Browse {FilterEven [1 2 3 4 5 6 7 8 9]}}

% 9
% Yes, it is. Higher-order programming means that one of the arguments of a function/procedure is a function/procedure itself, which is the case in exo 4a.

% 10
declare
fun {Flatten List}
   case List of H|nil then {Flatten H}
   [] H|T then {Append {Flatten H} {Flatten T}}
   [] X then [X]
   end
end

{Browse {Flatten [a [b [c d]] e [[[f]]]]}}

% 11
declare
proc {Fact N ?R}
   if N == 1 then R = [N]
   else
      local Out in
	 {Fact N-1 Out}
	 R = N*Out.1|Out
      end
   end
end

local R in
   {Fact 4 R}
   {Browse R}
end

% 12
declare
fun {DictionaryFilter D F}
   if D.left == leaf andthen D.right == leaf then
      if {F D.info} == true then
	 [D.key#D.info]
      else
	 nil
      end
   elseif D.left == leaf then
      if {F D.info} == true then
	 {Append [D.key#D.info] {DictionaryFilter D.right F}}
      else
	 {DictionaryFilter D.right F}
      end
   elseif D.right == leaf then
      if {F D.info} == true then
	 {Append {DictionaryFilter D.left F} [D.key#D.info]}
      else
	 {DictionaryFilter D.left F}
      end
   else
      if {F D.info} == true then
	 {Append {Append {DictionaryFilter D.left F} [D.key#D.info]} {DictionaryFilter D.right F}}
      else
	 {Append {DictionaryFilter D.left F} {DictionaryFilter D.right F}}
      end
   end
end

Class=dict(key:10
	   info:person('Christian' 19)
	   left:dict(key:7
		     info:person('Denys' 25)
		     left:leaf
		     right:dict(key:9
				info:person('David' 7)
				left:leaf
				right:leaf))
	   right:dict(key:18
		      info:person('Rose' 12)
		      left:dict(key:14
				info:person('Ann' 27)
				left:leaf
				right:leaf)
		      right:leaf))
fun {Old Info}
   Info.2 > 20
end

{Browse {DictionaryFilter Class Old}}

% 13
declare
fun {Length L Acc}
   case L of nil then Acc
   [] H|T then {Length T Acc+1}
   [] X then 0
   end
end
fun {Matcher Pattern Value}
   if {Length Pattern 0} == {Length Value 0} then
      case Pattern|Value of nil|nil then true
      [] (HP|TP)|(HV|TV) then
	 if {Matcher HP HV} == true orelse HP == x then {Matcher TP TV}
	 else false
	 end
      [] X|X then true
      [] X|Y then false
      end
   else
      false
   end
end

{Browse {Matcher [a x a] [a b a]}}
{Browse {Matcher [a x a] [a b d]}}
{Browse {Matcher [a x a] [a [a b] a]}}
{Browse {Matcher [a [c x] a] [a [b c] a]}}
{Browse {Matcher [a [c x] a] [a [c b] a]}}
{Browse {Matcher x [a [c b] e]}}
{Browse {Matcher x [a [c b] x]}}