% Merger with layers
% so far only tested with simple waiting and goal swapping examples
% Layers --------------------------------------------------------
% It is assumed that robots should have a move command on every time step
% Moves on lower layers are still active if there is no moves in any upper Layer on the same time step
% original idea by Anton R., Aaron B. and Louis D.
% define layers
#const max_layers = 15.
layer(0..max_layers-1).
horizon(0.. 7).
direction(0..1).
direction(-1).
% define nodes
node(X,Y) :- init(object(node, ID), value(at, (X, Y))).
% define robots
robot(ID) :- init(object(robot,ID), value(at,(X,Y))), node(X,Y).
% define moves on base layer(0)
move(R,  (XD,YD), T, 0) :- occurs(object(robot,R), action(move, (XD,YD)), T).
% every step without movement contains a move command with 0,0
move(R, (0, 0), T, 0) :- #count{XD2,YD2 : move(R, (XD2,YD2), T,0), direction(XD2), direction(YD2), XD2+YD2 != 0}<1, horizon(T), robot(R).

% collect finalMoves as all Moves on current Layer and all moves on layers below if you dont have one yet
finalMove(R, (XD, YD), T, L) :- move(R, (XD, YD), T, L).
finalMove(R, (XD, YD), T, L) :- finalMove(R, (XD, YD), T, L-1), layer(L), #count{XD2,YD2 : move(R, (XD2,YD2), T,L), direction(XD2), direction(YD2)}<1.

:- finalMove(R, (XD1, YD1), T, L), finalMove(R, (XD2, YD2), T, L), XD1 != XD2.
:- finalMove(R, (XD1, YD1), T, L), finalMove(R, (XD2, YD2), T, L), YD1 != YD2.

% define all starting positions on base layer(0)
position(R, (X, Y), 0, 0) :- init(object(robot,R), value(at,(X,Y))).

% define positions for any layer
position(R, (X,Y), 0, L) :- position(R, (X,Y), 0, 0), layer(L).
position(R, (X+XD,Y+YD), T, L) :- position(R, (X, Y), T-1, L), finalMove(R, (XD, YD), T, L).
% ---------------------------------------------------------------

% Conflict solving ----------------------------------------------

% Find Conflicts -----------

% find conflicts since it should only include those that are not swap conflicts both robots must have moved
sameTileConflict((R1, R2), (X,Y), T, L) :- position(R1, (X,Y), T, L), position(R2, (X,Y), T, L), R1!=R2, not sameTileConflict((R2,R1), (X,Y), T, L),
                           not finalMove(R1, (0, 0), T, L), not finalMove(R2, (0, 0), T, L).

% swap conflict when switching positions
swapConflict((R1, R2), T, L) :- position(R1, (X1,Y1), T, L), position(R2, (X2,Y2), T, L), position(R1, (X2,Y2), T-1, L), position(R2, (X1, Y1), T-1, L), R1 != R2.
% swap conflict when one robot moves ontop of another
moveOntoRobotConflict((R1, R2), T, L) :- position(R1, (X,Y), T, L), position(R2, (X,Y), T, L), move(R2,(XD, YD), T, L), direction(XD), direction(YD), XD=0, YD=0, R1 != R2.

% wait on conflict if not waited yet and other didnt either
wait((R1,R2), T, L) :- sameTileConflict((R1, R2), (X,Y), T, L-1), R1 != R2, #count{ET : wait((R1,R2),ET,L) ,ET<T, horizon(ET)}<1 ,#count{ET : wait((R2,R1),ET,L) ,ET<T, horizon(ET)}<1.

% goal swap on swapConflict and no wait operation on this layer
goalSwap((R1, R2), T, L) :- swapConflict((R1, R2), T, L-1), #count{TIME : wait(R1, TIME,L), horizon(TIME)}<1.
% goalswap when one robot moves ontop of another
goalSwapOntop((R1, R2), T, L) :- moveOntoRobotConflict((R1, R2), T, L-1), #count{TIME : wait(R1, TIME,L), horizon(TIME)}<1.
% Add Solutions to Conflicts -------------

% delay all moves by one if there is a wait command
delayedmove(R, (XD, YD), T+1, L) :- wait((R,R2), WT, L), finalMove(R, (XD, YD), T, L-1), T > WT-1.
move(R, (XD, YD), T, L) :- delayedmove(R, (XD, YD), T, L).
% insert wait move
move(R, (0, 0), T, L) :- wait((R,R2), T, L).

% put swapped moves
move(R1, (XD1, YD1), T, L) :- goalSwap((R1, R2), T, L), finalMove(R2, (XD1, YD1), LATERTIME,L-1), LATERTIME>T-1.

% put swapped moves when one robot moves ontop of another
move(R2, (XD1, YD1), LATERTIME-1, L) :- goalSwapOntop((R1, R2), T, L), finalMove(R1, (XD1, YD1), LATERTIME,L-1), LATERTIME>T, horizon(LATERTIME).
move(R1, (XD1, YD1), LATERTIME, L) :- goalSwapOntop((R1, R2), T, L), finalMove(R2, (XD1, YD1), LATERTIME,L-1), LATERTIME>T, horizon(LATERTIME).
move(R1, (XD1, YD1), T, L) :- goalSwapOntop((R1, R2), T, L), finalMove(R1, (XD1, YD1), T, L-1).

% OUTPUT ----------------------------------------------------------------------------------
#const outL =14 .
finalMove(R, (XD, YD), T) :- finalMove(R, (XD, YD), T, L), L == outL.
move(R, (XD, YD), T) :- move(R, (XD, YD), T, L), L==outL.
swapConflict((R1, R2), T) :- swapConflict((R1,R2), T, L), L == outL.
moveOntoRobotConflict((R1, R2), T) :- moveOntoRobotConflict((R1, R2), T, L), L == outL.
goalSwapOntop((R1, R2), T) :- goalSwapOntop((R1, R2), T, L), L==outL.
wait((R1, R2), T) :- wait((R1, R2), T, L), L== outL.
position(R, (X, Y), T) :- position(R, (X,Y), T, L), L==outL.
sameTileConflict(R, (X,Y), T) :- sameTileConflict(R, (X,Y), T, L), L==outL.

%testmove(R, (XD1, YD1), T) :- testmove(R, (XD1, YD1), T, L), L== outL.
%#show swapConflict/2.
%#show goalSwapOntop/2.
%#show sameTileConflict/3.
%#show moveOntoRobotConflict/2.
%#show testmove/3.
%#show move/3.
%#show wait/3.
%#show finalMove/3.
%#show finalMove/3.
%#show position/3.
%#show wait/2.