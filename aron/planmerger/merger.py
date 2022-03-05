#import libraries
from planmerger.iclingo import Clingo, Model
import planmerger.funcs as funcs
from planmerger.funcs import BMDataFormat, AccumulatedStats
import matplotlib.pyplot as plt
import numpy as np
import os
import planmerger.files as files

# class for the final merger
class Merger:
    def __init__(self, encodings_dir, bm_data_dir=None):
        # gather all encodings and assign them to variables
        self.inputter = os.path.join(encodings_dir, "inputter.lp")
        self.plan_switcher = os.path.join(encodings_dir, "merger_ps_small_final.lp")
        self.plan_switcher_big = os.path.join(encodings_dir, "merger_ps_big_final.lp")
        self.waiter_inc = os.path.join(encodings_dir, "merger_w_inc_final.lp")
        self.waiter_det = os.path.join(encodings_dir, "merger_w_det_small_final.lp")
        self.waiter_det_big = os.path.join(encodings_dir, "merger_w_det_big_final.lp")
        self.outputter = os.path.join(encodings_dir, "outputter.lp")
        self.validity_checker = os.path.join(encodings_dir, "validity_checker.lp")
        self.retriever = os.path.join(encodings_dir, "retrieve_bm_metrics.lp")

        # save benchmark data directory
        self.bm_data_dir = bm_data_dir

        # initialize the clingo class
        self.clg = Clingo()


    # core merging method
    def merge(self, benchmark, vizualize=False, save_data=True, automated=True, deterministic_waiter=False, check_validity=True, save_dir=None):
        if automated:
            #defaults
            deterministic_waiter = False
        print(self.getBenchmarkModel(benchmark).model)
        # read paths only and put into position/3 predicates
        model, _ = self.convertToPositions(self.getBenchmarkModel(benchmark))
        
        # switch plans
        model, acc_stats = self.switchPlans(model, AccumulatedStats(), small=True)

        if automated:
            # switch from non-deterministic to deterministic waiter if the benchmark has more than or equal to 8 robots involved in vertex collisions
            metrics, _ = self.retrieveBenchmarkMetrics(model)
            if metrics['r_vc'] >= 8:
                deterministic_waiter = True
                
        # switch plans again with big plan switcher if deterministic waiter is selected
        if deterministic_waiter:
            model, acc_stats = self.switchPlans(model, acc_stats, small=False)

        # wait
        model, acc_stats = self.wait(model, acc_stats, deterministic=deterministic_waiter)

        # output
        model, _ = self.convertToAsprilo(model, benchmark)
        # check validity if preferred
        if check_validity:
            model, _ = self.checkValidity(model)
        # save benchmark data if preferred
        self.reportBenchmarkData(benchmark, model, acc_stats, save_data, save_dir=save_dir)
        # vizualize if preferred
        if vizualize:
            self.vizualize(model)
        # return
        return model, acc_stats
      
     
    def convertToPositions(self, model, acc_stats=None):
        if not acc_stats:
            acc_stats = AccumulatedStats()
        # read paths only and put into position/3 predicates
        if "occurs" in model.model:
            return self.solve(model, self.inputter, acc_stats)
        else:
            #bypass
            return model, acc_stats


    def switchPlans(self, model, acc_stats=None, small=True):
        # transform occurs/3 predicate to position/3 predicates if necessary
        model, acc_stats = self.convertToPositions(model, acc_stats)
        # do small or big plan switching
        if small:
            model, acc_stats = self.fix_point_solve(model, self.plan_switcher, acc_stats)
        else:
            model, acc_stats = self.fix_point_solve(model, self.plan_switcher_big, acc_stats)
        return model, acc_stats


    def wait(self, model, acc_stats=None, deterministic=True):
        # transform occurs/3 predicate to position/3 predicates if necessary
        model, acc_stats = self.convertToPositions(model, acc_stats)
        # do deterministic or non-deterministic waiting
        if deterministic:
            # first try small deterministic waiter
            tmp_model, acc_stats = self.solve(model, self.waiter_det, acc_stats)
            # check for potential vertex collision remnants
            if "final_vertex" in tmp_model.model:
                print("final_vertex occurences: {}".format(tmp_model.model.count("final_vertex")))
                # try the big deterministic waiter to get rid of these last vertex collisions
                model, acc_stats = self.solve(model, self.waiter_det_big, acc_stats)
                # check for potential vertex collision remnants
                if "final_vertex" in model.model:
                    print("final_vertex occurences: {}".format(model.model.count("final_vertex")))
                    # try the incremental and non-deterministic waiter to rid these last vertex collisions
                    model, acc_stats = self.wait(model, acc_stats, deterministic=False)
            else:
                return tmp_model, acc_stats
        else:
            model, acc_stats = self.fix_point_solve(model, self.waiter_inc, acc_stats)
        return model, acc_stats


    def convertToAsprilo(self, model, benchmark, acc_stats=None):
        # transform occurs/3 predicate to position/3 predicates if necessary
        model, acc_stats = self.convertToPositions(model, acc_stats)
        # extract instance and plans from benchmark into seperate strings
        bm_init, bm_occurs = funcs.getBenchmarkProgram(benchmark)
        # output
        return self.solve(Model(bm_init+model.model), self.outputter, acc_stats)


    def checkValidity(self, model, acc_stats=None):
        if not acc_stats:
            acc_stats = AccumulatedStats()
        return self.solve(model, self.validity_checker, acc_stats)


    # auxiliary methods
    def solve(self, model, encoding, acc_stats):
        # bypass if model was not satisfiable
        if model.satisfiable == False:
            return model, acc_stats
        model = self.clg.solve(model.model, encoding)
        if model.satisfiable == False:
            print("UNSATISFIABLE: All subsequent solving is being canceled!\n")
            return model, acc_stats
        model.model = model.model.replace("position_","position")
        acc_stats.add(model)
        return model, acc_stats


    def fix_point_solve(self, model, encoding, acc_stats):
        # set model.cost and last_cost unequal
        last_cost = []
        model.cost = [1]
        counter = 1
        while model.cost != last_cost:
            print("Fix Point Solving Iteration: {}".format(counter))
            last_cost = model.cost
            model, acc_stats = self.solve(model, encoding, acc_stats)
            counter += 1
            print("Cost: {}\n".format(model.cost))
        return model, acc_stats


    def vizualize(self, model, benchmark=None):
        if benchmark:
            model, _ = self.convertToAsprilo(model, benchmark)
        # open the asprilo vizualizer on the given model
        self.clg.load_viz(model.model)


    def getBenchmarkModel(self, benchmark):
        # extract instance and plans from benchmark into seperate strings
        bm_init, bm_occurs = funcs.getBenchmarkProgram(benchmark)
        return Model(bm_init+bm_occurs)

    
    def reportBenchmarkData(self, benchmark, model, acc_stats, save, save_dir=None):
        if not model.satisfiable:
            return 0

        #prepare benchmark data format
        head, tail = os.path.split(benchmark[0:-1])
        if os.path.isfile(benchmark):
            head, tail = os.path.split(benchmark.replace('.lp',''))
        print("FINAL STATISTICS:\nBenchmark: {}\nTotal time: {}\nGrounding time: {}\nSolving time: {}\n".format(tail,acc_stats.total,acc_stats.groundingTime,acc_stats.solvingTime))
        if save:
            m_data = BMDataFormat(model, acc_stats)
            m_data.data["instance"] = tail

            if not save_dir:
                # strategy (sequence of solvers (no duplicates))
                strategy = m_data.data['solverName'].replace('.lp','').split('+')
                strategy = '+'.join(list(dict.fromkeys(strategy)))
                save_dir = os.path.join(self.bm_data_dir, strategy)

                if not os.path.exists(save_dir):
                    os.mkdir(save_dir)

            save_path = os.path.join(save_dir, tail +".json")
            m_data.save(save_path)
            print('saving benchmark data into: {}'.format(save_path))


    def retrieveBenchmarkMetrics(self, benchmark, acc_stats=None):
        # check whether benchmark is a benchmark directory path or a model of a benchmark
        if isinstance(benchmark, Model):
            model = benchmark
        else:
            model = self.getBenchmarkModel(benchmark)

        if not acc_stats:
            acc_stats = AccumulatedStats()

        # transform occurs/3 predicate to position/3 predicates if necessary
        model, acc_stats = self.convertToPositions(model, acc_stats)
        # retrieve benchmark metrics from positions
        m, acc_stats = self.solve(model, self.retriever, acc_stats)

        dct = {}
        # n robots
        dct['n_r'] = m.model.count("n_r(")
        # n positions
        dct['n_p'] = m.model.count("n_p(")
        # n longest path
        dct['n_lp'] = m.model.count("n_lp(")
        # n vertex collisions
        dct['n_vc'] = m.model.count("n_vc(")
        # n robots involved in vertex collisions
        dct['r_vc'] = m.model.count("r_vc(")
        # n edge collisions
        dct['n_ec'] = m.model.count("n_ec(")
        # n robots involved in edge collisions
        dct['r_ec'] = m.model.count("r_ec(")
         # n fake edge collisions
        dct['n_fec'] = m.model.count("n_fec(")
        # n fake robots involved in edge collisions
        dct['r_fec'] = m.model.count("r_fec(")

        return dct, acc_stats