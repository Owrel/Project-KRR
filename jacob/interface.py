from merger import Merger

# use this function to run plan merging on a benchmark file and return a json file into a directory
# [benchmark] should be a path to the instance file (example: "benchmarks/03_4r_node.lp")
# the plan should be saved in a different file with the same name + ".plan" suffix
# [save_dir] should be the folder where the json file is saved (example: save_dir = "testresults" -> file is saved as "testresults/benchmark.json")

def merge(benchmark, save_dir):
    merger = Merger(benchmark)
    merger.merge(save=True, save_dir=save_dir)



import threading
import glob


if __name__ == '__main__':
	bm = '/home/owrel/Documents/MASTER_2/Project-KRR/aron/benchmarks/01_no_conflict.lp'
	save_dir = '/home/owrel/Documents/MASTER_2/Project-KRR/benchmarks_jacob/'
	# merge(bm, save_dir)
        
	
	import glob
	import multiprocessing
	import time 

	files = glob.glob('/home/owrel/Documents/MASTER_2/Project-KRR/instances_jacob/*.lp')
	files.sort()
	print(files)
	# print()
	notsat = 0
	for instance in files:
        # print(instance == bm)
		t = multiprocessing.Process(target=merge, args=(instance,save_dir,))
		t.start()
		for i in range(0,12):
			if t.is_alive():
				time.sleep(5)
		if t.is_alive():
			t.terminate()
			print('Time out')
			notsat += 1
