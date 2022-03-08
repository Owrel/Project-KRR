import sys, os
import clingo
import time
from planmerger.files import ReadFile, WriteFile

#model class
class Model:
     def __init__(self, model=None, satisfiable=None, cost=None, number=None, statistics=None, encoding=None):
        self.model = model
        self.satisfiable = satisfiable
        self.cost = cost
        self.number = number
        self.statistics = statistics
        #
        self.encoding = encoding


#clingo class
class Clingo:
    def __init__(self):
        self.models = []
        

    def solve(self, bm_program, merger):
        #callbacks
        def on_model(m):
            self.models.append([str(m),m.cost,m.number])

        self.models.clear()
        ctl = clingo.Control()
        #load files into clingo
        ctl.add("base", [], bm_program)
        ctl.load(merger)
        ctl.ground([("base", [])])
        sr = ctl.solve(on_model=on_model)

        print('Encoding: ' + str(merger))
        print("Satisfiable") if sr.satisfiable else print("Unsatisfiable")
        print("Total time: {} sec".format(ctl.statistics['summary']['times']['total']))
        print("CPU time: {} sec".format(ctl.statistics['summary']['times']['cpu']))
        print("Grounding time: {} sec".format(ctl.statistics['summary']['times']['total'] - ctl.statistics['summary']['times']['solve']))
        print("Solving time: {} sec".format(ctl.statistics['summary']['times']['solve']))
        print('Atoms : ' + str(int(ctl.statistics['problem']['lp']['atoms'])))
        print('Rules : ' + str(int(ctl.statistics['problem']['lp']['rules'])) + '\n')

        #return model
        if sr.satisfiable:
            return Model(self.get_optimal_model(), sr.satisfiable, self.models[-1][1], self.models[-1][2], ctl.statistics, os.path.split(merger)[1])
        else:
            return Model(model="", satisfiable=False)


    def isolve(self, files, merger, c_name, f, max_iter, finish=False):
        m, stats = Model(), []
        start = time.perf_counter()
        #iterate max_iter times
        for i in range(max_iter):
            #current constant value
            c = f(i)
            print("Iteration {} with {}={}".format(i+1,c_name,c))
            self.set_constant(merger, c_name, c)
            m = self.solve(files, merger)
            stats.append(m.statistics)
            #stop if satisfiable
            if s and not finish:
                print("\nTotal execution time: {} sec\n".format(time.perf_counter()-start))
                return m, stats
        #return model of last iteration
        if s:
            return m, stats
        #no model found
        else:
            return Model(), []
    

    def set_constant(self, file, name, value):
        lp_mod = ""
        for line in ReadFile(file).split("\n"):
            if "#const" in line and name in line:
                # insert value for constant
                line = line[:line.find("=")+1] + str(value) + line[line.find("."):]
            lp_mod += line+"\n"
        WriteFile(file, lp_mod)


    def get_optimal_model(self):
        if len(self.models) != 0:
            return self.models[-1][0].replace(" ",". ")+"."
        else:
            return Model()


    def load_viz(self, model, output="../output.txt"):
        #save model into output.txt
        WriteFile(output, model)
        #open visualizer
        cmd = "viz -t {}".format(output)
        os.system(cmd)