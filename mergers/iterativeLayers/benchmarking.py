from merger import Iterations
import json
from pathlib import Path
import os
import multiprocessing
import time
import sys
# TODO: Benchmark output auf Aureliens output anpassen
# TODO: Benchmark ordner und Dateien auf Aureliens anpassen
class ProcessEnlosed:
    def start_merging(self, iteration, queue):
        iteration.start_merging()
        queue.put(len(iteration.models) > 0)
        queue.put(hasattr(iteration, "benchmark_info"))
        if(len(iteration.models) > 0):
            queue.put(iteration.models[0])
        if(hasattr(iteration, "benchmark_info")):
            queue.put(iteration.benchmark_info)

def count_atoms(atoms):
    bracketdepth = 0
    count = 0
    for c in atoms:
        if(c == "("):
            bracketdepth +=1
        if(c==")"):
            bracketdepth-=1
            if(bracketdepth == 0):
                count +=1
    return count
def remove_comments_and_newlines(lp_file):
    reading_comment = False
    out_lp = ""
    for char in lp_file:
        if(char == "%"):
            reading_comment = True
            continue
        if(char =="\n"):
            reading_comment = False
            continue
        if(not reading_comment):
            out_lp += char
    return out_lp
def benchmark_to_json(benchmark, model,instance, time):
    return {
        "groupName": "Aurelien & Florian",
        "solverName": "Layer Approach with Plan merging",
        "instance": instance,
        "statistics": {
            "groundingTime": sum(benchmark["grounding"]),
            "solvingTime": sum(benchmark["solving_times1"]),
            "total": time,
            "atoms": count_atoms(model),
        },
        "model": model
    }

if __name__ =="__main__":
    max_total_time_second = 30
    for folder in [x[0] for x in os.walk("checkable_examples")]:
        print("folder: ",folder)
        folder_wo_slashes = folder.replace("\\", "")

        iteration = Iterations()
        if(folder == "checkable_examples"): continue

        # read instance
        with open(folder+"/originalPlan.lp", 'r') as file:
            iteration.original_plan = remove_comments_and_newlines(file.read())
        with open(folder+"/originalWarehouse.lp", 'r') as file:
            iteration.original_warehouse = remove_comments_and_newlines(file.read())
        timestart = time.time()
        queue = multiprocessing.Queue()
        proc = multiprocessing.Process(target = ProcessEnlosed().start_merging, args=(iteration, queue,))
        proc.start()
        queuedata = []
        while proc.is_alive() and (time.time()-timestart)<max_total_time_second:
            if( not queue.empty()):
                queuedata.append(queue.get())
            if(len(queuedata)>=2):
                if(not queuedata[0]):
                    break
                if(not queuedata[1]):
                    break
                if(len(queuedata)==4):
                    break
        if(time.time()-timestart > max_total_time_second):
            print("max time reached")
            proc.terminate()
            continue
        else:
            timetaken = time.time()-timestart
            hasmodel = queuedata[0]
            hasbenchmark =queuedata[1]
            if(not hasmodel):
                continue

            model = queuedata[2]
            if(hasbenchmark):
                benchmark = queuedata[3]
                try:
                    benchmark["grounding"] = benchmark["grounding"]
                except AttributeError as err:
                    hasbenchmark = False
            proc.terminate()

        resultfolder = "working_examples/"+folder.replace("checkable_examples\\","")
        Path(resultfolder).mkdir(parents=True, exist_ok=True)
        if(hasmodel != None):
            with open(resultfolder+"/model.lp", 'w') as file:
                file.write(model)
            if(hasbenchmark):
                with open(resultfolder+"/statistics.lp", 'w') as file:
                    file.write(json.dumps(benchmark_to_json(benchmark, model, folder.replace("checkable_examples\\",""), timetaken), indent=4))
        # check whether merging worked
