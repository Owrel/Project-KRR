% - non-deterministic incremental waiter for sequential approach -----------------------------------

% init
isRobot(R) :- position(R,_,_).

% find times for waitable positions
has_vc(R,R') :- position(R,C,T), position(R',C,T), R!=R'.
waitable(R,T) :- has_vc(R,R'), position(R,C,T+1), position(R',C,T'), R!=R'.
waitable(R,T) :- waitable(R',T), position(R,C,T+1), position(R',C,T'), R!=R'.
not_earliest_waitable(R,T) :- waitable(R,T), waitable(R,T'), T>T'.
earliest_waitable(R,T) :- not not_earliest_waitable(R,T), waitable(R,T).

% either wait at one waitable timestep or don't
{wait(R,T) : earliest_waitable(R,T)}1 :- isRobot(R).

% reconstruct positions
% before wait
position_(R,C,T) :- wait(R,T_WAIT), T<=T_WAIT, position(R,C,T).
% after wait
position_(R,C,T) :- wait(R,T_WAIT), T>T_WAIT, position(R,C,T-1).
% keep positions if no wait
wait(R) :- wait(R,T).
position_(R,C,T) :- not wait(R), position(R,C,T).

% find new vertex collisions
horizon(R,T_MAX-1) :- T_MAX == #count{T : position_(R,C,T)}, isRobot(R).
vc_cost(R,T,(T_MAX-T)*(T_MAX-T)) :- position_(R,C,T), position_(R',C,T), R!=R', horizon(R,T_MAX).

% INTEGRITY CONSTRAINTS
% ----------------------------------------------------------------------------------------------
% remove new edge collision
:- position_(R,C,T), position_(R,C',T+1), position_(R',C',T), position_(R',C,T+1), R!=R', C!=C'.
% remove new fake edge collision
:- position_(R,C,T), position_(R,C',T+2), position_(R',C',T), position_(R',C,T+2), R!=R', C!=C'.
% remove new vertex collisions with arrived robots
destination(R,C,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).
:- position_(R,C,T), destination(R',C,T_DEST), T>T_DEST, R!=R'.
% ----------------------------------------------------------------------------------------------

% OPTIMIZATION
% ---------------------------------------------------------------------------------------------
% minimize number of waits
#minimize {1@1,R : wait(R,T)}.
% minimize number of vertex_collisions or at least delay them
#minimize {C@2,R,T : vc_cost(R,T,C)}.

% ----------------------------------------------------------------------------------------------

% output
#show.
#show position_/3.
