import clingo
import sys
def add_dots_to_atoms(atoms):
    bracket_depth =0
    out = atoms
    for i in range(0,len(atoms)):
        if(char =="("):
            bracket_depth+=1
        if(char == ")"):
            bracket_depth-=1
            if bracket_depth == 0:
                out
def filter_atoms(keep, atoms):
    atomAt = 0
    atomEnd = 1
    bracket_depth = 0
    fullatomRead = False
    filteredatoms = ""
    for a in keep:
        while a+"(" in atoms:
            fullatomRead = False
            atomAt = atoms.find(a+"(")
            atomEnd = atomAt+1
            while not fullatomRead:
                #print("lese ", atoms[atomEnd])
                if(atoms[atomEnd] == "("):
                    bracket_depth+=1
                if(atoms[atomEnd]== ")"):
                    bracket_depth-=1
                    if(bracket_depth == 0):
                        fullatomRead = True
                atomEnd+=1
            filteredatoms+=atoms[atomAt:atomEnd+1]
            atoms = atoms.replace(atoms[atomAt:atomEnd], "")
    return filteredatoms

class Iterations:
    debug = False
    output_models = 1
    max_layers = 4
    max_models_per_layer= 1
    models_per_layer = [0 for i in range(max_layers)]
    next_positions = ""
    check = ""
    occurs_to_positions = ""
    original_plan = ""
    layerMerger = ""
    models = []
    def printModels(self):
        count = 0
        for model in self.models:
            if count <self.output_models:
                count+=1
                print(model)
    def count_model(self, layer):
        self.models_per_layer[layer] +=1
    def should_continue(self, layer):
        if layer == self.max_layers:
            return False
        if self.models_per_layer[layer]+1 > self.max_models_per_layer:
            return False
        return True
    # read single Layer merger and conflict check
    def start_merging(self):
        # read files and start merge
        with open("singleLayer.lp", 'r') as file:
            self.layerMerger = file.read().replace('\n', '')
        with open("conflictCheck.lp", 'r') as file:
            self.check = file.read().replace('\n', '')
        with open("occursToPosition.lp", 'r') as file:
            self.occurs_to_positions = file.read().replace('\n', '')
        with open("originalPlan.lp", 'r') as file:
            self.original_plan = file.read().replace('\n', '')
        self.debug = "-debug" in sys.argv
        self.set_positions_from_original_plan()
        if "-output_models" in sys.argv: self.output_models = int(sys.argv[sys.argv.index("-output_models")+1])
        self.mergeRobots(0, self.next_positions+self.layerMerger)

    # do this when a model was found
    def on_model(self, layer):
        def do_something(m):
            # abort if there are too many models
            if(not self.should_continue(layer)):
                #if self.debug:
                #    print("aborting at layer ", layer)
                #    print(self.models_per_layer)
                return
            # add to models_per_layer
            self.count_model(layer)
            if self.debug : print("model at layer ",layer , m)
            # turn model into input for program
            model_string = filter_atoms(["position","robot", "horizon", "direction"],m.__str__().replace(" ", ".")+".").replace("position", "positionin")
            # if check is not satisfiable (conflicts exist) run layerMerger again
            if not self.checkSolution(model_string):
                self.mergeRobots(layer, model_string+self.layerMerger)
            else:
                if self.debug:
                    print("found model at layer",layer)
                    print(model_string)
                self.models.append(model_string)
        return do_something

    def set_positions(self, positions):
        self.next_positions = filter_atoms(["positionin","move" "robot", "horizon", "direction"], positions.__str__().replace(" ", ".")+".")
        if self.debug: print("..setting positions ", positions.__str__())

    def set_positions_from_original_plan(self):
        if self.debug: print("original_plan", self.original_plan)
        ctl = clingo.Control()
        ctl.add("base", [], self.original_plan+self.occurs_to_positions)
        ctl.ground([("base", [])])
        ctl.solve(yield_ = False,on_model=self.set_positions)

    def mergeRobots(self, layer, atoms):
        if self.debug: print("atoms", atoms)
        ctl = clingo.Control("0")
        ctl.add("base", [], atoms)
        ctl.ground([("base", [])])
        ctl.solve(yield_= False,on_model=self.on_model(layer+1))

    def checkSolution(self, solution):
        if self.debug:print("checking solution", solution+self.check)
        ctl = clingo.Control()
        ctl.add("base", [], solution + self.check)
        ctl.ground([("base", [])])
        return ctl.solve().__str__()== "SAT"
iterations = Iterations()
iterations.start_merging()
iterations.printModels()