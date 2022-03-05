from planmerger.iclingo import Clingo, Model
import planmerger.funcs as funcs
from planmerger.funcs import BMDataFormat, AccumulatedStats
import os
import planmerger.files as files


def merger(encodings_path, benchmark, save_dir):
    # ENTER PATHS
    #################################################################################
    encoding1 = os.path.join(encodings_path, "planmergeersatz.lp")
    encoding2 = os.path.join(encodings_path, "planmerge7.lp")
    encoding3 = os.path.join(encodings_path, "verandern4.lp")
    #################################################################################

    # init
    #bm_init, bm_occurs = funcs.getBenchmarkProgram(benchmark)
    clg = Clingo()
    acc_stats = AccumulatedStats()
    # SEQUENTIAL PLAN MERGING
    #################################################################################
    # step 1
    f = files.ReadFile(benchmark)
    m = clg.solve(f, encoding1)
    acc_stats.add(m)

    print(m.model)

    # step 2
    m = clg.solve(m.model, encoding2)
    acc_stats.add(m)

    # step 3
    m = clg.solve(m.model, encoding3)
    acc_stats.add(m)

    # shift plans starting from 1 to 0
    model = '.\n'.join(m.model.replace(' ','').split('.'))
    bm_init, bm_occurs = funcs.splitBenchmarkString(model)
    m.model = (bm_init+bm_occurs).replace('\n',' ')
                
    #prepare benchmark data format
    if benchmark[-1] == '\\' or benchmark[-1] == '/':
        benchmark = benchmark[0:-1]
    head, tail = os.path.split(benchmark)
    print("FINAL STATISTICS:\nBenchmark: {}\nTotal time: {}\nGrounding time: {}\nSolving time: {}\n".format(tail,acc_stats.total,acc_stats.groundingTime,acc_stats.solvingTime))
    m_data = BMDataFormat(m, acc_stats)
    m_data.data["instance"] = tail
    m_data.save(os.path.join(save_dir, tail +".json"))

    # load model into vizalizer
    #clg.load_viz(m.model)
    #################################################################################
