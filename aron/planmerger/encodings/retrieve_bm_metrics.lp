% - RETRIEVER OF BENCHMARK METRICS ---------------------------------------------------------------------------
% retrieve important benchmark metrics
isRobot(R) :- position(R,_,_).
destination(R,C,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).
% ----------------------------------------------------------------------------------------------


% RETRIEVE METRICS
% ----------------------------------------------------------------------------------------------
% robots
n_r(R) :- isRobot(R).
% positions
n_p(R,C,T) :- position(R,C,T).
% longest path
n_lp(0..T_MAX) :- T_MAX == #max{T : position(R,C,T)}.
% edge collision
n_ec(C,C',T) :- position(R,C,T), position(R,C',T+1), position(R',C',T), position(R',C,T+1), R!=R', C!=C'.
r_ec(R) :- position(R,C,T), position(R,C',T+1), position(R',C',T), position(R',C,T+1), R!=R', C!=C'.
% vertex collision
n_vc(C,T) :- position(R,C,T), position(R',C,T), R!=R'.
r_vc(R) :- position(R,C,T), position(R',C,T), R!=R'.
% vertex collisions with arrived robots
n_vc(C,T) :- position(R,C,T), destination(R',C,T_DEST), T>T_DEST, R!=R'.
r_vc(R) :- position(R,C,T), destination(R',C,T_DEST), T>T_DEST, R!=R'.
% fake edge collision
n_fec(C,C',T) :- position(R,C,T), position(R,C',T+2), position(R',C',T), position(R',C,T+2), R!=R', C!=C'.
r_fec(R) :- position(R,C,T), position(R,C',T+2), position(R',C',T), position(R',C,T+2), R!=R', C!=C'.
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
#show.
#show n_p/3.
#show n_lp/1.
#show n_ec/3.
#show r_ec/1.
#show n_vc/2.
#show r_vc/1.
#show n_r/1.
#show n_fec/3.
#show r_fec/1.
% ----------------------------------------------------------------------------------------------
