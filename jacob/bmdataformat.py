import json

class BMDataFormat:
    def __init__(self, model, acc_stats):
        self.data = {
            "groupName" : "Nils, Daniel & Jakob",
            "solverName" : "Plan Switching + Waiting - Sequential multishot Approach",

            "problemType" : None,
            "objective" : "Sum of timesteps for all robots, number of collisions left",
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
        self.addAccumulatedInfo(model, acc_stats)

    def addAccumulatedInfo(self, model, acc_stats):
        self.data['objective_cost'] = acc_stats[-1]

        self.data["statistics"] = {
            "groundingTime" : acc_stats[1],
            "solvingTime" : acc_stats[2],
            "total" : acc_stats[0],
            "atoms" : acc_stats[5],
            "rules" : acc_stats[6]
        }
        self.data["info"] = "Number of models:" + str(acc_stats[3])
        self.data["model"] = model
        
    def save(self, path):
        json_string = json.dumps(self.data, indent=4)
        self.WriteFile(path, json_string)

    def load(self, path):
        self.data = json.loads(self.ReadFile(path))
        return self.data



    def WriteFile(self, path, content):
        with open(path, 'w') as f:
            f.write(content)

    def ReadFile(self, path):
        with open(path, 'r') as f:
            content = f.read()
            return content
        return None