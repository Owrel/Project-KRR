
% # transforming to graph
node(N,X,Y) :- init(object(node,N),value(_,(X,Y))).
edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), X-X' <=1, X-X' >=-1, Y-Y' == 0. 
edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), Y-Y' <=1, Y-Y' >=-1, X-X' == 0. 
edge(N,N) :- node(N,X,Y).
edge(X,Y, X',Y') :- node(N,X,Y), node(N',X',Y'), edge(N,N').
edge(X,Y, X',Y') :- node(N,X,Y), node(N',X',Y'), edge(N,N').

% # Init goal in initialposition
end(N,X,Y) :- init(object(shelf,N), value(at,(X,Y))).
init(N,X,Y) :- init(object(robot,N), value(at,(X,Y))).


% # Computing path by propagation
{path(X,Y,X',Y',N): edge(X,Y,X',Y') } =1:- init(N,X,Y) .
{path(X,Y,X',Y',N): edge(X,Y,X',Y') } =1:- path(_,_,X,Y,N), (X,Y) != (EX,EY), end(N,EX,EY).

goalReached(N) :- path(_,_,X,Y,N), (X,Y) == (EX,EY), end(N,EX,EY).

:- init(N,_,_), not goalReached(N).

maxstep(50).

% # From propagation path, create the time step
step(N,0,X,Y) :- init(N,X,Y).
step(N,T+1,X',Y') :- step(N,T,X,Y), path(X,Y,X',Y',N), T<M, maxstep(M). 


% # Minimizing the length of the path
#minimize {1,N,T : step(N,T,_,_)}.




