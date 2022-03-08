import glob
import matplotlib.pyplot as plt
import json
import math



files = glob.glob("benchmarks_node_*/*.json")
files += glob.glob("benchmarks_edge_*/*.json")
print(f'Comparaison to compute : {len(files)}')

data = {}
for file in files:
    approach_name = file[file.index('_')+1:file.index('/')]
    f = open(file, "r")
    j = json.load(f)
    j['solverName'] = approach_name
    if approach_name in data :
        data[approach_name].append(j)
    else :
        data[approach_name]= [j]

list_instances = []
instances_name_per_solver = {}
for k in data.keys():
    instances_name = []
    for s in data[k]:
        instances_name.append(s['instance'])
        if not s['instance'] in list_instances:
            list_instances.append(s['instance'])
    instances_name_per_solver[k] = instances_name

global_common_insances = []
for instance in list_instances:
    inall = True 
    for k in instances_name_per_solver:
        if not instance in instances_name_per_solver[k]:
            inall = False

    if inall:
        global_common_insances.append(instance)

print('Global common instances')
print(global_common_insances)


nowait_common_insances = []
for instance in list_instances:
    inall = True 
    for k in instances_name_per_solver:
        if not 'wait' in k :
            if not instance in instances_name_per_solver[k]:
                inall = False

    if inall:
        nowait_common_insances.append(instance)

print('nowait common instances')
print(len(nowait_common_insances))



list_instances.sort()
## N instance solved
# solver = []
# n_solved = []
# for k in data.keys():
#     solver.append(k)
#     n_solved.append(len(data[k]))

# plt.bar(solver,n_solved,width=0.25,)
# plt.ylabel('Number of instances solved')
# plt.xlabel('Solvers')
# plt.title('Number of solved instance by solver (/37)')
# plt.show()



# time per robot 
# solver = []
# time_per_robot = []
# for k in data :
#     tpr = []
#     solver.append(k)
#     for stats in data[k]:
#         if stats['instance'] in global_common_insances:
#             n_robot = 0
#             for symbol in stats['model'].split(' '):
#                 if 'goalReached' in symbol:
#                     n_robot +=1
            
#             tpr.append(stats['statistics']['total']/n_robot)
#     print(len(tpr))
#     time_per_robot.append(sum(tpr)/len(tpr))
    

# plt.bar(solver,time_per_robot,width=0.25,)
# plt.ylabel('Time avarage time / robot')
# plt.xlabel('Solvers')
# plt.title('Average time/robot of solving on common instances')
# plt.show()



## time per robot withou wait
solver = []
time_per_robot = []
for k in data :
    if not 'wait' in k:
        tpr = []
        solver.append(k)
        for stats in data[k]:
            if stats['instance'] in nowait_common_insances and not stats['instance'] in global_common_insances :
                n_robot = 0
                for symbol in stats['model'].split(' '):
                    if 'goalReached' in symbol:
                        n_robot +=1

                tpr.append(stats['statistics']['total']/n_robot)
        print(len(tpr))
        time_per_robot.append(sum(tpr)/len(tpr))
    

plt.bar(solver,time_per_robot,width=0.25,)
plt.ylabel('Time avarage time / robot')
plt.xlabel('Solvers')
plt.title('Average time/robot of solving on instances not solvable with wait only')
plt.show()


## Generating latex 
# latex_table = "" 
# for k in data:
#     latex_table += '\\begin{center}\n'
#     latex_table += '\\begin{table}\n'


#     latex_table += '\\caption{Performance/metrics table on all instance. Merger '+ k + '}\n' 
#     latex_table += '\\begin{tabular}{ | m{5cm} | m{2cm}| m{2cm} |m{2cm} | } \n'
#     latex_table += '\hline \n'
#     latex_table += f'Merger : {k} & Total time & Pos. metric & Time Metric \\\ \n \hline \n'
#     for instance in list_instances:
#         ret = f"{instance}&"
#         found = False
#         for stats in data[k]:
#             if stats['instance'] == instance:
#                 found = True
#                 ret += f'{str(stats["statistics"]["total"])[0:5]}sec.  & {stats["additionnal"][0]} & {stats["additionnal"][1]} '


#         if found:
#             ret += '\\\ \n \hline\n'
#         else:
#             ret += 'X & X & X \\\ \n \hline \n'

#         latex_table += ret
#     latex_table += '\\end{tabular}\n'
#     latex_table += '\\end{table}\n'

#     latex_table += '\\end{center}\n'
#     latex_table += '\n\n\n\n\n\n'


# latex_table =latex_table.replace('_',' ')
# print(latex_table)






