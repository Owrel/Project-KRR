# use with python xRobotConflictCreator.py | viz
def instanceFromNumberOfRobots(numRobots):
    instance = ""
    # Nodes
    nodeid = 1
    for row in range(1, numRobots*2 +1):
        for column in range(1, numRobots+1):
            if(not (row > numRobots and column>1) and not(column >row)):
                instance +="init(object(node, "+str(nodeid)+"), value(at, ("+str(column)+", "+str(row)+"))).\n"
                nodeid+=1
    # Robots
    for i in range(1, numRobots +1 ):
        instance += "init(object(robot,"+str(i)+"), value(at,("+str(i)+","+str(i)+"))).\n"
        instance += "init(object(robot,"+str(i)+"), value(max_energy,0)).\n"
        instance += "init(object(robot,"+str(i)+"), value(energy,0)).\n"
    # Shelves
    for i in range(1, numRobots+1 ) :
        instance += "init(object(shelf,"+str(i)+"), value(at,("+str(  1)+","+str((numRobots*2)+1-i)+")  )).\n"
        instance += "init(object(product, "+str(i)+"), value(on,("+str(  1)+","+str((numRobots*2)+1-i)+"))).\n"
        instance += "init(object(order, "+str(i)+"), value("+str(i)+", 1)).\n"
    # Move Commands
    shelfId = 0
    for robot in range(numRobots, 0, -1) :
        shelfId += 1
        leftMoves = robot -1
        downMoves = shelfId + numRobots - robot
        # Move Left
        for leftMove in range(leftMoves) :
            instance += "occurs(object(robot,"+str(robot)+"), action(move, (-1,0)),"+str(leftMove+1)+")."
        # Move Down
        for downMove in range(downMoves):
            instance += "occurs(object(robot,"+str(robot)+"), action(move, (0,1)),"+str(leftMoves+downMove+1)+")."
    return instance
print(instanceFromNumberOfRobots(5))