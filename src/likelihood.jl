import RobustPmap

abstract type ExecutionKernel end

"""
Execution kernel that evaluates a function in parallel using `RobustPmap`.
"""
Base.@kwdef struct RobustPmapExecKernel <: ExecutionKernel
    type::Type
    checkoutputs::Bool
end

(exec::RobustPmapExecKernel)(f::Function, xs::AbstractArray) = RobustPmap.rpmap(f, xs; t=exec.type, checkoutputs=exec.checkoutputs)

"""
Simple execution kernel which evaluates all samples serially. Only intended for testing.
"""
struct SerialExecKernel <: ExecutionKernel end

(exec::SerialExecKernel)(f::Function, xs::AbstractArray) = map(f, xs)

"""
    LogLikelihoodFunction{funcType,execType<:ExecutionKernel}

Wraps a log-likelihood function and a given `ExecutionKernel` which determines how the likelihood
is evaluated over a batch of samples.
"""
struct LogLikelihoodFunction{funcType,execType<:ExecutionKernel}
    f::funcType
    exec::execType
end

(lik::LogLikelihoodFunction)(xs::AbstractArray) = lik.exec(lik.f, xs)
