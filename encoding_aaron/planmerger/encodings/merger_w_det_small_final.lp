% GET INTERSECTS AND COLLISIONS / PROPERTIES OF ORIGINAL PLANS
% ----------------------------------------------------------------------------------------------
isRobot(R) :- position(R,C,T).

collision(R,R',C,T) :- isRobot(R), isRobot(R'), position(R,C,T), position(R',C,T), R!=R'.

not_early_collsion(R,R',C,T) :- collision(R,R',C,T), collision(R,R',C',T'), T>T'.

earliest_collision(R,R',C,T) :- collision(R,R',C,T), not not_early_collsion(R,R',C,T).

intersect(R,R',C,T,T') :- isRobot(R), isRobot(R'), position(R,C,T), position(R',C,T'), R!=R'.

not_early_intersect(R,R',C,T,D) :- intersect(R,R',C,T,D), intersect(R,R',C',T',D'), T>T'.

earliest_intersect(R,R',C,T,D) :- intersect(R,R',C,T,D), not not_early_intersect(R,R',C,T,D).

not_last_intersect(R,R',C,T,D) :- intersect(R,R',C,T,D), intersect(R,R',C',T',D'), T<T'.

last_intersect(R,R',C,T,D) :- intersect(R,R',C,T,D), not not_last_intersect(R,R',C,T,D).

later_at_collision(R,R',C,T',T) :- earliest_collision(R',R'',C,T'), position(R,C,T), T>T'.

% save last timestep for each robots to check priority
last_time(R,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).
% ----------------------------------------------------------------------------------------------


% GET WAITS SO FAR AND ROBOT PRIORITIES AT COLLISIONS
% ----------------------------------------------------------------------------------------------
waited_so_far(R,0,0):- isRobot(R).

waited_so_far(R,T+1,A):- waited_so_far(R,T,A), position(R,_,T+1), not do_wait(R,_,T,_).

waited_so_far(R,T+1,A+B):- waited_so_far(R,T,A), position(R,_,T+1), do_wait(R,C,T,B).

% sort robots that collide
higher(R,R'):- earliest_collision(R,R',C,T), last_time(R,D), last_time(R',D'), D-T<D'-T.
higher(robot(A),robot(B)):- earliest_collision(robot(A),robot(B),C,T), last_time(robot(A),D), last_time(robot(B),D'), D-T=D'-T, A<B.


prio(R,C,T,A) :- earliest_collision(R,R'',C,T),  A == #count{1,R' : collision(R,R',C,T), higher(R,R')}.

new_robots_ahead(R,C,T,A) :- earliest_collision(R,R'',C,T),  A == #count{1,R' : earliest_collision(R,R',C,T), higher(R,R')}.

wait_for(R,C,T,W'-P'+B'+P) :- earliest_collision(R,R',C,T), prio(R',C,T,P'), prio(R,C,T,P) , new_robots_ahead(R',C,T,B'), waited_so_far(R',T-1,W'), P'<P.

not_wait_for(R,C,T,P) :- wait_for(R,C,T,P), wait_for(R,C,T,P'), P<P'.
% ----------------------------------------------------------------------------------------------

% CALCULATE NUMBER OF WAITS
% ----------------------------------------------------------------------------------------------
% set number of waits before each collsion.
do_wait(R,C,T-1,A-W) :- waited_so_far(R,T-1,W), wait_for(R,C,T,A), not not_wait_for(R,C,T,A), A-W>=0.

% wait for collisions ahead on robot path
do_wait(R,C,T-1,A-W) :- later_at_collision(R,R',C,T,T'), prio(R',C,T,P), not prio(_,C,T,P+1), waited_so_far(R',T,A), waited_so_far(R,T-1,W).

%find waits that occur after next do_wait
overwait(R,T,T'):- do_wait(R,C,T,A), do_wait(R,C',T',A'), T'<T+A, T'>T.

overwait(R,T,T'):- do_wait(R,C,T,A), overwait(R,T'',T), do_wait(R,C,T',A'), T'<T+A+T-T'', T'>T.

%calculate waits
wait(R,C,T..T+A-1):- do_wait(R,C,T,A), not overwait(R,T,_), not overwait(R,_,T).

wait(R,C,T..T'-1):- do_wait(R,C,T,A), overwait(R,T,T').

wait(R,C,T..T+A+T-T'-1):- do_wait(R,C,T,A), overwait(R,T',T), not overwait(R,T,_).
% ----------------------------------------------------------------------------------------------


% CALCULATE FINAL POSITIONS INCLUDING WAITING
% ----------------------------------------------------------------------------------------------
% set first final_position for recursion
final_position(R,C,0,0) :- position(R,C,0), isRobot(R).
% create final positions recursively
% either wait at the same position
final_position(R,C,T+1,N+1) :- final_position(R,C,T,N), wait(R,_,T).
% or take the next step in plan
final_position(R,C',T+1,N) :- position(R,C',T-N+1), not wait(R,_,T), final_position(R,C,T,N).
% ----------------------------------------------------------------------------------------------

% OUTPUT
% ----------------------------------------------------------------------------------------------
% vertex collision, as a fact for debugging
final_vertex(R,R',C,T):- final_position(R,C,T,N), final_position(R',C,T,N'), R!=R'.


position_(R,C,T) :- final_position(R,C,T,N).



% show statements
#show.
#show final_vertex/4.
#show position_/3.
