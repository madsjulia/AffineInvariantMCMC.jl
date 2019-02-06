AffineInvariantMCMC
===================

AffineInvariantMCMC performs Bayesian sampling using Goodman & Weare's Affine Invariant Markov chain Monte Carlo (MCMC) Ensemble sampler.
AffineInvariantMCMC is a module of [MADS](http://madsjulia.github.io/Mads.jl).
Goodman & Weare's algorithm implementation in Python is called [Emcee](http://dan.iel.fm/emcee).

[![AffineInvariantMCMC](http://pkg.julialang.org/badges/AffineInvariantMCMC_0.5.svg)](http://pkg.julialang.org/?pkg=AffineInvariantMCMC&ver=0.5)
[![AffineInvariantMCMC](http://pkg.julialang.org/badges/AffineInvariantMCMC_0.6.svg)](http://pkg.julialang.org/?pkg=AffineInvariantMCMC&ver=0.6)
[![AffineInvariantMCMC](http://pkg.julialang.org/badges/AffineInvariantMCMC_0.7.svg)](http://pkg.julialang.org/?pkg=AffineInvariantMCMC&ver=0.7)
[![Build Status](https://travis-ci.org/madsjulia/AffineInvariantMCMC.jl.svg?branch=master)](https://travis-ci.org/madsjulia/AffineInvariantMCMC.jl)
[![Coverage Status](https://coveralls.io/repos/madsjulia/AffineInvariantMCMC.jl/badge.svg?branch=master)](https://coveralls.io/r/madsjulia/AffineInvariantMCMC.jl?branch=master)

Reference:

[Goodman, Jonathan, and Jonathan Weare. "Ensemble samplers with affine invariance." Communications in applied mathematics and computational science 5.1 (2010): 65-80.](http://msp.org/camcos/2010/5-1/p04.xhtml)

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