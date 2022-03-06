import glob
import clingo

folder = 'instances/'

files = glob.glob(folder +'/*.lp.path')
for f in files :
    ctl = clingo.Control('')
    ctl.load(f)
    ctl.load('pathfinding/translation.lp')
    ctl.ground([("base", [])])
    result=[]
    ctl.solve(on_model=lambda m: result.append((("{}".format(m)))),on_finish=print)
    result = result[-1].replace(' ', '.\n') + '.'
    print(result)
    ctl = clingo.Control('')
    newf = open(( f)[:-5], "w")
    newf.write(result)







