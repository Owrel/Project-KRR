move(R, (X2-X1,Y2-Y1), T) :- positionin(R, (X2,Y2), T), positionin(R,(X1,Y1), T-1).
sameTileConflict((R1, R2), (X,Y), T) :- positionin(R1, (X,Y), T), positionin(R2, (X,Y), T), R1!=R2, not sameTileConflict((R2,R1), (X,Y), T), not move(R1, (0, 0), T), not move(R2, (0, 0), T).

swapConflict((R1, R2), T) :- positionin(R1, (X1,Y1), T), positionin(R2, (X2,Y2), T), positionin(R1, (X2,Y2), T-1), positionin(R2, (X1, Y1), T-1), R1 != R2.

moveOntoRobotConflict((R1, R2), T) :- positionin(R1, (X,Y), T), positionin(R2, (X,Y), T), move(R2,(XD, YD), T), XD=0, YD=0, R1 != R2.

wait((R1,R2), T) :- sameTileConflict((R1, R2), (X,Y), T), R1 != R2, #count{ET : wait((R1,R2),ET) ,ET<T, horizon(ET)}<1 ,#count{ET : wait((R2,R1),ET) ,ET<T, horizon(ET)}<1.

goalSwap((R1, R2), T) :- swapConflict((R1, R2), T), #count{TIME : wait(R1, TIME), horizon(TIME)}<1.

goalSwapOntop((R1, R2), T) :- moveOntoRobotConflict((R1, R2), T), #count{TIME : wait(R1, TIME), horizon(TIME)}<1.


delayedmove(R, (XD, YD), T+1) :- wait((R,R2), WT), move(R, (XD, YD), T), T > WT-1.

new_move(R, (XD, YD), T) :- delayedmove(R, (XD, YD), T).

new_move(R, (0, 0), T) :- wait((R,R2), T).

new_move(R1, (XD1, YD1), T) :- goalSwap((R1, R2), T), move(R2, (XD1, YD1), LATERTIME), LATERTIME>T-1.

new_move(R2, (XD1, YD1), LATERTIME-1) :- goalSwapOntop((R1, R2), T), move(R1, (XD1, YD1), LATERTIME), LATERTIME>T.
new_move(R1, (XD1, YD1), LATERTIME) :- goalSwapOntop((R1, R2), T), move(R2, (XD1, YD1), LATERTIME), LATERTIME>T.
new_move(R1, (XD1, YD1), T) :- goalSwapOntop((R1, R2), T), move(R1, (XD1, YD1), T).

position(R, (X,Y), 0) :- positionin(R, (X, Y), 0).
position(R, (X+XD,Y+YD), T+1) :- position(R, (X, Y), T), move(R, (XD, YD), T+1), not new_move(R, (_,_), T+1), #count{ XD2, YD2:new_move(R,(XD2,YD2),T+1) ,direction(XD2), direction(YD2)}<1.
position(R, (X+XD,Y+YD), T+1) :- position(R, (X, Y), T), new_move(R, (XD, YD), T+1).