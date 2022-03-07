import clingo
import os
import time
import json


import parser

# TODO:
# compute difference metrics
# compute maxtime constant base





def computemerger(instance, call):
    ctl,s  = call(instance)




class GraphMerger:
    def __init__(self,
                 spf='pathfinding/path.lp',
                 merger= 'mergers/NodeApproach/DiamondCorridor.lp',
                 reseting=True
                 ):
        self.spf = spf
        self.merger = merger
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
        print(f'Merger : {self.merger}')
        merger = self.merger
        maxstep = 0
        for l in path.split('\n'):
            if 'old_goalReached' in l :
                if int(l[l.index(',')+1:l.index(')')]) > maxstep:
                    maxstep = int(l[l.index(',')+1:l.index(')')])

        for i in range(maxstep,maxstep+50) :
            maxtime = f'-c maxtime={i}'
            print('MAXSTEP = ' + maxtime)

            ctl=clingo.Control([maxtime])
            ctl.load(merger)
            ctl.load(instance + '.path')

            start=time.time()
            ctl.ground([("base", [])])
            grounding_time=time.time()-start

            result=[]
            ctl.solve(on_model=lambda m: result.append((("{}".format(m)))),on_finish=print)
            # print(ctl.)

            if result:
                result = result[-1].replace(' ', '. ') + '.'
                metrics = [self.pos_metric(instance+'.path', result),self.time_metric(instance+'.path', result)]
                return ctl,grounding_time,result,metrics

        print('No solution')

            