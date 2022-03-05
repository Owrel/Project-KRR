% Definition of global variable
time(1..maxtime).

% Translation
node(X,Y) :- init(object(node,N),value(_,(X,Y))).
end(N,X,Y) :- init(object(shelf,N), value(at,(X,Y))).
init(N,X,Y) :- init(object(robot,N), value(at,(X,Y))).
robot(N) :- init(N,_,_).


% Possiple direction
direction(1,0). direction(-1,0). direction(0,1). direction(0,-1).

% Conflict Detection (on original path)
node_conflict(N,N',T)    :- step(N,T,X,Y),   step(N',T,X,Y),     N!=N'.
conflict(N,N',T)    :- node_conflict(N,N',T), not node_conflict(N,N',T-1), not node_conflict(N',N,T-1).
conflict(N,N',T)    :- step(N,T+1,X,Y), step(N',T,X,Y),     step(N,T,X',Y'), step(N',T+1,X',Y'), N!=N', not conflict(N',N,T), not conflict(N,N',T-1).
conflict(N',N,T)    :- step(N,_,X,Y),   end(N',X,Y), N!=N', step(N',T,X,Y).

% Getting nodes from original path
available_node(X,Y,N) :- step(N,T,X,Y).




position(X,Y,N,0) :- init(N,X,Y).

{move(DX,DY,N,T): direction(DX,DY)}1 :- time(T),  robot(N).
%If move at time step T
position(X+DX,Y+DY,N,T) :- position(X,Y,N,T-1), move(DX,DY,N,T), available_node(X+DX,Y+DY,N).
%If no move at time step T (wait)
position(X,Y,N,T) :- position(X,Y,N,T-1), not move(_,_,N,T), time(T).


% Management of reaching the goal
{picked(N,T)} :- end(N,X,Y), position(X,Y,N,T). % target assignment


:- move(_,_,N,T), picked(N,T'), T>T'.
:- not picked(N,_), robot(N).

% Conflict management
:- {position(X,Y,N,T): robot(N)}>1, time(T), node(X,Y).
:- position(X,Y,N,T), position(X',Y',N,T+1), position(X',Y',N',T), position(X,Y,N',T+1), N!=N', (X,Y)!=(X',Y').

% additionnal node

% Corridor
corridor_size(1).
corridor_require(X,Y,N) :- step(N,_,X,Y), conflict(N,_,_).
corridor(X+DX,Y+DY,N,1,(DX,DY)) :- corridor_require(X,Y,N), corridor_size(MS), MS>0, direction(DX,DY), not step(N,_,X+DX,Y+DY), node(X+DX,Y+DY).
corridor(X+DX,Y+DY,N,S+1,(DX,DY)) :- corridor(X,Y,N,S,(DX,DY)), corridor_size(MS), S<MS,node(X+DX,Y+DY),not step(N,_,X+DX,Y+DY).

available_node(X,Y,N) :- corridor(X,Y,N,_,_).


% Showing section
%translation to occurs
#show  occurs(object(robot,N), action(move,(DX,DY)),     T) :   move(DX,DY,N,T).
#show new_step(N,T,X,Y) : position(X,Y,N,T).
#show goalReached(N,T) : picked(N,T).

#show.
















