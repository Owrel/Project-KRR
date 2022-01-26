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
merger = 'EdgeApproach/TargetAssignmentDiamond.lp'
pathfinder = 'path.lp'


# Setiing instances path
path_instances = 'instances/'
# setting plan generation6
path_plan = 'plans/'

pathfinding = "pathfinding/"
path_mergers = 'mergers/'
file_extensions = '.lp'


for instance in instances:
    print('Instance ' + instance)
    f = open(path_instances+instance+file_extensions, "r")
    program = f.read()

    print('Computing simple path finding...')

    if os.path.isfile(path_instances+instance+".path") and not reseting:
        print('Reading from old computed path.')
        f = open(path_instances+instance+".path", "r")
        path = f.read()
        pathfinding_time = "Imported"
        # path = ''
    else:
        path = ''
        ret = compute_initial_path(path_instances+instance+file_extensions, pathfinding+pathfinder)
        if ret :
            for r in ret:
                r.sort()
                for s in r:

                    path += s +'.\n'
                path += '\n' 
        
            f = open(path_instances+instance+".path", "w")
            f.write(path)
            f.close()
        else:
            print('PATHFINDING UNSATISFIABLE')
            break

    print('Merging...')

    f = open(path_instances+instance+file_extensions, "r")
    instance_program = f.read()

    f = open(path_mergers+merger, "r")
    merger_program = f.read()

    ctl = clingo.Control()
    ctl.add('base', [], instance_program)
    ctl.add('base', [], merger_program)
    ctl.add('base', [], path)
    start = time.time()
    ctl.ground([("base", [])])
    print(f'Grounding done in {time.time()-start}')

    result = []
    ctl.solve(on_model=lambda m: result.append((("{}".format(m)))))

    if result:
        print(result[-1])
        out = result[-1].replace(' ', '. ')
        out += '.'
        f = open("instances/lastout.lp", "w")
        f.write(out)
        f.close()
    else:
        print('UNSATISFIABLE')
    # print(json.dumps(ctl.statistics,indent=4))
    print('####### Additional informations #######')
    print("Solved in " +
          str(ctl.statistics['summary']['times']['total']) + ' sec.')
    print('Atoms : ' + str(ctl.statistics['problem']['lp']['atoms']))
    print('Rules : ' + str(ctl.statistics['problem']['lp']['rules']))
    # print('Pathfinding : ' + pathfinding_time)

    # print(json.dumps(ctl.statistics, indent=4))




        





