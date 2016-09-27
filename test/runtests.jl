using Base.Test
import Emcee

srand(0)

numdims = 5
numwalkers = 100
thinning = 10
numsamples_perwalker = 1000
burnin = 100

function testit()
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
	chain, llhoodvals = Emcee.sample(llhood, numwalkers, x0, burnin, 1)
	chain, llhoodvals = Emcee.sample(llhood, numwalkers, chain[:, :, end], numsamples_perwalker, thinning)
	flatchain, flatllhoodvals = Emcee.flatten(chain, llhoodvals)
	for i = 1:numdims
		@test_approx_eq_eps mean(flatchain[i, :]) means[i] 0.1 * stds[i]
		@test_approx_eq_eps std(flatchain[i, :]) stds[i] 0.1 * stds[i]
	end
end

for _ in 1:10
	testit()
end
:passed
