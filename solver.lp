
% Building graph
node(N,X,Y) :- init(object(node,N),value(_,(X,Y))).
goal(X,Y,N) :- init(object(shelf,N), value(at,(X,Y))).
maxstep(50).
edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), X-X' <=1, X-X' >=-1, Y-Y' == 0. 
edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), Y-Y' <=1, Y-Y' >=-1, X-X' == 0. 
edge(N,N) :- node(N,X,Y).

edge(X,Y, X',Y') :- node(N,X,Y), node(N',X',Y'), edge(N,N').
edge(X,Y, X',Y') :- node(N,X,Y), node(N',X',Y'), edge(N,N').

% Finding path for each agents
path(R,X,Y,0) :- init(object(robot,R), value(at,(X,Y))).


% {path(R,X',Y',S+1)}1 :- path(R,X,Y,S),edge(X,Y,X',Y'), maxstep(MS), S<MS,  goal(GX,GY,R), (GX,GY)!=(X,Y).
% :- path(R,X,Y,S), path(R,X',Y',S), (X,Y)!= (X',Y'). % Can't move at two direction at the same time step
% goalreached(R,S,X,Y) :- path(R,X,Y,S), goal(X,Y,R). 
% :- path(R,_,_,S+1), goalreached(R,S,_,_).
% :- not goalreached(R,_,_,_), init(object(robot,R), _).
% #show path/4.


% #minimize{ S@1,R  : goalreached(R,_,_,S)}.