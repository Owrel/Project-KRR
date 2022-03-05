%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Grid size X: 3
%Grid size Y: 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

%init
init(object(node, 1), value(at, (1, 1))).
init(object(node, 2), value(at, (2, 1))).
init(object(node, 3), value(at, (3, 1))).
init(object(node, 5), value(at, (2, 2))).
init(object(node, 8), value(at, (2, 3))).
init(object(robot,1), value(at,(1,1))).
init(object(robot,1), value(max_energy,0)).
init(object(robot,1), value(energy,0)).
init(object(robot,2), value(at,(3,1))).
init(object(robot,2), value(max_energy,0)).
init(object(robot,2), value(energy,0)).
init(object(shelf,1), value(at,(2,2))).
init(object(shelf,2), value(at,(2,3))).
init(object(product, 1), value(on, 1)).
init(object(product, 1), value(on, 2)).
init(object(order, 1), value(1, 1)).
init(object(order, 2), value(2, 1)).

%occurs
