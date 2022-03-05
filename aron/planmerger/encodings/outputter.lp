
% input: position/3 and init/2 predicates

% OUTPUT
% ----------------------------------------------------------------------------------------------
% reconstruct final moves for output.
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- position(R,(C1X,C1Y),T), position(R,(C2X,C2Y),T+1).

% show statements
#show.
#show init/2.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).