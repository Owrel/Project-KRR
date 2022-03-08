% - input -----------------------------------------------------------------------
% reading plans and outputting positions

% READING PLANS
% ----------------------------------------------------------------------------------------------
% reading plans
position(robot(R),(X,Y),0) :- init(object(robot,R),value(at,(X,Y))).
move(robot(R),(DX,DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T).

% calculate original positions recursively
position(R,(X+DX,Y+DY),T+1) :- move(R,(DX,DY),T), position(R,(X,Y),T).
%lastposition(R,C,T) :- position(R,C,T), not position(R,,T+1), isRobot(R).
% ----------------------------------------------------------------------------------------------

% show statements
#show.
#show position/3.
