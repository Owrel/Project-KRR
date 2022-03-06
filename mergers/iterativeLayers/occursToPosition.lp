direction(-1..1).
horizon(0..60).
node(X,Y) :- init(object(node, ID), value(at, (X, Y))).
move(R, (XD,YD), T+1) :- occurs(object(robot,R), action(move, (XD,YD)), T).
move(R, (0, 0), T) :- #count{XD2,YD2 : move(R, (XD2,YD2), T), direction(XD2), direction(YD2), XD2+YD2 != 0}<1, horizon(T), robot(R).
positionin(R, (X,Y), 0) :- init(object(robot,R), value(at,(X,Y))).
positionin(R, (X+XD,Y+YD), T+1) :- positionin(R, (X, Y), T), move(R, (XD, YD), T+1).
robot(R) :- init(object(robot,R), value(at,(X,Y))), node(X,Y).
shelf(S, (X, Y)) :- init(object(shelf,S),value(at,(X,Y))).
