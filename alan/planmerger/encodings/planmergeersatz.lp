%Start 
rp(D,X,Y,0) :- init(object(robot,D),value(at,(X,Y))).
switch(D,0,D,-1,D,0) :- init(object(robot,D),value(at,(X,Y))).
maxplan(G,0):- init(object(robot,G),value(at,(_,_))), not occurs(object(robot,G), action(move,(_,_)),_).
maxplan(G,J):- occurs(object(robot,G),action(move,(_,_)),J), not occurs(object(robot,G), action(move,(_,_)),J+1).
maxmove(K):- occurs(object(robot,_),action(move,(_,_)),J), not occurs(object(robot,_), action(move,(_,_)),J+1), K=S+J+1, rc(S).

order(G,X,Y) :- init(object(shelf,G),value(at,(X,Y))).
rc(S) :- S = #count{ D : init(object(robot,D),value(at,(X,Y))) }.

% movement
rp(D,X+V,Y+W,T+1):- rp(D,X,Y,T), occurs(object(robot,D),action(move,(V,W)),T+1), T<K, maxmove(K).

% final in the way into mover must increase iteration.... Doesn't happen if switch plans accurate 
inithit(D,Q,X,Y,T,Z):-rp(D,X,Y,T), rp(Q,X,Y,Z), rp(D,V,W,T-1), not rp(Q,V,W,Z-1), not rp(Q,V,W,Z+1).
inithit(D,Q,X,Y,0,Z):-rp(D,X,Y,0), rp(Q,X,Y,Z), D!=Q.
gegen(D,T):-rp(D,X,Y,T), rp(Q,X,Y,Z), rp(D,V,W,T-1), rp(Q,V,W,Z+1), rp(D,A,B,T+1), not rp(Q,A,B,Z-1). 
finishhit(D,Q,T):-rp(Q,X,Y,T), order(D,X,Y), finish(D,Z), D!=Q.
switch(D,0,Q,0,G,U):-switch(D,0,_,-1,Q,0), inithit(Q,G,X,Y,0,U).
switch(D,T+Z-P,Q,P,G,U):-switch(D,T,_,_,Q,P), inithit(Q,G,X,Y,Z,U), P<Z, T+Z-P<K, end(K).
%binishhit A=Agent welcher zu D geht D=Ziel welches getroffen Z=wann A bei D da istQ=Agent weg welche D durchläuft T=wann Q da ist
%
%tinish(A,Q,O,D):-binishhit(A,Q,O,E,T), switch(D,Z,_,_,E,W), switch(D,P,E,W,_,_), P+1-Z>T-W, T>W, O<Z+T-W.
%tinish(A,Q,O,D):-binishhit(A,Q,O,E,T), switch(D,Z,_,_,E,W), finish(E,K), K+1-Z>T-W, T>W, O<Z+T-W.
binish(Q,Q,U):-finish(Q,U).
binish(D,Q,T+U-P):-switch(D,T,_,_,Q,P), finish(Q,U), T+U-P<K, end(K).
1{ cinish(X,Y,Z) : binish(X,Y,Z), not ginish(X,Y,Z)}1:- init(object(robot,X),_).
ginish(X,Y,Z):-binish(X,Y,Z), binish(X,Y,T), T<Z.
take(X) :- S=1, S= #count{ Y : binish(_,X,Y)}, binish(_,X,_).
cinish(Y,Y,Z):-binish(Y,Y,Z), take(Y).
%ginish(X,Y,Z):-binish(X,Y,Z), 
:-cinish(X,Y,_), cinish(Z,Y,_), Z<X.
:-cinish(X,Y,_), cinish(Z,Y,_), X<Z.
:-cinish(X,Y,_), cinish(X,Z,_), Z<Y.
:-cinish(X,Y,_), cinish(X,Z,_), Y<Z.
ciel(X,Y,Z):-cinish(X,Y,Z), cinish(_,_,T),not ciel(_,_,T), Z<T.
diel(Z):-cinish(X,Y,Z), not ciel(X,Y,Z).
eiel(Z):-Z = #sum{ T,X,Y :cinish(X,Y,T)}.
#minimize {X@2: diel(X); Y@1: eiel(Y)}.

wayswitch(D,0,D,-1,D,0):-switch(D,0,D,-1,D,0), diel(_).
wayswitch(D,Z,A,B,E,W):-wayswitch(D,T,_,_,A,B), switch(D,Z,A,B,E,W), T<Z, cinish(D,E,T), not wayswitch(D,T,_,_,E,_), finish(E,F), Z+F-W=T.
{wayswitch(D,0,D,0,E,W)}:-wayswitch(D,0,D,-1,D,0), switch(D,0,D,0,E,W).
{wayswitch(D,Z,A,B,E,W)}:-wayswitch(D,T,_,_,A,B), switch(D,Z,A,B,E,W), T<Z, inithit(A,E,_,_,G,W), G-B=Z-T.
:-wayswitch(D,Z,A,B,_,_),wayswitch(D,T,A,B,_,_), Z!=T.
:-wayswitch(D,Z,A,B,C,_),wayswitch(D,Z,A,B,E,_), C!=E.
:-wayswitch(D,Z,A,B,C,E),wayswitch(D,Z,A,B,C,F), F!=E.
:-wayswitch(D,_,A,_,_,_), cinish(D,A,_), A!=D.
:-wayswitch(D,_,D,I,_,_), cinish(D,D,_), I!=-1.
%1 to 1 =3, 1,2=4 2,1=2 2,2 =3 cinishhit(

cinishhit(A,D,Z,Q,T):-finishhit(D,Q,T), cinish(A,D,Z).
:-cinishhit(A,Q,I,E,T), wayswitch(D,Z,_,_,E,W), wayswitch(D,P,E,W,_,_), W+1+P-Z>T, T>W, Z+T-W>I.
:-cinishhit(A,Q,I,E,T), wayswitch(D,Z,_,_,E,W), cinish(D,E,P), W+1+P-Z>T, T>W, Z+T-W>I.
%wayfinishhit(D,Q,Z+T-W):-wayswitch(D,Z,A,B,E,W), finishhit(Q,E,X,Y,T,O), wayswitch(D,P,E,W,_,_), P+1-Z>T-W.
%wayfinishhit(D,Q,Z+T-W):-wayswitch(D,Z,A,B,E,W), finishhit(Q,E,X,Y,T,O), wayfinish(D,E,K), K+1-Z>T-W.
%:-cinish(D,Q,K), wayfinishhit(E,Q,T), T>K.
wayfinish(D,Q,K):-cinish(D,Q,K), finish(Q,U), wayswitch(D,T,_,_,Q,P), K=T+U-P.
:-cinish(D,Y,Z), not wayfinish(D,Y,Z).

%
finish(D,T):- rp(D,X,Y,T), order(D,X,Y).
final(T):- rp(_,_,_,T), not rp(_,_,_,T+1), rc(S), S=#count{ D : finish(D,_) }.
c(S) :- S = #count{ T : final(T) }.

end(T+1):-rp(_,_,_,T), not rp(_,_,_,T+1).
#show gegen/2.
#show init/2.
#show occurs/3.
#show wayswitch/6.
#show wayfinish/3.