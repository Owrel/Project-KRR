# Final Plan Merging Package

This package is supposed to be used by other groups to easily use our plan merger on their benchmarks as well as using our benchmarks on their plan merger.

The package contains:
- `interface.py` provides the main merge method. (please mess with this:) )
- `benchmarks/` contains all of our groups benchmarks in single .lp files. (no need to mess with this)
- `planmerger/` contains every python script and ASP encoding needed for our plan merger. (DO NOT MESS WITH THIS)

The core merge method takes an absolute path to a benchmark file and an absolute path of a directory for storing the resulting json files in.
It returns the result of the benchmark in a json file with the benchmark name in the given directory.

Special libraries being used:
- clingo
- parse
- numpy
- matplotlib

Happy comparing:)
