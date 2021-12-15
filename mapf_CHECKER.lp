% How the plan should look like for the solver/viz

% Initializing the global deadline


value(max_dl,10).


node(N,X,Y) :- init(object(node,N),value(_,(X,Y))).
goal(X,Y,N) :- init(object(shelf,N), value(at,(X,Y))).


edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), X-X' <=1, X-X' >=-1, Y-Y' == 0. 
edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), Y-Y' <=1, Y-Y' >=-1, X-X' == 0. 
edge(N,N) :- node(N,X,Y).

edge(X,Y, X',Y') :- node(N,X,Y), node(N',X',Y'), edge(N,N').
edge(X,Y, X',Y') :- node(N,X,Y), node(N',X',Y'), edge(N,N').


path(R,X,Y,0,DL) :- init(object(robot,R), value(at,(X,Y))), init(object(robot,R), value(max_dl,DL)).
{path(R,X',Y',S+1,DL)}1 :- path(R,X,Y,S,DL),edge(X,Y,X',Y'),  S < DL, goal(GX,GY,R), (GX,GY)!=(X,Y).
:- path(R,X,Y,S,_), path(R,X',Y',S,_), (X,Y)!= (X',Y'). % Can't move at two direction at the same time step




:- path(R,X,Y,S,_), goalreached(R',S',X',Y'), (X,Y) == (X',Y'), S > S'. % Agent doesn't desapear after reaching a goal => robot cann'ot mve on each other





goalreached(R,S,X,Y) :- path(R,X,Y,S,_), goal(X,Y,_). % Not target assignment
:- path(R,_,_,S+1,_), goalreached(R,S,_,_).


% :- path(R,X,Y,S,_), goal(X,Y,R), path(R,_,_,S',_), S'>S. % Stop moving after reaching a goal
% goalreached(R,S,X,Y) :- path(R,X,Y,S,_), goal(X,Y,R) . % Target assignment


:- goalreached(R,_,X,Y),goalreached(R',_,X,Y), R != R'. % No same goal for different robot
% :- not goalreached(R,_,_,_), init(object(robot,R), _). % Uncomment to have classic mapf :)


% movement constaint
:- path(R,X,Y,S,_), path(R',X,Y,S,_), R != R'.
:- path(R,X,Y,S,_), path(R,X',Y',S+1,_), R != R' , path(R',X',Y',S,_), path(R',X,Y,S+1,_).

occurs(object(robot, R), action(move,(X'-X, Y'-Y)),S) :- path(R,X,Y,S,_),path(R,X',Y',S+1,_).

#show occurs/3.

#show goalreached/4.

% #maximize{1@1,R : path(R,X,Y,_,_), opath(R,X,Y,T), T>=1}.
#maximize{ 1@3,R : goalreached(R,S,_,_) ; 0@2,0}. % Try to maximize the number of agent that reach a goal ('; 0@2,0' makes the program not searching for all the path if no optimization exist)
#minimize{ S@2,R  : goalreached(R,S,_,_) ; 0@1,0}.

