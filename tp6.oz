% Aux function
declare
proc {Touch L N}
   if N==0 then skip
   else {Touch L.2 N-1}
   end
end

% 1.a
declare
fun lazy {Gen I}
   I|{Gen I+1}
end

% 1.b
local S in
   S = {Gen 0}
   {Browse S}
   {Browse S.2.2.1}
end

% 1.c
declare
fun {GiveMeNth N L}
   if N==1 then L.1
   else {GiveMeNth N-1 L.2}
   end
end

{Browse {GiveMeNth 3 {Gen 0}}}

% 2.a
declare
fun lazy {Filter Xs P}
   case Xs
   of nil then nil
   [] X|Xr then
      if {P X} then
	 X|{Filter Xr P}
      else
	 {Filter Xr P}
      end
   end
end

fun {IsPrime X}
   fun {Aux X P}
      if P >= X then true
      elseif X mod P == 0 then false
      else {Aux X P+1}
      end
   end
in
   {Aux X 2}
end

fun lazy {Primes}
   {Filter {Gen 2} IsPrime}
end

{Browse {Primes}.1}
{Browse {Primes}.2.1}
{Browse {Primes}.2.2.1}
{Browse {Primes}.2.2.2.1}
{Browse {Primes}.2.2.2.2.1}

% 2.b
declare
fun lazy {Sieve Xs}
   case Xs
   of nil then nil
   [] X|Xr then
      X|{Sieve {Filter Xr fun {$ Y} Y mod X \= 0 end}}
   end
end

% 3
declare
fun {ShowPrimes N}
   fun {Aux N L}
      if N==0 then nil
      else
	 case L
	 of nil then nil
	 [] H|T then H|{Aux N-1 T}
	 end
      end
   end
in
   {Aux N {Primes}}
end

{Browse {ShowPrimes 10}}

% 4.a
declare
fun {Gen I N}
   {Delay 50}
   if I==N then [I] else I|{Gen I+1 N} end
end
fun {Filter L F}
   case L
   of nil then nil
   [] H|T then
      if {F H} then H|{Filter T F} else {Filter T F} end
   end
end
fun {Map L F}
   case L
   of nil then nil
   [] H|T then {F H}|{Map T F}
   end
end

declare Xs Ys Zs
{Browse Zs}
thread {Gen 1 100 Xs} end
thread {Filter Xs fun {$ X} (X mod 2)==0 end Ys} end
thread {Map Ys fun {$ X} X*X end Zs} end

% 4.b
declare
fun lazy {Gen I N}
   {Delay 50}
   if I==N then [I] else I|{Gen I+1 N} end
end
fun lazy {Filter L F}
   case L
   of nil then nil
   [] H|T then
      if {F H} then H|{Filter T F} else {Filter T F} end
   end
end
fun lazy {Map L F}
   case L
   of nil then nil
   [] H|T then {F H}|{Map T F}
   end
end

declare Xs Ys Zs
{Browse Zs}
{Gen 1 100 Xs}
{Filter Xs fun {$ X} (X mod 2)==0 end Ys}
{Map Ys fun {$ X} X*X end Zs}
{Touch Zs 25}

% 5.a
% The complexity is quadratic:
% we have to sort the array using insertion sort, taking O(n^2) time,
% then we have to take the smallest element of that array.

% 5.b
% The complexity is linear (on average):
% we have to split the list according to a pivot, which is linear
% then recursively split the list of "smaller" items
% until we are left with a list of size 1 containing the minimum.
% This means we do n + n/2 + n/4 + ... + 2  = O(n) operations on average.

% 6
% It doesn't make a difference,
% as lazy evaluation still requires the entire list to be sorted
% because of how {Last Xs} is implemented.

% 7
% Cf. tp5.oz

% 8.a
