AffineInvariantMCMC
===================

AffineInvariantMCMC performs Bayesian sampling using Goodman & Weare's Affine Invariant Markov Chain Monte Carlo (MCMC) Ensemble sampler.
AffineInvariantMCMC is a module of [MADS](http://madsjulia.github.io/Mads.jl).
Goodman & Weare's algorithm implementation in Python is called [Emcee](http://dan.iel.fm/emcee).

[![Build Status](https://travis-ci.org/madsjulia/AffineInvariantMCMC.jl.svg?branch=master)](https://travis-ci.org/madsjulia/AffineInvariantMCMC.jl)
[![Coverage Status](https://coveralls.io/repos/madsjulia/AffineInvariantMCMC.jl/badge.svg?branch=master)](https://coveralls.io/r/madsjulia/AffineInvariantMCMC.jl?branch=master)

Reference:

Goodman, Jonathan, and Jonathan Weare. "Ensemble samplers with affine invariance." Communications in applied mathematics and computational science 5.1 (2010): 65-80. [Link](http://msp.org/camcos/2010/5-1/p04.xhtml)

Installation
-----------

```julia
import Pkg; Pkg.add("AffineInvariantMCMC")
```

Example
--------

```julia
import AffineInvariantMCMC

numdims = 5
numwalkers = 100
thinning = 10
numsamples_perwalker = 1000
burnin = 100

const stds = exp(5 * randn(numdims))
const means = 1 + 5 * rand(numdims)
llhood = x->begin
	retval = 0.
	for i in 1:length(x)
		retval -= .5 * ((x[i] - means[i]) / stds[i]) ^ 2
	end
	return retval
end
x0 = rand(numdims, numwalkers) * 10 - 5
chain, llhoodvals = AffineInvariantMCMC.sample(llhood, numwalkers, x0, burnin, 1)
chain, llhoodvals = AffineInvariantMCMC.sample(llhood, numwalkers, chain[:, :, end], numsamples_perwalker, thinning)
flatchain, flatllhoodvals = AffineInvariantMCMC.flattenmcmcarray(chain, llhoodvals)
```

Comparison
----------

The figures below compare predicted marginal and joint posterior PDF's (probability density functions) using Classical vs. Affine Invariant MCMC for the same number of functional evaluations (in this case 1,000,000).

The synthetic problem tested below is designed to have a very complex structure.
The Classical MCMC clearly fails to characterize sufficiently well the  posterior PDF's.

- Classical MCMC ![ClassicalMCMC](/examples/ClassicalMCMC_w1000000.png)
- Affine Invariant MCMC ![AffineInvariantMCMC](/examples/AffineInvariantMCMC_w1000000.png)

Parallelization
---------------

AffineInvariantMCMC can be executed efficiently in parallel using existing distributed network capabilities.

For more information, check out our Julia module [RobustPmap](https://github.com/madsjulia/RobustPmap.jl).

Restarts
--------

AffineInvariantMCMC analyses can be performed utilizing extremely efficient restarts.

Typically, the AffineInvariantMCMC runs require large number of functional (model) evaluations which may take substantial computational time.
Occasionally, the AffineInvariantMCMC runs may crash due to external issues (e.g., network/computer/disk failures).
Furthermore, AffineInvariantMCMC runs may require more time than the allowed allocation time on existing HPC cluster queues.
In all these cases, the AffineInvariantMCMC runs needs to be restarted.
Our codes allow are very efficient restarts with very minimal overhead and without re-execution of completed functional (model) evaluations.

For more information, check out our Julia module [ReusableFunctions](https://github.com/madsjulia/ReusableFunctions.jl).

Documentation
-------------

All the available MADS modules and functions are described at [madsjulia.github.io](http://madsjulia.github.io/Mads.jl)

AffineInvariantMCMC functions are documented at [https://madsjulia.github.io/Mads.jl/Modules/AffineInvariantMCMC](https://madsjulia.github.io/Mads.jl/Modules/AffineInvariantMCMC)

Projects using AffineInvariantMCMC
-----------------

* [MADS](https://github.com/madsjulia)
* [TensorDecompositions](https://github.com/TensorDecompositions)

Publications, Presentations, Projects
--------------------------

* [mads.gitlab.io](http://mads.gitlab.io)
* [TensorDecompositions](https://tensordecompositions.github.io)
* [monty.gitlab.io](http://monty.gitlab.io)
* [ees.lanl.gov/monty](https://www.lanl.gov/orgs/ees/staff/monty)