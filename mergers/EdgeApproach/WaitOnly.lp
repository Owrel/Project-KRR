% translation
node(N,X,Y) :- init(object(node,N),value(_,(X,Y))).
edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), X-X' <=1, X-X' >=-1, Y-Y' == 0. 
edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), Y-Y' <=1, Y-Y' >=-1, X-X' == 0. 
edge(N,N) :- node(N,X,Y).
edge(X,Y, X',Y') :- node(N,X,Y), node(N',X',Y'), edge(N,N').


%  Init goal in initialposition
end(N,X,Y) :- init(object(shelf,N), value(at,(X,Y))).
init(N,X,Y) :- init(object(robot,N), value(at,(X,Y))).



% parameters
time(1..maxtime).

available_edge(X,Y,X',Y',N) :- path(X,Y,X',Y',N).


move(X,Y,0,N) :- init(N,X,Y).

{move(X',Y',T+1,N) : new_step(X,Y,T,N), available_edge(X,Y,X',Y',N) }1 :- init(N,_,_), time(T+1).

:- move(_,_,T,N), picked(N,T'), T>T'.


% if not moving, staying on position
stay(X,Y,T,N) :- not move(_,_,T,N), new_step(X,Y,T-1,N), time(T).
new_step(X,Y,T,N) :- move(X,Y,T,N).
new_step(X,Y,T,N) :- stay(X,Y,T,N).


{picked(N,T)} :- end(N,X,Y), new_step(X,Y,T,N).


:- not picked(N,_), init(N,_,_).




:- {new_step(X,Y,T,N): init(N,_,_)}>1, time(T), node(_,X,Y).
:- new_step(X,Y,T,N), new_step(X',Y',T+1,N), new_step(X',Y',T,N'), new_step(X,Y,T+1,N'), N!=N', (X,Y)!=(X',Y').


occurs(object(robot, N), action(move,(X'-X, Y'-Y)),T) :- new_step(X,Y,T,N),new_step(X',Y',T+1,N).
#show occurs/3.
% #show picked/2.

% #maximize {1,N,T: stay(X,Y,T,N), end(N,X,Y)}.