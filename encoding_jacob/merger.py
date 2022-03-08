import clingo
import numpy as np
import time
import sys, os
from bmdataformat import BMDataFormat


class Model:
     def __init__(self, model=None, cost=None, number=None, stats=None):
        self.model = model
        self.cost = cost
        self.number = number
        self.stats = stats


class Merger:
    def __init__(self, instance, max_iter=100, verbose=False):
        self.instance = instance
        f = open(instance+".plan","r")
        self.plan = f.read()
        f.close()
        self.max_iter = max_iter
        self.verbose = verbose
        self.models = []
        self.stats = []
        self.totals = []
        self.wm1 = "encodings/wait_merger1.lp"
        self.wm2 = "encodings/wait_merger2.lp"
        self.pm1 = "encodings/planswitch_merger1.lp"
        self.pm2 = "encodings/planswitch_merger2.lp"
        self.pm3 = "encodings/planswitch_merger3.lp"
        self.benchmark = instance[instance.rfind("/")+1:instance.rfind(".")]


    def on_model(self, m):
        self.models.append(Model(self.to_plan(str(m)), m.cost, m.number))

    def to_plan(self, model):
        return model.replace(" ", ".\n") + "."


    def solve(self, merger):
        ctl = clingo.Control()
        ctl.load(merger)
        ctl.load(self.instance)
        ctl.add("base", [], self.plan)
        ctl.ground([("base", [])])
        ctl.solve(on_model=self.on_model)
        self.models[-1].stats = ctl.statistics
        self.save_stats(self.models[-1])
        self.plan = self.models[-1].model
        if self.verbose:
            self.print_stats(self.stats[-1])

    def planswitch(self):
        self.solve(self.pm1)
        self.solve(self.pm2)
        old_cost = self.models[-1].cost
        self.solve(self.pm3)
        cost = self.models[-1].cost
        iter = 0
        while (cost != old_cost and iter != self.max_iter):
            old_cost = cost
            self.solve(self.pm3)
            cost = self.models[-1].cost
            iter += 1

    def wait(self):
        iter = 0
        cost = [1, 1]
        while iter < 2 and cost != [0, 0]:
            self.solve(self.wm1)
            cost = self.models[-1].cost[:2]
            iter += 1

        while cost != [0, 0] and iter != self.max_iter:
            self.solve(self.wm2)
            cost = self.models[-1].cost[:2]
            iter += 1
    
    def merge(self, save=True, save_dir=None):
        self.planswitch()
        self.wait()
        self.set_total_stats()

        self.reportBenchmarkData(save, save_dir)


    def save_stats(self, model):
        self.stats.append([model.stats['summary']['times']['total'],
            model.stats['summary']['times']['total'] - model.stats['summary']['times']['solve'],
            model.stats['summary']['times']['solve'],
            model.number,
            model.stats['solving']['solvers']['choices'],
            model.stats['problem']['lp']['atoms'],
            model.stats['problem']['lp']['rules'],
            model.cost])

    def set_total_stats(self):
        stats = np.array(self.stats,dtype=object)
        self.totals = []
        for i in range(stats.shape[1]-1):
            self.totals.append(np.sum(stats[:,i]))
        self.totals.append([stats[-1][-1][-1],stats[-1][-1][0]+stats[-1][-1][1]])

    def print_stats(self, stats):
        print("Total merge time: {} sec".format(stats[0]))
        print("Grounding time: {} sec".format(stats[1]))
        print("Solving time: {} sec".format(stats[2]))
        print("Number of models: {}".format(stats[3]))
        print("Choices : {}".format(stats[4]))
        print("Atoms : {}".format(stats[5]))
        print("Rules : {}".format(stats[6]))
        print("Optimization : {}\n".format(stats[7]) + '\n')  

    def reportBenchmarkData(self, save, save_dir=None):
        print("FINAL STATISTICS:\nBenchmark: {}\nTotal time: {}\nGrounding time: {}\nSolving time: {}\n".format(self.benchmark,self.totals[0],self.totals[1],self.totals[2]))
        if save:
            m_data = BMDataFormat(self.plan, self.totals)
            m_data.data["instance"] = self.benchmark

            if not save_dir:
                save_path = self.benchmark + ".json"
            else:
                if not os.path.exists(save_dir):
                    os.mkdir(save_dir)
                save_path = os.path.join(save_dir, self.benchmark +".json")
            m_data.save(save_path)
            print('saving benchmark data into: {}'.format(save_path))