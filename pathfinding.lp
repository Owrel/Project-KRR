
 
1{goal(X,Y,R,N) : init(object(robot,R), value(at,(_,_)))}1 :-  init(object(shelf,N), value(at,(X,Y))).

:- goal(_,_,R,N), goal(_,_,R,N'), N!=N'. 

% #show goal/4.

maxstep(10).


node(N,X,Y) :- init(object(node,N),value(_,(X,Y))).
edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), X-X' <=1, X-X' >=-1, Y-Y' == 0. 
edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), Y-Y' <=1, Y-Y' >=-1, X-X' == 0. 
edge(N,N) :- node(N,X,Y).

edge(X,Y, X',Y') :- node(N,X,Y), node(N',X',Y'), edge(N,N').
edge(X,Y, X',Y') :- node(N,X,Y), node(N',X',Y'), edge(N,N').
% % Finding opath for each agents
opath(R,X,Y,0) :- init(object(robot,R), value(at,(X,Y))).


{opath(R,X',Y',T+1)}1 :- opath(R,X,Y,T), edge(X,Y,X',Y'), T<MS, maxstep(MS),  goal(GX,GY,R,_), (GX,GY)!=(X,Y).  

goalReached(R,T) :- goal(X,Y,R,_), opath(R,X,Y,T).
:- opath(R,X,Y,S), goal(X,Y,R,_), opath(R,_,_,S'), S'>S. % Stop moving after reaching a goal
:- not goalReached(R,_), init(object(robot,R), _).


#show goalReached/2.
#show opath/4.
#minimize{ T,R  : goalReached(R,T)}.