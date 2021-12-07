node(1..2,1..5).

init(1, 1,1).
init(2, 1,5).

end(1,1,5).
end(2,1,1).


edge(X,Y,X,Y') :-node(X,Y), node(X,Y'),Y'!=Y, Y-Y'<=1, Y-Y' >=-1. 
edge(X,Y,X',Y) :-node(X,Y), node(X',Y),X'!=X, X-X'<=1, X-X' >=-1.


{path(X,Y,X',Y',N): edge(X,Y,X',Y') } =1:- init(N,X,Y) .

{path(X,Y,X',Y',N): edge(X,Y,X',Y') } =1:- path(_,_,X,Y,N), (X,Y) != (EX,EY), end(N,EX,EY) .






goalReached(N) :- path(_,_,X,Y,N), (X,Y) == (EX,EY), end(N,EX,EY).

:- init(N,_,_), not goalReached(N).



step(N,0,X,Y) :- init(N,X,Y).
step(N,T+1,X',Y') :- step(N,T,X,Y), path(X,Y,X',Y',N), T<15.


% conflict(N,N',T,X,Y) :- step(N,T,X,Y), step(N',T,X,Y),N'!= N.

% {path(X,)}

% path(X,Y,X',Y'). path(X',Y',X,Y). 

% #show step/4.
% #show node/2.
% #show path/5.
% #show goalReached/1.
% #show conflict/5.
#show edge/4.

% #show .

% #minimize {1,N,N',T : conflict(N,N',T,X,Y)}.
#minimize {1,N,T : step(N,T,_,_)}.




