%% Interacting with Browser
% 2.
{Browse 'Hello Nurse'}
{Browse "Hello nurse"}

% 3.
% a
local
   X=x Y=y Z=z
in
   {Browse [X Y Z]}
end
% b
local
   X=x Y=y Z=z
in
   {Browse X#Y#Z}
end

%% Detecting Warnings and Errors
% 4.
local
   F1 = fun {$ X} X*X end
   F2 = fun {$ X} X+X end
in
   {Browse ({F1 3} - {F2 3}) + 4}
end

%% Using Oz as a calcutor
% 5.
declare
fun {Roots A B C}
   [(~B + {Sqrt B*B-4.0*A*C})/(2.0*A) (~B - {Sqrt B*B-4.0*A*C})/(2.0*A)] 
end
{Browse {Roots 1.0 5.0 ~150.0}}

% 6.
% a
local X in
   X = a
   X = b % can't work, a =/= b
end
local X in
   X = a
   local X in
      X = b % masked variable, works now
   end
end

% b
local
   Y = 1
   X = 1
in
   local
      Y = 2
   in
      {Browse [X Y]} % prints [1 2]
   end
   {Browse [X Y]} % prints [1 1]
end

%% Working with Lists and Records
% 7.
% a: 4 elements
% b: 2 elements
% c: L.1.2.1
% d: {Nth {Nth L 1} 2}
% e
{Browse '#'(a:5 b:2 3 4)=='#'(1:3 b:2 a:5 2:4)} % prints true, the records are the same
% f
declare
R='#'(a [b '#'(c d) e] f)
{Browse R.2.2.1.2}

% 8.
% a
declare
X=a(1 X)
{Browse X}
% b
X = b(c d)
Y = d(b e)
Z = a(X Y)

% 9.
% a
local X Y in
   X = 1|2|Y
   X = Y
   {Browse X.2.2.1} % prints 1
end
% b
local X Y Z in
   X = 1|X
   Y = X|Z
   Z = 2|3|4|nil
   {Browse Y.1.2.1} % prints 1
end
% c
local X Y Z in
   X = a(b X)
   Y = c(X Z)
   Z = d(e f g h)
   {Browse Y.1.2.1} % prints b
end