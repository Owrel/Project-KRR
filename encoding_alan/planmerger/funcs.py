from planmerger.files import WriteFile, ReadFile
import glob
import parse as parser
import json
import os


# this function is used to read the benchmarks from the other groups
# split benchmark string into instance and plans and also convert into times starting from 0 and not 1
def splitBenchmarkString(benchmark):
    instance = ''
    plans = ''
    occurs = 'occurs(object(robot,{}),action(move,({},{})),{}).'
    # check if occurs statement starts with T=0 or T=1
    ts = []
    for line in benchmark.split('\n'):
        if 'occurs(' in line:
            parsed = parser.parse(occurs, line)
            ts.append(int(parsed[3]))

    offset = 0
    if min(ts) == 1:
        offset = -1

    # do the actual splitting and converting
    for line in benchmark.split('\n'):
        if 'occurs(' in line:
            plans += line + '\n'
        else:
            instance += line + '\n'
    return instance, offsetPlans(plans, offset)


def offsetPlans(plans, offset):
    new_plans = ''
    occurs = 'occurs(object(robot,{}),action(move,({},{})),{}).'
    for line in plans.split('\n'):
        if 'occurs(' in line:
            for fact in line.split('.'):
                if 'occurs(' in fact:
                    parsed = parser.parse(occurs, fact+'.')
                    new_plans += occurs.format(parsed[0],parsed[1],parsed[2],int(parsed[3])+offset) + '\n'
    return new_plans


def getBenchmarkFiles(bm_dir,ext=".lp"):
    instance = glob.glob("{}/instance/*{}".format(bm_dir,ext))
    plans = glob.glob("{}/plans/plan_r*{}".format(bm_dir,ext))
    return instance, plans


# this function is used within the Merger class and reads a path of a benchmark and return an instance and the plans in string format
def getBenchmarkProgram(path):
    if os.path.isfile(path):
        return splitBenchmarkString(ReadFile(path))
    else:
        instance, plans = getBenchmarkFiles(path)
        return "".join([ReadFile(file) for file in instance]), "".join([ReadFile(file) for file in plans])


def getAllBenchmarks(directory="benchmarks"):
    return sorted(glob.glob("{}/*/".format(directory)))


def parse(model,pattern,index):
    li = []
    for atom in model.split(" "):
        parsed = parser.parse(pattern, atom)
        li.append(int(parsed[index]))
    return li


# accumulated important statistics
class AccumulatedStats:
    def __init__(self):
        self.groundingTime = 0.0
        self.solvingTime = 0.0
        self.total = 0.0
        self.atoms = 0.0
        self.rules = 0.0
        #additional info
        self.encodings = []
        self.costs = []

    def add(self, model):
        if model.satisfiable:
            self.groundingTime += model.statistics['summary']['times']['total'] - model.statistics['summary']['times']['solve']
            self.solvingTime += model.statistics['summary']['times']['solve']
            self.total = self.groundingTime + self.solvingTime
            self.atoms += model.statistics['problem']['lp']['atoms']
            self.rules += model.statistics['problem']['lp']['rules']
            #
            self.encodings.append(model.encoding)
            self.costs.append(model.cost)
        else :
            print(model)
            self.groundingTime = None
            self.solvingTime = None
            self.total = None
            self.atoms = None
            self.rules = None
            #
            self.encodings.append(model.encoding)
            self.costs.append(model.cost)


# json benchmark data
class BMDataFormat:
    def __init__(self, model=None, acc_stats=None):
        self.data = {
            "groupName" : "Allan",
            "solverName" : "Sequential Approach",

            "problemType" : None,
            "objective" : None,
            "objective_cost" : [],

            "instance" : None,
            "statistics" : {
                "groundingTime" : 0.0,
                "solvingTime" : 0.0,
                "total" : 0.0,
                "atoms" : 0.0,
                "rules" : 0.0
		    },
            "info" : None,
            "model" : None
	    }
        if model and not acc_stats:
            self.addModelInfo(model)
        elif model and acc_stats:
            self.addAccumulatedInfo(model, acc_stats)

    def addModelInfo(self, model):
        self.data['solverName'] = model.encoding
        self.data['objective_cost'] = model.cost

        self.data["statistics"] = {
            "groundingTime" : model.statistics["summary"]["times"]["total"] - model.statistics["summary"]["times"]["solve"],
            "solvingTime" : model.statistics["summary"]["times"]["solve"],
            "total" : model.statistics["summary"]["times"]["total"],
            "atoms" : model.statistics['problem']['lp']['atoms'],
            "rules" : model.statistics['problem']['lp']['rules']
        }
        self.data["model"] = model.model

    def addAccumulatedInfo(self, model, acc_stats):
        self.data['solverName'] = '+'.join(acc_stats.encodings)
        self.data['objective_cost'] = acc_stats.costs

        self.data["statistics"] = {
            "groundingTime" : acc_stats.groundingTime,
            "solvingTime" : acc_stats.solvingTime,
            "total" : acc_stats.total,
            "atoms" : acc_stats.atoms,
            "rules" : acc_stats.rules
        }
        self.data["model"] = model.model
        
    def save(self, path):
        json_string = json.dumps(self.data, indent=4)
        WriteFile(path, json_string)

    def load(self, path):
        self.data = json.loads(ReadFile(path))
        return self.data