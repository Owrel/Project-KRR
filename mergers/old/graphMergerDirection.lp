max_time(13).
% time(0..MT) :- max_time(MT).

% Actions
move(0,0).  
move(1,0). 
move(-1,0).
move(0,1).
move(0,-1).
% end actions

% Searching for old conflict
% VERTEX CONFLICT : T is different than new T.
conflict(N,N',T) :- step(N,T,X,Y), step(N',T,X,Y), N!=N'.
% Edge conflict
conflict(N,N',T) :- step(N,T+1,X,Y), step(N',T,X,Y), step(N,T,X',Y'), step(N',T+1,X',Y'), N!=N'. 


% Creating subgraph for each robot from their respective path
available_node_from_path(X,Y,N) :- path(X,Y,_,_,N).
available_node_from_path(X,Y,N) :- end(N,X,Y).
available_node(X,Y,N) :- available_node_from_path(X,Y,N).


% If needed, add node to the subgraph to solve conflicts


{additional_node(X,Y,N): node(_,X,Y), init(N,_,_), available_node(X',Y',N), |X'-X +Y'-Y| == 1, not available_node(X,Y,N'), init(N',_,_), N'!=N}. % To split


available_node(X,Y,N) :- additional_node(X,Y,N).

% An additional node have to be used at some point
additional_node_used(X,Y,N,T) :- additional_node(X,Y,N), new_step(N,T,X,Y).
additional_node_used(X,Y,N) :- additional_node_used(X,Y,N,T).
:- additional_node(X,Y,N), not additional_node_used(X,Y,N).

% An additional node can not be added after the old conflict
:- step(N,T',X,Y), conflict(N,_,T), T'>=T, additional_node(X',Y',N), |X'-X +Y'-Y| <=1. 


% Making the robot explore his subgraph
new_step(N,0,X,Y) :-    init(N,X,Y).
{new_step(N,T+1,X+A,Y+B) :  move(A,B),  available_node(X+A,Y+B,N)}=1 :- new_step(N,T,X,Y),  T<MT,   max_time(MT), not new_goalReached(N,T).
global_step(N,T,X,Y) :- new_step(N,T,X,Y).


% Checking if the robot reach his goal
{new_goalReached(N,T)} :-   new_step(N,T,X,Y),  (X,Y)==(EX,EY), end(N,EX,EY).
new_goalReached(N) :-   new_goalReached(N,T).
:-  not new_goalReached(N),  init(N,_,_).


% Managing robot robot still being at the same postision after reaching goal
after_step(N,T,X,Y) :-  new_step(N,T,X,Y),  new_goalReached(N,T).
after_step(N,T+1,X,Y) :-    after_step(N,T,X,Y),    T<MT,   max_time(MT).
global_step(N,T,X,Y) :-     after_step(N,T,X,Y).
% OPTIMISATION : we know for sure where the robot will stay, we can ground all the position already and choose which one to keep after while


% Managing conflict
new_conflict(N,N',T) :- global_step(N,T,X,Y),   global_step(N',T,X,Y), N!=N'. 
new_conflict(N,N',T) :- global_step(N,T+1,X,Y), global_step(N',T,X,Y), global_step(N,T,X',Y'),global_step(N',T+1,X',Y'), N!=N'. 
:- new_conflict(_,_,_).

occurs(object(robot, N), action(move,(X'-X, Y'-Y)),T) :- global_step(N,T,X,Y),global_step(N,T+1,X',Y').
#show occurs/3.

