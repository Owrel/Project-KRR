from merger import Iterations
import json
from pathlib import Path
import os
import multiprocessing
import time
class ProcessEnlosed:
    def start_merging(self, iteration, queue):
        iteration.start_merging()
        queue.put(len(iteration.models) > 0)
        queue.put(hasattr(iteration, "benchmark_info"))
        if(len(iteration.models) > 0):
            queue.put(iteration.models[0])
        if(hasattr(iteration, "benchmark_info")):
            queue.put(iteration.benchmark_info)


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
if __name__ =="__main__":
    max_total_time_second = 600
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
        while proc.is_alive() and (time.time()-timestart)<max_total_time_second:
            #print("time passed: "+str(time.time()-timestart)+" time left: "+str(max_total_time_second-(time.time()-timestart)))
            pass
        #print("left while loop")
        if(time.time()-timestart > max_total_time_second):
            print("max time reached")
            proc.terminate()
            continue
        else:
            hasmodel = queue.get()
            hasbenchmark = queue.get()
            if(not hasmodel):
                continue

            model = queue.get()
            if(hasbenchmark):
                benchmark = queue.get()
            proc.join()

        resultfolder = "working_examples/"+folder
        Path(resultfolder).mkdir(parents=True, exist_ok=True)
        if(hasmodel != None):
            with open(resultfolder+"/model.lp", 'w') as file:
                file.write(model)
            if(hasbenchmark != None):
                with open(resultfolder+"/statistics.lp", 'w') as file:
                    file.write(json.dumps(benchmark))
        # check whether merging worked
