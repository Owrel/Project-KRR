%%%---------------------------------%%%
% test for preemptive(optimal?) planswitching
% Jakob Westphal
%%%---------------------------------%%%

%%% ----------------------- setup -------------------------------------------- %%%
%horizon(65).
horizon(H) :- H = #max{ 0; T : occurs( _, _, T) }.
time(0..H) :-  horizon(H).

at(R, X, Y, 0) :- init(object(robot, R), value(at, (X,Y))).
moves(R, DX, DY, T) :- occurs(object(robot, R), action(move, (DX,DY)), T).
node(X,Y) :- init(object(node, N),value(at, (X,Y))).
robot(R) :- init(object(robot, R), _).

at(R, X+DX, Y+DY, T) :- at(R, X, Y, T-1), moves(R, DX, DY, T), time(T).

%%% -------------------------- collisions --------------------------------------- %%%
% normal edge collision
edgecollision(R1, R2, T) :- at(R1, X1, Y1, T);
                            at(R2, X2, Y2, T);
                            at(R1, X2, Y2, T-1);
                            at(R2, X1, Y1, T-1);
                            R1 < R2, |X2-X1|+|Y2-Y1|==1, time(T).

% 2 robots switch places during 2 timesteps
%nodeswitchcollision(R1, R2, T) :- at(R1, X1, Y1, T+1);
%                            at(R2, X2, Y2, T+1);
%                            at(R1, X2, Y2, T-1);
%                            at(R2, X1, Y1, T-1);
%                            R1 < R2, |X2-X1|+|Y2-Y1|==2, time(T).

% 1 robot reached his final position (is now sleeping) and another robot tries to pass over it
%endpos(R, X, Y, T) :- at(R, X, Y, T), not at(R, _, _, T+1), node(X, Y), time(T).
%sleepingcollision(R1, R2, T') :- endpos(R1, X, Y, T), at(R2, X, Y, T'), T' > T, R1 != R2.

% check between which robots a collision occurs
collision(R1, R2) :- edgecollision(R1, R2, _).
%collision(R1, R2) :- nodeswitchcollision(R1, R2, _).
%collision(R1, R2) :- sleepingcollision(R1, R2, _).
collision(R2, R1) :- collision(R1, R2).


%%% ------------------------ plan switching ------------------------------------- %%%
% detect if 2 robots are ever on the same node
same_pos(R1, R2, X, Y, T1, T2) :- collision(R1, R2), R1 < R2, at(R1, X, Y, T1), at(R2, X, Y, T2), time(T1), time(T2).
same_pos(R2, R1, X, Y, T2, T1) :- same_pos(R1, R2, X, Y, T1, T2).

% find the earliest time that 2 specific robots are on the same position
late_pos(R1, R2, X, Y, T1) :- same_pos(R1, R2, X, Y, T1, T2), same_pos(R1, R2, X', Y', T1', T2'), T1 > T1'.
earliest_pos(R1, R2, X, Y, T, T2) :- same_pos(R1, R2, X, Y, T, T2), not late_pos(R1, R2, X, Y, T).

% randomly add switches between robots
{ switch(R1, R2, X, Y, T1, T2) } :- robot(R1), robot(R2), earliest_pos(R1, R2, X, Y, T1, T2).

% only one switch per robot
:- switch(R1, R2, _, _, _, _), switch(R1, R2', _, _, _, _), R2 != R2'.
% two robots can not switch to the same robot
:- switch(R1, R2, _, _, _, _), switch(R1', R2, _, _, _, _), R1 != R1'.
:- switch(R1, R2, _, _, _, _), not switch(R2, _, _, _, _, _).


%%% ----------------------- create new movement ---------------------------------- %%%
% Movement after switch
movement(R1, DX, DY, (T1+(T'-T2)) ) :- switch(R1, R2, _, _, T1, T2), moves(R2, DX, DY, T'), T' > T2.
% Movement before switch
movement(R1, DX, DY, T) :- moves(R1, DX, DY, T), switch(R1, R2, _, _, T1, T2), T <= T1.
% if no switch just copy the plan
movement(R, DX, DY, T) :- moves(R, DX, DY, T), not switch(R, _, _, _, _, _).


%%% ------------------- minimize over arrival time of each robot ------------------- %%%
% minimize over the timesteps of each robot
#minimize{ T,R : movement(R, _, _, T), robot(R) }.


#show.
%#show switch/6.
%#show at/4.
%#show final/2.
%#show movement/4.
%#show horizon/1.
%#show edgecollision/3.
%#show sleepingcollision/3.
%#show same_pos/6.
%#show earliest_pos/6.
%#show collision/2.
%#show robot/1.
#show occurs(object(robot,R), action(move, (DX,DY)), T) : movement(R, DX, DY, T).