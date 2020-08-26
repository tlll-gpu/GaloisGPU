## DESCRIPTION

The LSG Delaunay Mesh Refinement uses a variant of Chew's algorithm as
implemented in the Lonestar CPU benchmark.

A great resource on Delaunary Mesh Refinement is the website
maintained by Shewchuk:

https://www.cs.cmu.edu/~quake/triangle.research.html

##TLLL
If you use TLLL in your work or research, please kindly let us know about it. We also encourage you to reference our paper:)

Here is the reference:

Lan Gao, Yunlong Xu, Rui Wang, Zhongzhi Luan, Zhibin Yu, Depei Qian. Thread-Level Locking for SIMT Architectures. IEEE Transactions on Parallel and Distributed System, 2020, 31(5): 1121-1136.


## BUILD

Run make in root directory or source files (e.g. apps/dmr)

## RUN

Execute as ./dmr path-to-input/ [maxfactor]

e.g. ./dmr r1M 20

## INPUT

Test inputs (files with extensions .ele, .node, .poly) can be downloaded from [https://www.cs.cmu.edu/~quake/triangle.html](this url)
