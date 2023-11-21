# Entanglement buffering with 1G1B (one good memory, one bad memory)

This repository contains all the code used in the project 1G1B (see the arxiv version of our manuscript [here](https://arxiv.org/abs/2311.10052)).

Here, we have three blocks of code:

 1. Simulation of the 1G1B system.
	1.1. When the probability of successful purification ($p$) is constant, we simulate the Markov Chain corresponding to the 1G1B system. Our functions can calculate many samples of the evolution of the state of the system over time. After collecting the samples, we can calculate the fidelity, average fidelity, and standard error, and we can plot all those quantities.
	1.2. We also simulate the system when the success probability ($p$) is fidelity-dependent (i.e., time-dependent). In this case, each sample directly computes the fidelity over time, since this cannot be done anymore in post-processing.

 2. Analysis of bilocal Clifford protocols. We analyze the jump functions of all bilocal Clifford protocols using the code from Jansen et al. [1]. We label the pieces of code that are from [1].

 3. We provide the code used to obtain the results (plots and claims) from our manuscript.

[1] Sarah Jansen, Kenneth Goodenough, Sébastian de Bone, Dion Gijswijt, and David Elkouss. Enumerating all bilocal Clifford distillation protocols through symmetry reduction. Quantum 6 (2022), 715.

---
---

# Files

Note that some Matlab scripts may require having the auxiliary folders `_*/` in the Matlab path.

---

### Simulation

#### With constant $p$

 - `TUTORIAL_simulation_constant_p.m`: example of how to run a simulation and how to visualize the results.

 - `TUTORIAL_get_avgfid_constant_p.m`: example of how to run a simulation and how to read the average fidelity files.

Calculations:

Plots:
 - `plotCTMC_1G1B.m` (function): plots the evolution of the states versus time.
 - `plotfidCTMC_1G1B.m` (function): plots the evolution of the fidelity versus time.

#### With fidelity-dependent $p$

*** Under construction ***

---

### Results

 - `MANUSCRIPT_FvsA_linearbounds.m`: plots average consumed fidelity vs availability, considering the upper and lower bounds to the jump function and the success probability derived in our paper (Figure 7).

 - `MANUSCRIPT_linear_jump.m`: plots availability and average consumed fidelity vs probability of attempting purification ($q$) to show the tradeoff in both quantities. We assume a linear jump function. The file generates Figure 6 of our paper.

 - `VALIDATION_linear_jump.m`: comparison of analytical average consumed fidelity with simulation results, for different sets of parameters, assuming a linear jump.

---

### Bilocal Clifford protocols

The following files were used to study the jump function and success probability of all 2-to-1 bilocal Clifford protocols. They require running `Jansen2022_get_all_circuits_1G1B.ipynb` first.
 - `_bilocal_cliffords/ANALYSIS_protocols_FandP.m`: plots output fidelity vs success probability of every 2-to-1 bilocal Clifford protocol, for given input states.
 - `_bilocal_cliffords/ANALYSIS_protocols_linearbounds.m`: plots maximum/minimum output fidelity vs input fidelity achieved by any bilocal Clifford protocol (inputs: a Werner state and a Bell diagonal state). We also plot the linear bounds discussed in the paper.

---

### Auxiliary files

All auxiliary files are in directories that start with `_*`.

`_aux_functions/*`:
 - `DEJMPS.m`: returns the output fidelity and success probability of the DEJMPS protocol for two given input Bell-diagonal states.
 - `cividis.m`: colormap used in some of our plots.

`_simulation_constant_p/*`:
 - `simCTMC_1G1B.m`: simulates the system and saves the data in a file.
 - `fidCTMC_1G1B.m`: calculates fidelity over time for each sample and saves the data in a file. Requires running `simCTMC_1G1B.m` first.
 - `avgfidCTMC_1G1B.m`: calculates average fidelity over time for each sample and saves the data in a file. Requires running `fidCTMC_1G1B.m` first.
 - `depolarize.m`: returns the fidelity of a Werner state after being stored in memory subject to depolarizing noise.

`_theory_constant_p/*`:
 - `THEORYavailab_1G1B.m`: returns the (analytical) availability for a given set of parameters. We assume constant $p$.
 - `THEORYavgfid_1G1B.m`: returns the (analytical) average consumed fidelity for a given set of parameters. We assume constant $p$.

`_bilocal_cliffords/*`:
 - `Jansen2022_Transversal.ipynb`: generates an auxiliary data file needed to run `get_all_circuits_1G1B.ipynb`. This notebook requires a SageMath 9.0 (or 10.0) kernel. Code adapted from [1] (for the original version see https://doi.org/10.4121/15082515.v1).
 - `Jansen2022_get_all_circuits_1G1B.ipynb`: (it requires running `Jansen2022_Transversal.ipynb` first) finds all combinations of output fidelity and success probability achievable by bilocal Clifford protocols, and saves the results in a matlab-readable (.mat) file. This notebook requires a SageMath 9.0 (or 10.0) kernel. Code adapted from [1] (for the original version see https://doi.org/10.4121/15082515.v1).
 - `simplify_jump_function.m`: simplifies the analytical jump function of every 2-to-1 bilocal Clifford protocol provided by the code from [1].
 - `simplify_success_prob.m`: simplifies the analytical jump function of every 2-to-1 bilocal Clifford protocol provided by the code from [1].

---

### Auxiliary files (`aux_functions/*`)

Analytical functions:


---
---



























