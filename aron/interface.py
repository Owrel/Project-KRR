from planmerger.merger import Merger
import os

# use this function to run plan merging on a benchmark file and return a json file into a directory
# benchmark.lp --> save_path/benchmark.json
def merge(benchmark, save_dir):
        # initialize merger
        script_dir = os.path.dirname(os.path.realpath(__file__))
        merger = Merger(os.path.join(script_dir, 'planmerger', 'encodings'))
        merger.merge(benchmark, save_dir=save_dir)




import threading
import glob




if __name__ == '__main__':
	bm = '/home/owrel/Documents/MASTER_2/Project-KRR/aron/benchmarks/01_no_conflict.lp'
	save_dir = '/home/owrel/Documents/MASTER_2/Project-KRR/benchmarks/'
	# merge(bm, save_dir)
        
	
	import glob
	import multiprocessing
	import time 

	files = glob.glob('/home/owrel/Documents/MASTER_2/Project-KRR/aron/benchmarks/*.lp')
	files.sort()
	print(files)
	# print()
	notsat = 0
	for instance in files:
		print(instance)
		
		# print(instance == bm)
		t = multiprocessing.Process(target=merge, args=(instance,save_dir,))
		t.start()
		time.sleep(180)
		if t.is_alive():
			t.terminate()
			print('Time out')
			notsat += 1

		


		# t.join(timeout=60)
		
		# try:
		# 	merge(instance, save_dir)
		# except:
		# 	print(f"{instance} not satifiabale")
		# 	notsat += 1
		# print('---------------------------------')

	print(f"score : {notsat}/{len(files)}")

