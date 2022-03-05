import clingo
import os
import time
import json

# TODO:
# compute difference metrics
# compute maxtime constant base


class GraphMerger:
    def __init__(self,
                 spf='pathfinding/path.lp',
                 mergers=[
                     'mergers/EdgeApproach/Diamond.lp',
                     'mergers/EdgeApproach/WaitOnly.lp',
                     'mergers/NodeApproach/Corridor.lp',
                     'mergers/NodeApproach/Diamond.lp',
                     'mergers/NodeApproach/DiamondCorridor.lp',
                     'mergers/NodeApproach/WaitOnly.lp'
                 ],
                 reseting=True
                 ):
        self.spf = spf
        self.mergers = mergers
        self.reseting = False

    def pos_metric(self, instancepath, result):
        ctl = clingo.Control()
        ctl.load(instancepath)
        ctl.add('base', [], result)
        ctl.load('metrics/diffpos.lp')
        ctl.ground([("base", [])])
        ret = []
        ctl.solve(on_model=lambda m: ret.append((("{}".format(m)))))
        ret = ret[0].split(' ')
        # print(ret)

        new_step = {}
        step = {}

        for s in ret:
            if 'new_step' in s:
                if int(s[s.index('(')+1:s.index(',')]) in new_step:
                    new_step[int(s[s.index('(')+1:s.index(',')])].append(
                        (int(s[s.index(',')+1:s.rindex(',')]), 
                        int(s[s.rindex(',')+1:s.rindex(')')])))
                else :
                    new_step[int(s[s.index('(')+1:s.index(',')])] = [
                            (int(s[s.index(',')+1:s.rindex(',')]), 
                            int(s[s.rindex(',')+1:s.rindex(')')]))
                        ]
            elif 'step' in s:
                if int(s[s.index('(')+1:s.index(',')]) in step:
                    step[int(s[s.index('(')+1:s.index(',')])].append(
                        (int(s[s.index(',')+1:s.rindex(',')]), 
                        int(s[s.rindex(',')+1:s.rindex(')')])))
                else :
                    step[int(s[s.index('(')+1:s.index(',')])] = [
                            (int(s[s.index(',')+1:s.rindex(',')]), 
                            int(s[s.rindex(',')+1:s.rindex(')')]))
                        ]
        # comparaison
        diff = 0
        for k in step :
            ns = set(new_step[k])
            s = set(step[k])

            udiff = (ns - s).union(s-ns)
            diff += len(udiff)

        return diff

    def time_metric(self, instancepath, result):
        ctl = clingo.Control()
        ctl.load(instancepath)
        ctl.load('metrics/difftime.lp')

        ctl.add('base', [], result)
        ctl.ground([("base", [])])
        ret = []
        ctl.solve(on_model=lambda m: ret.append((("{}".format(m)))))
        ret = ret[0].split(' ')
        oldgoalreached = {}
        goalreached = {}
        # print(ret)
        for s in ret :
            if 'old_goalReached' in s:
                oldgoalreached[int(s[s.index('(')+1:s.index(',')])] = int(s[s.index(',')+1:s.index(')')])
            elif 'goalReached' in s:
                goalreached[int(s[s.index('(')+1:s.index(',')])] = int(s[s.index(',')+1:s.index(')')])

        diff = 0
        for k in oldgoalreached:
            diff += goalreached[k] - oldgoalreached[k]


        return diff



    def get_merger_name(self, merger):
        # prefix
        if 'NodeApproach' in merger:
            prefix= 'NodeApproach'
        elif 'EdgeApproach' in merger:
            prefix= 'EdgeApproach'
        else:
            prefix= ''

        # suffix
        if '/' in merger and '.lp' in merger:
            suffix= merger[merger.rindex('/')+1:merger.rindex('.lp')]
        elif '.lp' in merger:
            suffix= merger[:merger.rindex('.lp')]

        if prefix:
            return f'{prefix}{suffix}'
        else:
            return f'{suffix}'

    def compute_initial_path(self, instance):
        ctl= clingo.Control()
        ctl.load(instance)
        ctl.ground([("base", [])])
        result= []
        ctl.solve(on_model=lambda m: result.append((("{}".format(m)))))
        result=result[0].split(' ')
        robot=[]
        for symbol in result:
            if 'init(object(robot,' in symbol:
                r=symbol[symbol.index(',')+1:symbol.index(')')]
                if not eval(r) in robot:
                    robot.append(eval(r))
        robot.sort()
        print(f'Number of single path to compute : {len(robot)}')
        ret=[]
        for r in robot:
            start=time.time()
            ctl=clingo.Control('')
            ctl.load(instance)
            ctl.load(self.spf)
            ctl.add('base', [], f'pathfor({r}).')
            ctl.ground([("base", [])])
            ctl.solve()
            result=[]
            ctl.solve(on_model=lambda m: result.append((("{}".format(m)))))
            if result:
                ret.append(result[-1].split(' '))


                print(f'Robot : {r} \t... Done in {time.time() - start}')
            else:
                print(f'Robot : {r} \t... Fail in {time.time() - start}')
                return []
        return ret

    def __call__(self, instance, output_directory='./benchmarks/'):
        global_ret={}
        print(f'Working on instance : {instance}')
        if '/' in instance:
            folder=instance[:instance.rindex('/')+1]
        else:
            folder='./'

        if os.path.isfile(instance+".path") and not self.reseting:
            print('Reading from old computed path.')
            f=open(instance+".path", "r")
            path=f.read()
            pathfinding_time="Imported"
        else:
            path=''
            ret=self.compute_initial_path(instance)
            if ret:
                for r in ret:
                    r.sort()
                    for s in r:
                        path += s + '.\n'
                    path += '\n'

                f=open(instance+".path", "w")
                f.write(path)
                f.close()
            else:
                print('PATHFINDING UNSATISFIABLE')

        print('Merging')
        for merger in self.mergers:

            # Building result object
            ret={
                'model': None,
                'sat': None,
                'merger': self.get_merger_name(merger),
                'problemtype': 'targetassignement',
                'instance': self.get_merger_name(instance) + '.lp'
            }

            print(f'Merger : {merger}')
            f=open(merger, "r")
            merger_program=f.read()

            ctl=clingo.Control(['-c maxtime=6'])
            ctl.load(merger)
            ctl.load(instance + '.path')

            start=time.time()
            ctl.ground([("base", [])])
            grounding_time=time.time()-start

            result=[]
            ctl.solve(on_model=lambda m: result.append((("{}".format(m)))))

            total_time=ctl.statistics['summary']['times']['total']
            nb_atoms=ctl.statistics['problem']['lp']['atoms']
            nb_rules=ctl.statistics['problem']['lp']['rules']


            ret['rules']=nb_rules
            ret['atoms']=nb_atoms
            ret['grounding_time']=grounding_time
            ret['cpu_time']=ctl.statistics['summary']['times']['cpu']
            ret['total_time']=total_time

            print('####### Result #######')
            print(f'\tSolved in {str(total_time)} sec.')
            print(f'\tAtoms : {str(nb_atoms)}')
            print(f'\tRules : {str(nb_rules)}')

            print(ret)
            if result:
                # print(result[-1])
                ret['model']=result[-1].replace(' ', '. ') + '.'
                out=result[-1].replace(' ', '. ')
                out += '.'
                f=open("instances/lastout.lp", "w")
                f.write(out)
                f.close()
                print('+ SATISFIABLE')
                ret['sat']=True
            else:
                print('- UNSATISFIABLE')
                ret['sat']=False
            print()


            # dumpings data
            f=open(
                f'{output_directory}{self.get_merger_name(instance)}{self.get_merger_name(merger)}.json', "w")
            f.write(json.dumps(ret, indent=2))
            f.close()
            if ret['sat']:
                print(f"Pos difference  : {self.pos_metric(instance+'.path', ret['model'])}")
                print(f"Time difference : {self.time_metric(instance+'.path', ret['model'])}")








gm=GraphMerger()
gm('instances/instance05.lp')

# graphmerger('instances/instance01.lp')
