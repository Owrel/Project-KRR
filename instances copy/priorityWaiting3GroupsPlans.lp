% step 1
occurs(object(robot,1), action(move, (0,-1)),1).
occurs(object(robot,2), action(move, (0,-1)),1).
occurs(object(robot,3), action(move, (1,0)),1).
occurs(object(robot,4), action(move, (1,0)),1).
occurs(object(robot,5), action(move, (1,0)),1).
occurs(object(robot,6), action(move, (0,1)),1).

% step 2
occurs(object(robot,1), action(move, (1,0)),2).
occurs(object(robot,2), action(move, (0,-1)),2).
occurs(object(robot,3), action(move, (0,-1)),2).
occurs(object(robot,4), action(move, (1,0)),2).
occurs(object(robot,5), action(move, (1,0)),2).
occurs(object(robot,6), action(move, (1,0)),2).

% step 3
occurs(object(robot,1), action(move, (1,0)),3).
occurs(object(robot,2), action(move, (1,0)),3).
occurs(object(robot,3), action(move, (0,-1)),3).
occurs(object(robot,4), action(move, (1,0)),3).
occurs(object(robot,5), action(move, (1,0)),3).
occurs(object(robot,6), action(move, (1,0)),3).

% step 4
occurs(object(robot,1), action(move, (0,1)),4).
occurs(object(robot,2), action(move, (1,0)),4).
occurs(object(robot,3), action(move, (1,0)),4).
occurs(object(robot,4), action(move, (0,1)),4).
occurs(object(robot,5), action(move, (1,0)),4).
occurs(object(robot,6), action(move, (1,0)),4).

% step 5
occurs(object(robot,1), action(move, (0,1)),5).
occurs(object(robot,2), action(move, (0,1)),5).
occurs(object(robot,3), action(move, (1,0)),5).
occurs(object(robot,4), action(move, (1,0)),5).
occurs(object(robot,5), action(move, (0,-1)),5).

% step 6
occurs(object(robot,1), action(move, (0,1)),6).
occurs(object(robot,2), action(move, (0,1)),6).
occurs(object(robot,3), action(move, (0,1)),6).
occurs(object(robot,5), action(move, (1,0)),6).

% step 7
occurs(object(robot,1), action(move, (-1,0)),7).
occurs(object(robot,2), action(move, (0,1)),7).
occurs(object(robot,3), action(move, (0,1)),7).

% step 8
occurs(object(robot,2), action(move, (1,0)),8).
occurs(object(robot,3), action(move, (1,0)),8).