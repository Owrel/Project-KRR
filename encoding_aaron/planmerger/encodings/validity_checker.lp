% - VALIDITY CHECKER ---------------------------------------------------------------------------
% check validity of the merged plans

% INPUT
% ----------------------------------------------------------------------------------------------
#include "./input.lp".
% ----------------------------------------------------------------------------------------------


% READING PLANS
% ----------------------------------------------------------------------------------------------
% reading plans
move(robot(R),(DX,DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T).

% calculate original positions recursively
position(R,(X+DX,Y+DY),T+1) :- move(R,(DX,DY),T), position(R,(X,Y),T), isRobot(R).
destination(R,C,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).
% ----------------------------------------------------------------------------------------------


% CONFLICTS
% ----------------------------------------------------------------------------------------------
% edge collision
:- position(R,C,T), position(R,C',T+1), position(R',C',T), position(R',C,T+1), R!=R', C!=C', isRobot(R), isRobot(R').
% vertex collision
:- position(R,C,T), position(R',C,T), R!=R', isRobot(R), isRobot(R').
% vertex collisions with arrived robots
:- position(R,C,T), destination(R',C,T_DEST), T>T_DEST, R!=R', isRobot(R), isRobot(R').
% robots only move on valid nodes
:- position(R,C,T), not position(C), isRobot(R).
% moves only have a magnitude of 0 or 1
dir((X,Y)) :- move(R,(X,Y),T).
:- dir((X,Y)), X < -1.
:- dir((X,Y)), X > 1.
:- dir((X,Y)), Y < -1.
:- dir((X,Y)), Y > 1.
:- dir((X,Y)), |X|+|Y| < 0.
:- dir((X,Y)), |X|+|Y| > 1.
% ----------------------------------------------------------------------------------------------


% GOAL
% ----------------------------------------------------------------------------------------------
processed(A,R) :- ordered(O,A), shelved(S,A), isRobot(R), position(S,C,0), position(R,C,T).
processed(A) :- processed(A,R).
:- ordered(O,A), not processed(A).
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
#show.
#show init/2.
#show occurs/3.
% ----------------------------------------------------------------------------------------------
