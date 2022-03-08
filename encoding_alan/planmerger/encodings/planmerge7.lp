%Start 
rp(D,X,Y,0,0):-wayswitch(D,0,_,-1,_,0), not wayswitch(D,0,_,0,_,_), init(object(robot,D),value(at,(X,Y))).
rp(D,X,Y,0,P):-wayswitch(D,0,_,-1,_,0), wayswitch(D,0,_,0,_,P), init(object(robot,D),value(at,(X,Y))).
maxplan(G,J):- occurs(object(robot,G),action(move,(_,_)),J), not occurs(object(robot,G), action(move,(_,_)),J+1).
maxmove(K+1):- occurs(object(robot,_),action(move,(_,_)),J), not occurs(object(robot,_), action(move,(_,_)),J+1), K=70, rc(S).
maxit(U):- rc(S), U=S*2.
order(G,X,Y) :- init(object(shelf,G),value(at,(X,Y))).
rc(S) :- S = #count{ D : init(object(robot,D),value(at,(X,Y))) }.

% movement
rp(D,X+V,Y+W,T+1,J+1):- rp(D,X,Y,T,J), occurs(object(robot,G),action(move,(V,W)),J+1), wayswitch(D,B,_,_,G,P), wayswitch(D,Z,G,P,_,_), B=T, T!=Z-1, T<K+1, maxmove(K), B!=Z.
rp(D,X+V,Y+W,T+1,J+1):- rp(D,X,Y,T,J), occurs(object(robot,G),action(move,(V,W)),J+1), wayswitch(D,B,_,_,G,P), wayswitch(D,Z,G,P,_,_), B<T, T<Z-1,T<K+1, maxmove(K), B!=Z.
rp(D,X+V,Y+W,T+1,F):- rp(D,X,Y,T,J), occurs(object(robot,G),action(move,(V,W)),J+1), wayswitch(D,B,_,_,G,P), wayswitch(D,Z,G,P,_,F), T=Z-1, T<K+1, maxmove(K), B!=Z.
rp(D,X+V,Y+W,T+1,J+1):- rp(D,X,Y,T,J), occurs(object(robot,G),action(move,(V,W)),J+1), wayswitch(D,B,_,A,G,P), wayfinish(D,G,Z), B<T+1, T<Z+1,T<K, maxmove(K), B!=Z.

maxpath(D,T+1):-rp(D,_,_,T,_), not rp(D,_,_,T+1,_).

inithit(D,X,Y,T):-rp(D,X,Y,T,_), rp(Q,X,Y,Z,_), rp(D,V,W,T-1,_), not rp(Q,V,W,Z-1,_), not rp(Q,V,W,Z+1,_).
inithit(D,X,Y,0):-rp(D,X,Y,0,_), rp(Q,X,Y,Z,_), D!=Q.

gegen(D,Q,X,Y):-rp(D,X,Y,T,_), rp(Q,X,Y,Z,_), rp(D,V,W,T-1,_), rp(Q,V,W,Z+1,_), rp(D,A,B,T+1,_), not rp(Q,A,B,Z-1,_). 
wp(D,X,Y,0,0):-rp(D,X,Y,0,P).

wp(D,X,Y,T,J):-rp(D,X,Y,T-J,_), wp(D,V,W,T-1,J), not back(D,T), T<K+1, maxmove(K).
1{back(D,T);wp(D,X,Y,T,J)}1:-rp(D,X,Y,T-J,_), wp(D,V,W,T-1,J), inithit(D,X,Y,_).
wp(D,V,W,T,J+1):-rp(D,X,Y,T-J,_), wp(D,V,W,T-1,J), back(D,T), T<K+1, maxmove(K).
back(D,T):-rp(D,X,Y,T-J,_), wp(D,V,W,T-1,J), wp(Q,X,Y,T,_), back(Q,T).
wp(Q,X,Y,K+1,I):-inithit(D,X,Y,C), inithit(Q,X,Y,O), rp(D,V,W,C-1,_), rp(Q,N,M,O-1,_), wp(D,V,W,K,J), wp(Q,N,M,K,I), G+J<H+I, maxpath(D,G), maxpath(Q,H), not gegen (D,Q,X,Y), not gegen (Q,D,X,Y).

%hit(D,V,W,T-1):-not rp(D,_,_,T-J,_), wp(D,V,W,T-1,J), T+J<K+1, maxmove(K).
%:-wp(D,X,Y,T,_), wp(Q,X,Y,T,_), Q<D.
%:-wp(D,X,Y,T,J), J>U, maxit(U).
%:-not wp(D,X,Y,_,_), rp(D,X,Y,_).
%:-hit(D,X,Y,T), wp(Q,X,Y,Z,_), T<Z, D!=Q.

%wp(D,X,Y,0,0):-rp(D,X,Y,0,P).
%wp(D,X,Y,T,J):-rp(D,X,Y,T-J,_), wp(D,V,W,T-1,J), T<K, maxmove(K), not wp(D,_,_,T-2,J-1).
%1{wp(D,V,W,T,J+1);wp(D,X,Y,T,J)}1:-rp(D,X,Y,T-J,_), wp(D,V,W,T-1,J), inithit(D,X,Y,_), T<K, maxmove(K).
%wp(D,V,W,T,J+1):-rp(D,X,Y,T-J,_), wp(D,V,W,T-1,J), T<K, maxmove(K), wp(Q,X,Y,T,_), Q!=D.

hit(D,V,W,T-1):-not rp(D,_,_,T-J,_), wp(D,V,W,T-1,J), T<K, maxmove(K).
:-wp(D,X,Y,T,_), wp(Q,X,Y,T,_), Q<D.
:-wp(D,X,Y,T,I), wp(D,V,W,T+1,I), wp(Q,V,W,T,J), wp(Q,X,Y,T+1,J).
:-wp(D,X,Y,T,J), J>U, maxit(U).
:-not wp(D,X,Y,_,_), rp(D,X,Y,_,_).
:-hit(D,X,Y,T), wp(Q,X,Y,Z,_), T<Z, D!=Q.

t(T):-wp(_,_,_,T,_), not wp(_,_,_,T+1,_).
#minimize {T:t(T)}.

#show.
#show init/2.
#show wp/5.