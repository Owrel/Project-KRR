# IMPORT SECTION
import clingo
import json
import os
import sys
import time





def compute_initial_path(instance, pathfinder):
    #get atoms
    ctl = clingo.Control()
    ctl.load(instance)
    ctl.ground([("base", [])])
    result = []
    ctl.solve(on_model=lambda m: result.append((("{}".format(m)))))
    result = result[0].split(' ')

    robot = []
    for symbol in result:
        if 'init(object(robot,' in symbol:
            r = symbol[symbol.index(',')+1:symbol.index(')')]
            if not eval(r) in robot:
                robot.append(eval(r))

    
    robot.sort()
    print(f'Number of single path to compute : {len(robot)}')
    ret = []
    for r in robot:
        start = time.time()
        ctl = clingo.Control('')
        ctl.load(instance)
        ctl.load(pathfinder)
        ctl.add('base', [], f'pathfor({r}).')
        ctl.ground([("base", [])])
        ctl.solve()
        result = []
        ctl.solve(on_model=lambda m: result.append((("{}".format(m)))))
        if result:
            ret.append(result[-1].split(' '))
            print(f'Robot : {r} ... Done in {time.time() - start}')
        else :
            print(f'Robot : {r} ... Fail in {time.time() - start}')
            return []

    return ret



#Reseting path
reseting = False

# Getting instances
instances = ['instance08']
merger = 'NodeApproach/TargetAssignmentDiamond.lp'
pathfinder = 'path.lp'


# Setiing instances path
path_instances = 'instances/'
# setting plan generation6
path_plan = 'plans/'

pathfinding = "pathfinding/"
path_mergers = 'mergers/'
file_extensions = '.lp'


# for instance in instances:
    
    # print('Pathfinding : ' + pathfinding_time)

    # print(json.dumps(ctl.statistics, indent=4))




        





