
def outputToVizualizerPlan(output):
    atomList = output.split()
    visualizerPlan = ""
    for atom in atomList:
        if "finalMove" == atom[0:9]:
            splitAtom = atom.replace("finalMove", "").replace("(", "").replace(")","").split(",")
            visualizerPlan+= "occurs(object(robot,{}), action(move, ({},{})),{}).\n".format(splitAtom[0], splitAtom[1], splitAtom[2], splitAtom[3])

    return visualizerPlan

import sys
with open(sys.argv[1], 'r') as file:
    data = file.read().replace('\n', '')
    print(outputToVizualizerPlan(data))