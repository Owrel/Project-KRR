# Final planmerger

This contains everything needed to easily run our planmerger on any instance and save the results.

The package contains:
- `interface.py` provides the main merge method. Only need to use this
- `benchmarks/` contains our groups main benchmarks. .lp files contain the instance, .lp.plan files contain the plans.
- `encodings/` contains the ASP encodings for our planmerger and some python scripts.

The merge method takes the path to the instance (.lp) file (a .lp.plan file with the same name has to exist containing the plan) and a path to a directory for storing the resulting json file in.
It returns the result of the benchmark in a json file with the benchmark name in the given directory.

Special libraries being used:
- clingo
