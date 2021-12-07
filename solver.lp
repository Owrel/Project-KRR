
% Building graph
node(N,X,Y) :- init(object(node,N),value(_,(X,Y))).
goal(X,Y,N) :- init(object(shelf,N), value(at,(X,Y))).
maxstep(50).
edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), X-X' <=1, X-X' >=-1, Y-Y' == 0. 
edge(N,N') :-N!=N', node(N,X,Y), node(N',X',Y'), Y-Y' <=1, Y-Y' >=-1, X-X' == 0. 
edge(N,N) :- node(N,X,Y).

edge(X,Y, X',Y') :- node(N,X,Y), node(N',X',Y'), edge(N,N').
edge(X,Y, X',Y') :- node(N,X,Y), node(N',X',Y'), edge(N,N').


