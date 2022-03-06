% occurs(object(robot, N), action(move,(X'-X, Y'-Y)),T) :- step(X,Y,T,N),step(X',Y',T+1,N).
occurs(object(robot, N), action(move,(X'-X, Y'-Y)),T) :- step(N,T,X,Y),step(N,T+1,X',Y').

init(object(product,N),value(on,(N,1))) :- init(object(shelf,N),value(at,(_,_))).
init(object(order,N),value(line,(N,1))) :- init(object(shelf,N),value(at,(_,_))).

#show init/2.
#show occurs/3.