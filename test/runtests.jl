import AffineInvariantMCMC
import Test
import Random
import Statistics

if !isdefined(Base, Symbol("@stderrcapture"))
	macro stderrcapture(block)
		quote
			if ccall(:jl_generating_output, Cint, ()) == 0
				errororiginal = stderr;
				(errR, errW) = redirect_stderr();
				errorreader = @async read(errR, String);
				evalvalue = $(esc(block))
				redirect_stderr(errororiginal);
				close(errW);
				close(errR);
				return evalvalue
			end
		end
	end
end

Random.seed!(2017)

numdims = 5
numwalkers = 100
thinning = 10
numsamples_perwalker = 1000
burnin = 100

@stderrcapture function testemcee()
	stds = exp.(5 .* randn(numdims))
	means = 1 .+ 5 .* rand(numdims)
	llhood = x->begin
		retval = 0.
		for i in 1:length(x)
			retval -= .5 * ((x[i] - means[i]) / stds[i]) ^ 2
		end
		return retval
	end

	x0 = rand(numdims, numwalkers) .* 10 .- 5
	chain, llhoodvals = AffineInvariantMCMC.sample(llhood, numwalkers, x0, burnin, 1)
	chain, llhoodvals = AffineInvariantMCMC.sample(llhood, numwalkers, chain[:, :, end], numsamples_perwalker, thinning)
	flatchain, flatllhoodvals = AffineInvariantMCMC.flattenmcmcarray(chain, llhoodvals)
	return flatchain, means, stds
end

@Test.testset "Emcee" begin
	for _ in 1:10
		flatchain, means, stds = testemcee()
		for i = 1:numdims
			@Test.test isapprox(Statistics.mean(flatchain[i, :]), means[i], atol=(0.5 * stds[i]))
			@Test.test isapprox(Statistics.std(flatchain[i, :]), stds[i], atol=(5 * stds[i]))
		end
	end
end
:passed