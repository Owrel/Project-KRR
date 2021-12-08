# use with python NoConflictCreator.py | viz
def instanceFromNumberOfRobots(numRobots, requiredSteps):
    instance = ""
    # Nodes
    for row in range(1, numRobots +1):
        for column in range(1, requiredSteps+2):
            instance += "init(object(node, "+str(row*(requiredSteps+1)+column)+"), value(at, ("+str(column)+", "+str(row)+"))).\n"
    # Robots
    for i in range(1, numRobots +1 ):
        instance += "init(object(robot,"+str(i)+"), value(at,(1,"+str(i)+"))).\n"
        instance += "init(object(robot,"+str(i)+"), value(max_energy,0)).\n"
        instance += "init(object(robot,"+str(i)+"), value(energy,0)).\n"
    # Shelves
    for i in range(1, numRobots+1 ) :
        instance += "init(object(shelf,"+str(i)+"), value(at,("+str(requiredSteps+1)+","+str(i)+"))).\n"
        instance += "init(object(product, "+str(i)+"), value(on,("+str(requiredSteps+1)+","+str(i)+"))).\n"
        instance += "init(object(order, "+str(i)+"), value("+str(i)+", 1)).\n"
    # Move Commands
    for i in range(1, numRobots +1) :
        for step in range(requiredSteps) :
            instance += "occurs(object(robot,"+str(i)+"), action(move, (1,0)),"+str(step+1)+")."
    return instance
print(instanceFromNumberOfRobots(50,5))