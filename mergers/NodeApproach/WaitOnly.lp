% Definition of global variable
time(1..maxtime).

% Translation
node(X,Y) :- init(object(node,N),value(_,(X,Y))).
end(N,X,Y) :- init(object(shelf,N), value(at,(X,Y))).
init(N,X,Y) :- init(object(robot,N), value(at,(X,Y))).
robot(N) :- init(N,_,_).


% Possiple direction
direction(1,0). direction(-1,0). direction(0,1). direction(0,-1).


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




% Showing section
%translation to occurs
#show  occurs(object(robot,N), action(move,(DX,DY)),     T) :   move(DX,DY,N,T).
#show new_step(N,T,X,Y) : position(X,Y,N,T).
#show goalReached(N,T) : picked(N,T).
#show.
















