# use with python MustChangeDestinationCreator.py | viz
def instanceFromNumberOfRobots(numRobots):
    instance = ""
    # Nodes
    for i in range(1, numRobots*2 +1):
        instance += "init(object(node, "+str(i)+"), value(at, (1, "+str(i)+"))).\n"
    # Robots
    for i in range(1, numRobots +1 ):
        instance += "init(object(robot,"+str(i)+"), value(at,(1,"+str(i)+"))).\n"
        instance += "init(object(robot,"+str(i)+"), value(max_energy,0)).\n"
        instance += "init(object(robot,"+str(i)+"), value(energy,0)).\n"
    # Shelves
    for i in range(1, numRobots+1 ) :
        instance += "init(object(shelf,"+str(i)+"), value(at,(1,"+str(i+numRobots)+"))).\n"
        instance += "init(object(product, "+str(i)+"), value(on,(1,"+str(i)+"))).\n"
        instance += "init(object(order, "+str(i)+"), value("+str(i)+", 1)).\n"
    # Move Commands
    distance = -1
    for i in range(numRobots, 0, -1) :
        distance += 2
        for step in range(distance) :
            instance += "occurs(object(robot,"+str(i)+"), action(move, (0,1)),"+str(step+1)+")."
    return instance
print(instanceFromNumberOfRobots(2))