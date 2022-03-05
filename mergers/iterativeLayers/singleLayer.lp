% get move atoms
move(R, (X2-X1,Y2-Y1), T) :- positionin(R, (X2,Y2), T), positionin(R,(X1,Y1), T-1).

% identify conflicts
sameTileConflict((R1, R2), (X,Y), T) :- positionin(R1, (X,Y), T), positionin(R2, (X,Y), T), R1!=R2, not sameTileConflict((R2,R1), (X,Y), T), not move(R1, (0, 0), T), not move(R2, (0, 0), T).
sameTileConflict((R1, R2), (X,Y), T) :- positionin(R1, (X,Y), T), positionin(R2, (X,Y), T), R1!=R2, not sameTileConflict((R2,R1), (X,Y), T), move(R2, (0, 0), T),
not move(R1, (0,0), T),#count{TIME : move(R2,(XD,YD),TIME) ,horizon(TIME), TIME>=T, XD+YD!=0}>0.
% for debugging
sameTileBecauseWaiterAhead((R1, R2), (X,Y), T) :- positionin(R1, (X,Y), T), positionin(R2, (X,Y), T), R1!=R2, not sameTileConflict((R2,R1), (X,Y), T), move(R2, (0, 0), T),
not move(R1, (0,0), T),#count{TIME : move(R2,(XD,YD),TIME) ,horizon(TIME), TIME>=T, XD+YD!=0}>0.
swapConflict((R1, R2), T) :- positionin(R1, (X1,Y1), T), positionin(R2, (X2,Y2), T), positionin(R1, (X2,Y2), T-1), positionin(R2, (X1, Y1), T-1), R1 != R2.

moveOntoRobotConflict((R1, R2), T) :- positionin(R1, (X,Y), T), positionin(R2, (X,Y), T), R1 != R2,
#count{TIME : move(R2,(XD,YD),TIME) ,horizon(TIME), TIME>=T, XD+YD!=0, direction(XD), direction(YD)}<1.

% find solutions to conflicts
wait((R1,R2), T) :- sameTileConflict((R1, R2), (X,Y), T), R1 != R2, #count{ET : wait((R1,ANY_R),ET) ,ET<T, horizon(ET), robot(ANY_R)}<1 ,#count{ET : wait((R2,ANY_R),ET) ,ET<T, horizon(ET), robot(ANY_R)}<1.

goalSwap((R1, R2), T) :- swapConflict((R1, R2), T), #count{TIME : wait((R1,OTHER_R), TIME), horizon(TIME), robot(OTHER_R)}<1, #count{TIME: wait((R2,OTHER_R), TIME), horizon(TIME), robot(OTHER_R)}<1, #count{TIME: goalSwap((R1, R2), TIME), TIME < T} <1.

goalSwapOntop((R1, R2), T) :- moveOntoRobotConflict((R1, R2), T), #count{TIME : wait((R1, OTHER_R), TIME), horizon(TIME), robot(OTHER_R)}<1, #count{TIME : wait((R2,OTHER_R), TIME), horizon(TIME), robot(OTHER_R)}<1,
 #count{TIME: goalSwapOntop((R1, OTHER_R), TIME), TIME <T, robot(OTHER_R)}<1, #count{TIME: goalSwapOntop((R2, OTHER_R), TIME), horizon(TIME), robot(OTHER_R)}<1,
 #count{TIME: goalSwapOntop((OTHER_R, R2), TIME), horizon(TIME), robot(OTHER_R), OTHER_R!=R1}<1,
 #count{TIME: moveOntoRobotConflict((R1, ANY_R), TIME), horizon(TIME),TIME<T, robot(ANY_R), ANY_R!=R1}<1,
 #count{TIME: moveOntoRobotConflict((R2, ANY_R), TIME), horizon(TIME),TIME<T, robot(ANY_R), ANY_R!=R2}<1,
 #count{TIME: moveOntoRobotConflict((ANY_R, R2), TIME), horizon(TIME),TIME<T, robot(ANY_R), ANY_R!=R2}<1,
 #count{TIME: moveOntoRobotConflict((ANY_R, R1), TIME), horizon(TIME),TIME<T, robot(ANY_R), ANY_R!=R1}<1,
 #count{TIME: goalSwap((R1, OTHER_R), TIME), horizon(TIME), robot(OTHER_R)} <1, #count{TIME: goalSwap((R2, OTHER_R), TIME), horizon(TIME), robot(OTHER_R)} <1.

delayedmove(R, (XD, YD), T+1) :- wait((R,R2), WT), move(R, (XD, YD), T), T > WT-1.

% set solution moves
new_move(R, (XD, YD), T) :- delayedmove(R, (XD, YD), T).
new_move(R, (0, 0), T) :- wait((R,R2), T).

new_move(R1, (XD1, YD1), LATERTIME-1) :- goalSwap((R1, R2), T), move(R2, (XD1, YD1), LATERTIME), LATERTIME>T.
% for debugging
new_move_goalSwap(R1, (XD1, YD1), LATERTIME-1) :- goalSwap((R1, R2), T), move(R2, (XD1, YD1), LATERTIME), LATERTIME>T.

new_move(R2, (XD1, YD1), LATERTIME-1) :- goalSwapOntop((R1, R2), T), move(R1, (XD1, YD1), LATERTIME), LATERTIME>T.
new_move(R1, (XD1, YD1), LATERTIME) :- goalSwapOntop((R1, R2), T), move(R2, (XD1, YD1), LATERTIME), LATERTIME>T.

% for debugging
new_move_goalSwapOntop(R2, (XD1, YD1), LATERTIME-1) :- goalSwapOntop((R1, R2), T), move(R1, (XD1, YD1), LATERTIME), LATERTIME>T.
new_move_goalSwapOntop(R1, (XD1, YD1), LATERTIME) :- goalSwapOntop((R1, R2), T), move(R1, (XD1, YD1), LATERTIME), LATERTIME>T.

% set positions from solution moves
position(R, (X,Y), 0) :- positionin(R, (X, Y), 0).
position(R, (X+XD,Y+YD), T+1) :- position(R, (X, Y), T), move(R, (XD, YD), T+1), #count{ XD2, YD2 : new_move(R,(XD2,YD2),T+1) ,direction(XD2), direction(YD2)}<1.
position(R, (X+XD,Y+YD), T+1) :- position(R, (X, Y), T), new_move(R, (XD, YD), T+1).