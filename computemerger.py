import graphmerger
# import alan.interface as alan
# import aron
import json

def sat(model):
    if model : return True 
    else : return False

def computemerger(instance, call):
    ctl,gt,model,additionnal_info = call(instance)


    ret = {
        "groupName" : 'Aurélien & Florian',
        "solverName" : "Target Assignment - Node Approach diamond + corridor",
        "objective" : "timespan",
        "instance" : instance,
        "ret" : sat(model),
        "statistics" : {
            "groudingTime" : gt,
            "solvingtime"  : ctl.statistics['summary']['times']['cpu'],
            "total" : gt + ctl.statistics['summary']['times']['cpu'],
            "atoms" : ctl.statistics['problem']['lp']['atoms'],
            "rules" : ctl.statistics['problem']['lp']['rules']
        },
        'model' : model,
        'additionnal' : additionnal_info
    }

    f = open(instance + ".json", "a")
    f.write(json.dumps(ret,indent=4))
    f.close()

import glob
import multiprocessing
import time 

gm = graphmerger.GraphMerger(merger='mergers/NodeApproach/DiamondCorridor.lp', reseting=False)




files = glob.glob('/home/owrel/Documents/MASTER_2/Project-KRR/common_instances/*.lp')
files.sort()
print(files)
# print()
notsat = 0
for instance in files:
    print(instance)
    
    # print(instance == bm)
    t = multiprocessing.Process(target=computemerger, args=(instance,gm,))
    t.start()
    time.sleep(360)
    if t.is_alive():
        t.terminate()
        print('Time out')
        notsat += 1


print(f"score : {notsat}/{len(files)}")