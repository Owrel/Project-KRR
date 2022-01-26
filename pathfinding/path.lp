
% # transforming to graph
maxstep(54).

node(N,X,Y) :- init(object(node,N),value(_,(X,Y))).
edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), X-X' <=1, X-X' >=-1, Y-Y' == 0. 
edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), Y-Y' <=1, Y-Y' >=-1, X-X' == 0. 
edge(N,N) :- node(N,X,Y).
edge(X,Y, X',Y') :- node(N,X,Y), node(N',X',Y'), edge(N,N').


% # Init goal in initialposition
end(N,X,Y) :- init(object(shelf,N), value(at,(X,Y))).
init(N,X,Y) :- init(object(robot,N), value(at,(X,Y))), pathfor(N).


% # Computing path by propagation
{path(X,Y,X',Y',N,0): edge(X,Y,X',Y') } =1:- init(N,X,Y).
{path(X,Y,X',Y',N,S+1): edge(X,Y,X',Y') } =1:- path(_,_,X,Y,N,S), (X,Y) != (EX,EY), end(N,EX,EY), maxstep(MS), S<MS.

goalReached(N) :- path(_,_,X,Y,N,S), (X,Y) == (EX,EY), end(N,EX,EY).
:- path(X,Y,X',Y',N,S), path(X',Y',X,Y,N,_).
:- init(N,_,_), not goalReached(N).
:- path(X,Y,X',Y',N,_),  path(X'',Y'',X',Y',N,_), (X,Y) != (X'',Y'').

step(N,0,X,Y) :- path(X,Y,_,_,N,0).
step(N,S,X,Y) :- path(X,Y,_,_,N,S), S!=0.
step(N,S+1,X',Y') :- step(N,S,X,Y),path(X,Y,X',Y',N,S), end(N,X',Y').


#show step/4.
#show path(X,Y,X',Y',N) : path(X,Y,X',Y',N,S). 
#minimize {1,S: path(X,Y,X',Y',N,S)}.




