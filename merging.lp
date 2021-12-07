node(1,1).
node(1,2).
node(1,3).
node(1,4).
node(1,5).
node(2,1).
node(2,2).
node(2,3).
node(2,4).
node(2,5).
step(1,0,1,1).
step(2,0,1,5).
path(1,5,1,4,2).
path(1,1,1,2,1).
path(1,2,1,3,1).
path(1,4,1,3,2).
path(1,3,1,2,2).
path(1,3,1,4,1).
path(1,4,1,5,1).
path(1,2,1,1,2).
step(2,1,1,4).
step(1,1,1,2).
step(1,2,1,3).
step(2,2,1,3).
step(2,3,1,2).
step(1,3,1,4).
step(1,4,1,5).
step(2,4,1,1).
edge(1,2,1,1).
edge(1,1,1,2).
edge(1,3,1,2).
edge(1,2,1,3).
edge(1,4,1,3).
edge(1,3,1,4).
edge(1,5,1,4).
edge(1,4,1,5).
edge(2,2,2,1).
edge(2,1,2,2).
edge(2,3,2,2).
edge(2,2,2,3).
edge(2,4,2,3).
edge(2,3,2,4).
edge(2,5,2,4).
edge(2,4,2,5).
edge(2,1,1,1).
edge(2,2,1,2).
edge(2,3,1,3).
edge(2,4,1,4).
edge(2,5,1,5).
edge(1,1,2,1).
edge(1,2,2,2).
edge(1,3,2,3).
edge(1,4,2,4).
edge(1,5,2,5).



edge(X,Y,X,Y) :- edge(X,Y,_,_).
% conflict(N,N',T) :- step(N,T,X,Y), step(N',T,X,Y), N!=N'. 
% #show conflict/3.

available_edge_from_path(X,Y,X',Y',N) :- path(X,Y,X',Y',N).

{available_edge_from_conflict(X,Y,X',Y',N) : edge(X,Y,X',Y'),init(N,_,_) }=1.
available_edge(X,Y,X',Y',N):- available_edge_from_conflict(X,Y,X',Y',N).
available_edge(X,Y,X',Y',N):- available_edge_from_path(X,Y,X',Y',N).


new_step(N,0,X,Y) :- init(N,X,Y).
{new_step(N,T+1,X',Y') : available_edge(X,Y,X',Y',N)}=1 :- new_step(N,T,X,Y),  T<15,  (X,Y) != (EX,EY), end(N,EX,EY).


init(1, 1,1).
init(2, 1,5).

end(1,1,5).
end(2,1,1).



goalReached(N) :- new_step(N,_,X,Y), (X,Y) == (EX,EY), end(N,EX,EY).
:- init(N,_,_), not goalReached(N).


new_conflict(N,N',T) :- new_step(N,T,X,Y), new_step(N',T,X,Y), N!=N'. 

% new_conflict(N,N',T) :- new_step(N,T-1,X,Y),new_step(N',T,X,Y), new_step(N,T,X',Y'),new_step(N',T-1,X',Y'). 
:- new_conflict(_,_,_).





% new_step1(T,X,Y):- N==2, new_step(N,T,X,Y).
% #show available_edge/5.
% #show new_step1/3.
% #show conflict/3.
% #show new_conflict/3.

#show available_edge_from_conflict/5.
% #minimize {1,T,N : new_step(N,T,_,_)}.
% #minimize {1,X,Y,X',Y',N : available_edge_from_conflict(X,Y,X',Y',N)}.

