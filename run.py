# IMPORT SECTION
import clingo
import json
import os

#Reseting path
reseting = False

# Getting instances
instances = ['instance03']
merger = 'graphMerger.lp'
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
    else:

        f = open(pathfinding + pathfinder, "r")
        program += f.read()

        ctl = clingo.Control()
        ctl.add('base', [], program)
        ctl.ground([("base", [])])

        result = []
        ctl.solve(on_model=lambda m: result.append((("{}".format(m)))))

        pathfinding_time = str(ctl.statistics['summary']['times']['total'])

        if result:

            path = result[-1].replace(' ', '. ')
            path += '.'
            f = open(path_instances+instance+".path", "w")
            f.write(path)
            f.close()

            print('Done ')
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

    ctl.ground([("base", [])])

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
    print('Rules : ' + str(ctl.statistics['problem']['lp']['atoms']))
    print('Pathfinding : ' + pathfinding_time)

    # print(json.dumps(ctl.statistics, indent=4))
