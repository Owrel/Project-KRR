% Definition of global variable
time(1..30).

% Translation
node(X,Y) :- init(object(node,N),value(_,(X,Y))).
end(N,X,Y) :- init(object(shelf,N), value(at,(X,Y))).
init(N,X,Y) :- init(object(robot,N), value(at,(X,Y))).
robot(N) :- init(N,_,_).


% Possiple direction
direction(1,0). direction(-1,0). direction(0,1). direction(0,-1).

% Conflict Detection (on original path)
conflict(N,N',T)    :- step(N,T,X,Y),   step(N',T,X,Y),     N!=N', not conflict(N',N,T). 
conflict(N,N',T)    :- step(N,T+1,X,Y), step(N',T,X,Y),     step(N,T,X',Y'), step(N',T+1,X',Y'), N!=N', not conflict(N',N,T).
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
% :- new_step(X,Y,T,N), new_step(X',Y',T+1,N), new_step(X',Y',T,N'), new_step(X,Y,T+1,N'), N!=N', (X,Y)!=(X',Y').

% additionnal node
% diamond
diamond_size(1).
diamond_require(X,Y,N) :- conflict(N,N',T), step(N,T,X,Y).
diamond(X,Y,N,0) :- diamond_require(X,Y,N), diamond_size(MS), MS>0.
diamond(X+DX,Y+DY,N,T+1) :- diamond(X,Y,N,T), direction(DX,DY), node(X+DX,Y+DY), 
                            diamond_size(MS), T<MS,
                            time(T'), T'!=T.

diamond(X,Y,N) :- diamond(X,Y,N,_).
available_node(X,Y,N) :- diamond(X,Y,N).





% Showing section
%translation to occurs
#show  occurs(object(robot,N), action(move,(DX,DY)),     T) :   move(DX,DY,N,T).
#show.
















