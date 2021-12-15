max_time(13).
time(0..MT) :- max_time(MT).


edge(X,Y,X,Y) :- edge(X,Y,_,_).
edge(X,Y,X,Y) :- edge(_,_,X,Y).

% conflict(N,N',T) :- step(N,T,X,Y), step(N',T,X,Y), N!=N'. 
% #show conflict/3.

available_edge_from_path(X,Y,X',Y',N) :- path(X,Y,X',Y',N).
available_edge_from_path(X,Y,X,Y,N) :- available_edge_from_path(X,Y,_,_,N).
% {available_edge_from_conflict(X,Y,X',Y',N) : edge(X,Y,X',Y'), available_edge(X,Y,_,_,N)}.
{available_edge_from_conflict(X,Y,X',Y',N) : edge(X,Y,X',Y'), available_edge(_,_,X,Y,N)}.
available_edge(X,Y,X',Y',N):- available_edge_from_conflict(X,Y,X',Y',N).
available_edge(X,Y,X',Y',N):- available_edge_from_path(X,Y,X',Y',N).

% available_edge(X,Y,_,_,N)
% :- available_edge_from_conflict(X,Y,_,_,N),  conflict(N,_,T), new_step(N,T',_,_), T'<T.


{new_goalReached(N,T)} :- new_step(N,T,X,Y), (X,Y) == (EX,EY), end(N,EX,EY).
new_goalReached(N) :- new_goalReached(N,T).
:- not new_goalReached(N), init(N,_,_).



new_step(N,0,X,Y) :- init(N,X,Y).
{new_step(N,T+1,X',Y') : available_edge(X,Y,X',Y',N)}=1 :- new_step(N,T,X,Y),  T<MT, max_time(MT), not new_goalReached(N,T).
global_step(N,T,X,Y) :- new_step(N,T,X,Y).


% available_edge(X,Y,X,Y,N) :- new_step(N,T,X,Y), new_goalReached(N,T). 
after_step(N,T,X,Y) :- new_step(N,T,X,Y), new_goalReached(N,T).
after_step(N,T+1,X,Y) :- after_step(N,T,X,Y),  T<MT, max_time(MT).
global_step(N,T,X,Y) :- after_step(N,T,X,Y).



new_conflict(N,N',T) :- global_step(N,T,X,Y), global_step(N',T,X,Y), N!=N'. 
new_conflict(N,N',T) :- global_step(N,T+1,X,Y),global_step(N',T,X,Y), global_step(N,T,X',Y'),global_step(N',T+1,X',Y'), N!=N'. 

:- new_conflict(_,_,_).







#show available_edge_from_conflict/5.
% #minimize {1,N',N,T : new_conflict(N,N',T)}.

occurs(object(robot, N), action(move,(X'-X, Y'-Y)),T) :- global_step(N,T,X,Y),global_step(N,T+1,X',Y').
% #show occurs/3. 
% #show available_edge/5. 


#minimize {1@1,X,Y,X',Y',N : available_edge_from_conflict(X,Y,X',Y',N)}.
% #minimize {1@2,N,T : new_step(N,T,X,Y)}.
% #maximize {T@2,N : new_goalReached(N,T), not new_goalReached(N,T'), T'>T, time(T')}.
% #minimize {T@3,N : new_goalReached(N,T)}.






