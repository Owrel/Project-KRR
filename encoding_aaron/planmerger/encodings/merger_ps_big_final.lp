% - plan merger encoding -----------------------------------------------------------------------
% Lets two robots switch goals to remove all possible edge collisions. Only run after ps_small. Necessary as preprocessing for deterministic waiting

last_position(R,C,T) :- position(R,C,T), not position(R,_,T+1).
% ----------------------------------------------------------------------------------------------


% GET PROPERTIESS OF ORIGINAL PLANS
% ----------------------------------------------------------------------------------------------
% calculate the earliest switching spot
intersect(R,R',C,T,T') :- position(R,C,T), position(R',C,T'), R!=R'.

not_early_intersect(R,R',C,T,T') :- intersect(R,R',C,T,T'), intersect(R,R',C',T'',T'''), T>T''.
not_early_intersect(R,R',C,T,T') :- intersect(R,R',C,T,T'), intersect(R,R',C',T'',T'''), T=T'', T'>T'''.

earliest_intersect(R,R',C,T,T') :- intersect(R,R',C,T,T'), not not_early_intersect(R,R',C,T,T').

% detect collisions
edge_collision_possible(R,R',T) :- intersect(R,R',C,T,T'), intersect(R,R',C',T+1,T'-1).

not_early_collision(R,R',T) :- edge_collision_possible(R,R',T), edge_collision_possible(R,R',T'), T'<T.

earliest_collision(R,R',T) :- edge_collision_possible(R,R',T), not not_early_collision(R,R',T).

overtake_edge_collision(R,R',T,T') :- last_position(R,C,T), position(R',C,T'), R!=R', T'>T.

collision(R,R',T) :- edge_collision_possible(R,R',T).

% detect earliest switches that don't change anything
not_sound_switch(R,R') :- earliest_intersect(R,R',C,T,T'), earliest_intersect(R',R,C,T'',T'''), T'''-T=0, T''-T'=0.

% CHOOSE SWITCHING ROBOTS
% ----------------------------------------------------------------------------------------------
% calculate switching for overtake collisions
{switch(R,R',T,T')}:- overtake_edge_collision(R,R',T,T').
switch(R',R,T',T):- overtake_edge_collision(R,R',T,T'), switch(R,R',T,T').

% for each pair of robots decide to swich or not.
{switch(R,R')} :- collision(R,R',T).
switch(R',R) :- switch(R,R').

% find switching positions
switch(R,R',T,T'):- switch(R,R'), earliest_intersect(R,R',C,T,T'), not not_sound_switch(R,R').
switch(R,R',T,T'+1):- switch(R,R'), earliest_collision(R,R',T), earliest_collision(R',R,T'), not_sound_switch(R,R').
% ----------------------------------------------------------------------------------------------

% RECURSIVELY DEFINE NEW POSITIIONS
% ----------------------------------------------------------------------------------------------
% set first position_ for recursion
position_(R,C,0,R,0) :- position(R,C,0).

position_(R,C',T+1,R',N+1) :- position(R',C',N+1), position_(R,C,T,R',N), not switch(R',_,N,_).
position_(R,C',T+1,R'',D+1) :- switch(R',R'',N,D), position(R'',C',D+1), position_(R,C,T,R',N).
% ----------------------------------------------------------------------------------------------

% INTEGRITY CONSTRAINTS
% ----------------------------------------------------------------------------------------------
% Switch twice, same pair.
:- switch(R,R',T,D), switch(R,R',T',D'), T'>T.

%exclusive switching
:- switch(R,R'), switch(R,R''), R'!=R''.

%switch to different robots at the same time
:- switch(R,R',T,D), switch(R,R'',T,D'), R'!=R''.

%reach all shelfs
last_position_(R,C,T) :-position_(R,C,T,R',N), not position_(R,_,T+1,_,_).
last_position(R,C,T) :- position(R,C,T), not position(R,_,T+1).

:- last_position(R,C,T), not last_position_(_,C,_).

% can't switch on removed steps
:- switch(R,R',T,D), switch(R',R,T',D'), switch(R,R'',T'',D''), T''>T, T''<=D'.
% ----------------------------------------------------------------------------------------------

% OPTIMIZATION
% ---------------------------------------------------------------------------------------------
%get remaining collisions
final_edge_collision(R,R',T+1) :- position_(R,C,T,_,_), position_(R,C',T+1,_,_), position_(R',C',T',_,_), position_(R',C,T'+1,_,_), R!=R', C!=C'.
final_collision(R,R',T) :- final_edge_collision(R,R',T).
final_overtake_edge_collision(R,R',T,T') :- last_position_(R,C,T), position_(R',C,T',_,_), R!=R', T'>T.

horizon(T_MAX) :- T_MAX == #max{T : position_(R,C,T,X,Y)}.
%#minimize{T@5 : horizon(T)}.

#minimize {1@4,T,R : position_(R,C,T,R',D)}.

#minimize {1@3,R,R' : final_collision(R,R',T)}.

#minimize {1@1,R,R' : final_overtake_edge_collision(R,R',T,T')}.

#minimize {1@2,R,R' : final_overtake_edge_collision(R,R',T,T'), overtake_edge_collision(R,R',T,T')}.
% ----------------------------------------------------------------------------------------------

% OUTPUT
% ----------------------------------------------------------------------------------------------
position_(R,C,T) :- position_(R,C,T,X,Y).

% show statements
#show.
%#show collision/3.
%#show overtake_edge_collision/4.
%#show earliest_intersect/4.
%#show switch/4.
%#show recswitch/4.
%#show last_position/3.
%#show last_final_position/3.
%#show final_edge_collision/3.
%#show final_fake_edge_collision/3.
%#show overtake_edge_collision/4.
%#show final_overtake_edge_collision/4.
%#show final_position/5.
#show position_/3.
