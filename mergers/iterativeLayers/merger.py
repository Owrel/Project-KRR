import threading

import clingo
import sys
import time
import json


def filter_atoms(keep, atoms):
    atomAt = 0
    atomEnd = 1
    bracket_depth = 0
    fullatomRead = False
    filteredatoms = ""
    for a in keep:
        while a + "(" in atoms:
            fullatomRead = False
            atomAt = atoms.find(a + "(")
            atomEnd = atomAt + 1
            while not fullatomRead:
                if (atoms[atomEnd] == "("):
                    bracket_depth += 1
                if (atoms[atomEnd] == ")"):
                    bracket_depth -= 1
                    if (bracket_depth == 0):
                        fullatomRead = True
                atomEnd += 1
            filteredatoms += atoms[atomAt:atomEnd + 1]
            atoms = atoms.replace(atoms[atomAt:atomEnd], "")
    return filteredatoms


def remove_comments_and_newlines(lp_file):
    reading_comment = False
    out_lp = ""
    for char in lp_file:
        if (char == "%"):
            reading_comment = True
            continue
        if (char == "\n"):
            reading_comment = False
            continue
        if (not reading_comment):
            out_lp += char
    return out_lp


class Iterations:
    debug = False
    output_models = 1
    max_layers = 40
    max_models_per_layer = 1
    max_time_per_layer_seconds = 600
    models_per_layer = [0 for i in range(max_layers)]
    next_positions = ""
    check = ""
    occurs_to_positions = ""
    positionin_to_occurs = ""
    original_plan = ""
    original_warehouse = ""
    layerMerger = ""
    loggingFolder = "layers"
    start_time = time.time()
    models = []

    def __init__(self):
        # read files and start merge
        with open("singleLayer.lp", 'r') as file:
            self.layerMerger = remove_comments_and_newlines(file.read())
        with open("conflictCheck.lp", 'r') as file:
            self.check = remove_comments_and_newlines(file.read())
        with open("occursToPosition.lp", 'r') as file:
            self.occurs_to_positions = remove_comments_and_newlines(file.read())
        with open("originalPlan.lp", 'r') as file:
            self.original_plan = remove_comments_and_newlines(file.read())
        with open("originalWarehouse.lp", 'r') as file:
            self.original_warehouse = remove_comments_and_newlines(file.read())
        with open("positioninToOccurs.lp", 'r') as file:
            self.positionin_to_occurs = remove_comments_and_newlines(file.read())
        self.debug = "-debug" in sys.argv
        if "-output_models" in sys.argv: self.output_models = int(sys.argv[sys.argv.index("-output_models") + 1])
        if self.debug: self.logLayer(self.next_positions, 0, {})
    def toJSON(self):
        return json.dumps(self, default=lambda o: o.__dict__,
                          sort_keys=True, indent=4)
    def printModels(self):
        count = 0
        for model in self.models:
            if count < self.output_models:
                count += 1
                print(model)

    def count_model(self, layer):
        self.models_per_layer[layer] += 1

    def should_continue(self, layer):
        if layer == self.max_layers:
            return False
        if self.models_per_layer[layer] + 1 > self.max_models_per_layer:
            return False
        return True

    # read single Layer merger and conflict check
    def start_merging(self):
        self.set_positions_from_original_plan()
        self.mergeRobots(0, self.next_positions + self.layerMerger, {})

    # do this when a model was found
    def on_model(self, layer, benchmark_info):
        def do_something(m):
            if (not "solving_times" + str(layer) in benchmark_info.keys()):
                benchmark_info["solving_times" + str(layer)] = []
            benchmark_info["solving_times" + str(layer)].append(time.time() - benchmark_info["solving_start"])
            if (not "atoms" + str(layer) in benchmark_info.keys()):
                benchmark_info["atoms" + str(layer)] = []
            benchmark_info["atoms" + str(layer)].append(len(m.symbols(atoms=True)))
            # abort if there are too many models
            if (not self.should_continue(layer)):
                if self.debug and False:
                    print("aborting at layer ", layer)
                    print(self.models_per_layer)
                return
            # add to models_per_layer
            self.count_model(layer)
            if self.debug: print("model at layer ", layer, m)
            # turn model into input for program
            model_string = filter_atoms(["position", "robot", "horizon", "direction"],
                                        m.__str__().replace(" ", ".") + ".").replace("position", "positionin")
            if self.debug: self.logLayer(model_string, layer, benchmark_info)
            # if check is not satisfiable (conflicts exist) run layerMerger again
            if not self.checkSolution(model_string):
                self.mergeRobots(layer, model_string + self.layerMerger, benchmark_info)
            else:
                if self.debug:
                    print("found model at layer", layer)
                    print(model_string)
                    self.logLayer(model_string, "Model", benchmark_info)
                self.benchmark_info = benchmark_info
                self.models.append(self.model_to_occurs(model_string))
        return do_something

    def set_positions(self, positions):
        self.next_positions = filter_atoms(["positionin", "robot", "horizon", "direction"],
                                           positions.__str__().replace(" ", ".") + ".")
        if self.debug: print("..setting positions ", positions.__str__())

    def set_positions_from_original_plan(self):
        if self.debug: print("original_plan", self.original_plan)
        ctl = clingo.Control()
        ctl.add("base", [], self.original_warehouse + self.original_plan + self.occurs_to_positions)
        ctl.ground([("base", [])])
        ctl.solve(yield_=False, on_model=self.set_positions)

    def mergeRobots(self, layer, atoms, benchmark_info):
        if self.debug: print("atoms", atoms)
        ctl = clingo.Control("0")
        ctl.add("base", [], atoms)
        groundstart = time.time()
        ctl.ground([("base", [])])
        if not "grounding" in benchmark_info.keys():
            benchmark_info["grounding"] = []
        benchmark_info["grounding"].append(time.time() - groundstart)
        benchmark_info["solving_start"] = time.time()
        solve_handle = ctl.solve(yield_=False, on_model=self.on_model(layer + 1, benchmark_info))
    def checkSolution(self, solution):
        if self.debug: print("checking solution", solution + self.check)
        ctl = clingo.Control()
        ctl.add("base", [], solution + self.check)
        ctl.ground([("base", [])])
        return ctl.solve().__str__() == "SAT"

    def writeToFile(self, layer, benchmark_info):
        def do_something(m):
            print(json.dumps(benchmark_info))
            with open(self.loggingFolder + '/' + "layer_" + str(layer) + ".lp", 'w') as f:
                f.write("% time taken solving: " + str(self.get_total_solving_time(benchmark_info, 0)) + "\n" +
                        "% time taken grounding: " + str(self.get_total_grounding_time(benchmark_info)) + "\n" +
                        "% atoms: " + str(self.get_atoms(benchmark_info, 0)) + "\n"
                        + filter_atoms(["occurs"], m.__str__().replace(" ", ".")))

        return do_something

    def logLayer(self, atoms, layer, benchmark_info):
        ctl = clingo.Control()
        ctl.add("base", [], atoms + self.positionin_to_occurs)
        ctl.ground([("base", [])])
        ctl.solve(yield_=False, on_model=self.writeToFile(layer, benchmark_info))
    def model_to_occurs(self, model):
        ctl = clingo.Control()
        ctl.add("base", [], model + self.positionin_to_occurs)
        ctl.ground([("base", [])])
        modelcontainer = {}
        def on_model(modelcontainer):
            def do_something(m):
                modelcontainer["model"] = m.__str__()
                return False
            return do_something
        ctl.solve(yield_=False, on_model=on_model(modelcontainer))
        return filter_atoms(["occurs"],modelcontainer["model"])
    def get_total_solving_time(self, benchmark_info, found_at):
        i = 1
        total_time = 0
        while "solving_times" + str(i) in benchmark_info.keys():
            total_time += benchmark_info["solving_times" + str(i)][found_at]
            i += 1
        return total_time

    def get_atoms(self, benchmark_info, found_at):
        print(json.dumps(benchmark_info))
        atoms = 0
        i = 1
        print("is atoms" + str(i) + " in keys ? " + str("atoms" + str(i) in benchmark_info.keys()))
        while "atoms" + str(i) in benchmark_info.keys():
            atoms = benchmark_info["atoms" + str(i)][found_at]
            i += 1
        return atoms

    def get_total_grounding_time(self, benchmark_info):
        if not "grounding" in benchmark_info.keys():
            return 0
        total_time = 0
        for time in benchmark_info["grounding"]:
            total_time += time
        return total_time


if __name__ == "__main__":
    iterations = Iterations()
    iterations.start_merging()
    iterations.printModels()
