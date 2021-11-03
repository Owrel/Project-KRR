### IMPORT SECTION
import clingo
import json


# Getting instances
instances = ['instance01']


# Setiing instances path
path_instances = 'instances/'
#setting plan generation
path_plan = 'plans/'


file_extensions = '.lp'

for instance in instances:
    print('Instance ' + instance )
    f = open(path_instances+instance+file_extensions, "r")
    program = f.read()

    f = open("solver.lp", "r")
    program += f.read()


    ctl = clingo.Control()
    ctl.add('base',[],program)
    ctl.ground([("base", [])])

    result = []
    ctl.solve(on_model=lambda m: result.append((("{}".format(m)))))


    print(result)
    print('####### Additional informations #######')
    print("Solved in " + str(ctl.statistics['summary']['times']['total']) + ' sec.')
    print('Atoms : ' + str(ctl.statistics['problem']['lp']['atoms']))
    print('Rules : ' + str(ctl.statistics['problem']['lp']['atoms']))

    # print(json.dumps(ctl.statistics, indent=4))