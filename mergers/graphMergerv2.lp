time(1..13).

conflit(N,N',T)     :- step(N,T,X,Y),   step(N',T,X,Y), N!=N', not conflict(N',N,T). 
conflict(N,N',T)    :- step(N,T+1,X,Y), step(N',T,X,Y), step(N,T,X',Y'),   step(N',T+1,X',Y'), N!=N',not conflict(N',N,T). 

available_edge(X,Y,X',Y',N) :- path(X,Y,X',Y',N).


{additional_edge(X,Y,X',Y',N): init(N,_,_)} :- new_step(X,Y,_,N), edge(X,Y,X',Y'), (X,Y)!=(X',Y'). 
available_edge(X,Y,X',Y',N) :- additional_edge(X,Y,X',Y',N).

move(X,Y,0,N) :- init(N,X,Y).
{move(X,Y,T,N) : init(N,_,_)}1 :- new_step(X',Y',T-1,N), available_edge(X',Y',X,Y,N), time(T).



{picked(N)} :- end(N,X,Y), new_step(X,Y,_,N).
:- not picked(N), init(N,_,_).

% if not moving, staying on position
stay(X,Y,T,N) :- not move(_,_,T,N), new_step(X,Y,T-1,N), time(T).
new_step(X,Y,T,N) :- move(X,Y,T,N).
new_step(X,Y,T,N) :- stay(X,Y,T,N).


:- {new_step(X,Y,T,N): init(N,_,_)}>1, time(T), node(_,X,Y).
:- new_step(X,Y,T,N), new_step(X',Y',T+1,N), new_step(X',Y',T,N'), new_step(X,Y,T+1,N'), N!=N', (X,Y)!=(X',Y').

% #show conflict/3.
% #show new_step/4.

occurs(object(robot, N), action(move,(X'-X, Y'-Y)),T) :- new_step(X,Y,T,N),new_step(X',Y',T+1,N).
#show occurs/3. 