AffineInvariantMCMC
===================

[![AffineInvariantMCMC](http://pkg.julialang.org/badges/AffineInvariantMCMC_0.5.svg)](http://pkg.julialang.org/?pkg=AffineInvariantMCMC&ver=0.5)
[![Build Status](https://travis-ci.org/madsjulia/AffineInvariantMCMC.jl.svg?branch=master)](https://travis-ci.org/madsjulia/AffineInvariantMCMC.jl)
[![Coverage Status](https://coveralls.io/repos/madsjulia/AffineInvariantMCMC.jl/badge.svg?branch=master)](https://coveralls.io/r/madsjulia/AffineInvariantMCMC.jl?branch=master)

AffineInvariantMCMC performs Bayesian sampling using Goodman & Weare's Affine Invariant Markov chain Monte Carlo (MCMC) Ensemble sampler.
AffineInvariantMCMC is a module of [MADS](http://madsjulia.github.io/Mads.jl).
Goodman & Weare's algorithm implementation in Python is called [Emcee](http://dan.iel.fm/emcee).

Reference:

[Goodman, Jonathan, and Jonathan Weare. "Ensemble samplers with affine invariance." Communications in applied mathematics and computational science 5.1 (2010): 65-80.](http://msp.org/camcos/2010/5-1/p04.xhtml)

Example
-------

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

MADS
====

[MADS](http://madsjulia.github.io/Mads.jl) (Model Analysis & Decision Support) is an integrated open-source high-performance computational (HPC) framework in [Julia](http://julialang.org).
MADS can execute a wide range of data- and model-based analyses:

* Sensitivity Analysis
* Parameter Estimation
* Model Inversion and Calibration
* Uncertainty Quantification
* Model Selection and Model Averaging
* Model Reduction and Surrogate Modeling
* Machine Learning and Blind Source Separation
* Decision Analysis and Support

MADS has been tested to perform HPC simulations on a wide-range multi-processor clusters and parallel environments (Moab, Slurm, etc.).
MADS utilizes adaptive rules and techniques which allows the analyses to be performed with a minimum user input.
The code provides a series of alternative algorithms to execute each type of data- and model-based analyses.

Documentation
=============

All the available MADS modules and functions are described at [madsjulia.github.io](http://madsjulia.github.io/Mads.jl)

Installation
============

```julia
Pkg.add("AffineInvariantMCMC")
```

Installation behind a firewall
------------------------------

Julia uses git for the package management.
To install Julia packages behind a firewall, add the following lines in the `.gitconfig` file in your home directory:

```git
[url "https://"]
        insteadOf = git://
```

or execute:

```bash
git config --global url."https://".insteadOf git://
```

Set proxies:

```bash
export ftp_proxy=http://proxyout.<your_site>:8080
export rsync_proxy=http://proxyout.<your_site>:8080
export http_proxy=http://proxyout.<your_site>:8080
export https_proxy=http://proxyout.<your_site>:8080
export no_proxy=.<your_site>
```

For example, if you are doing this at LANL, you will need to execute the
following lines in your bash command-line environment:

```bash
export ftp_proxy=http://proxyout.lanl.gov:8080
export rsync_proxy=http://proxyout.lanl.gov:8080
export http_proxy=http://proxyout.lanl.gov:8080
export https_proxy=http://proxyout.lanl.gov:8080
export no_proxy=.lanl.gov
```

MADS examples
=============

In Julia REPL, do the following commands:

```julia
import Mads
```

To explore getting-started instructions, execute:

```julia
Mads.help()
```

There are various examples located in the `examples` directory of the `Mads` repository.

For example, execute

```julia
include(Mads.madsdir * "/../examples/contamination/contamination.jl")
```

to perform various example analyses related to groundwater contaminant transport, or execute

```julia
include(Mads.madsdir * "/../examples/bigdt/bigdt.jl")
```

to perform Bayesian Information Gap Decision Theory (BIG-DT) analysis.