__precompile__()

"""
MADS: Model Analysis & Decision Support (Mads.jl v1.0) (c) 2023
Module: AffineInvariantMCMC
"""
module AffineInvariantMCMC

import RobustPmap
import ProgressMeter
import Random

const emceedir = splitdir(splitdir(pathof(AffineInvariantMCMC))[1])[1]

"Test AffineInvariantMCMC"
function test()
	include(joinpath(emceedir, "test", "runtests.jl"))
end

"""
Bayesian sampling using Goodman & Weare's Affine Invariant Markov chain Monte Carlo (MCMC) Ensemble sampler (aka Emcee)

```
AffineInvariantMCMC.sample(llhood, numwalkers=10, numsamples_perwalker=100, thinning=1)
```

Arguments:

- `llhood` : function estimating loglikelihood (for example, generated using Mads.makearrayloglikelihood())
- `numwalkers` : number of walkers
- `x0` : normalized initial parameters (matrix of size (length(params), numwalkers))
- `thinning` : removal of any `thinning` realization
- `a` :

Returns:

- `mcmcchain` : final MCMC chain
- `llhoodvals` : log likelihoods of the final samples in the chain

Reference:

Goodman & Weare, "Ensemble samplers with affine invariance", Communications in Applied Mathematics and Computational Science, DOI: 10.2140/camcos.2010.5.65, 2010.
"""
function sample(llhood::Function, numwalkers::Integer, x0::AbstractMatrix{<:Real}, numsamples_perwalker::Integer, thinning::Integer, a::Number=2.; filename::AbstractString="", load::Bool=true, save::Bool=true, rng::Random.AbstractRNG=Random.GLOBAL_RNG)
	if filename != "" && isfile(filename) && load
		chain, llhoodvals = JLD2.load(filename, "chain", "llhoods")
	end
	x = copy(x0)
	chain = Array{Float64}(undef, size(x0, 1), numwalkers, div(numsamples_perwalker, thinning))
	lastllhoodvals = RobustPmap.rpmap(llhood, map(i->x[:, i], 1:size(x, 2)))
	llhoodvals = Array{Float64}(undef, numwalkers, div(numsamples_perwalker, thinning))
	llhoodvals[:, 1] = lastllhoodvals
	chain[:, :, 1] = x0
	batch1 = 1:div(numwalkers, 2)
	batch2 = div(numwalkers, 2) + 1:numwalkers
	divisions = [(batch1, batch2), (batch2, batch1)]
	@ProgressMeter.showprogress 5 for i = 1:numsamples_perwalker
		for ensembles in divisions
			active, inactive = ensembles
			zs = map(u->((a - 1) * u + 1)^2 / a, rand(rng, length(active)))
			proposals = map(i->zs[i] * x[:, active[i]] + (1 - zs[i]) * x[:, rand(rng, inactive)], 1:length(active))
			newllhoods = RobustPmap.rpmap(llhood, proposals)
			for (j, walkernum) in enumerate(active)
				z = zs[j]
				newllhood = newllhoods[j]
				proposal = proposals[j]
				logratio = (size(x, 1) - 1) * log(z) + newllhood - lastllhoodvals[walkernum]
				if log(rand(rng)) < logratio
					lastllhoodvals[walkernum] = newllhood
					x[:, walkernum] = proposal
				end
				if i % thinning == 0
					chain[:, walkernum, div(i, thinning)] = x[:, walkernum]
					llhoodvals[walkernum, div(i, thinning)] = lastllhoodvals[walkernum]
				end
			end
		end
	end
	if save && filename != ""
		JLD2.save(filename, "chain", chain, "llhoods", llhoodvals)
	end
	return chain, llhoodvals
end

"Flatten MCMC arrays"
function flattenmcmcarray(chain::AbstractArray, llhoodvals::AbstractArray)
	numdims, numwalkers, numsteps = size(chain)
	newchain = Array{Float64}(undef, numdims, numwalkers * numsteps)
	for j = 1:numsteps
		for i = 1:numwalkers
			newchain[:, i + (j - 1) * numwalkers] = chain[:, i, j]
		end
	end
	return newchain, llhoodvals[1:end]
end

end
