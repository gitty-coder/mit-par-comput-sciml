import Base.Threads
using Distributions


"""
function estimatepi(n)

Runs a simple Monte Carlo method
to estimate pi with n samples.
"""
function estimate_pi(n)
	count = 0
	for i=1:n		
		x = rand(Uniform(-1.0, 1.0))
		y = rand(Uniform(-1.0, 1.0))
		count += (x^2 + y^2) <= 1
	end
	
	return 4*count/n
end


"""
Compute pi in parallel, over ncores cores, with a Monte Carlo simulation throwing N total darts
"""
function estimate_pi_tasks_vector(N::Int)
	ntasks = Base.Threads.nthreads()
	slices_of_pi = Vector{Float64}(undef, ntasks)
	n = N ÷ ntasks

	@sync for tid in 1:ntasks
		Threads.@spawn slices_of_pi[tid] = estimate_pi(n)
	end
    return sum(slices_of_pi) / ntasks
end



"""
Compute pi in parallel, over ncores cores, with a Monte Carlo simulation throwing N total darts with channels
"""
function estimate_pi_tasks_channel(N::Int)
	ntasks = Base.Threads.nthreads()
	ch = Channel{Float64}(ntasks)
	n = N ÷ ntasks

	@sync for _ in 1:ntasks
		Threads.@spawn put!(ch, estimate_pi(n))
	end
	sum_of_pis = sum(take!(ch) for _ in 1:ntasks)
    return sum_of_pis / ntasks
	#slices_of_pi = collect(take!(ch) for _ in 1:ntasks)
	#return slices_of_pi
end




N = 2000
#estimate_pi_tasks(N)

 #serial = @elapsed estimate_pi(N)
pchannel = @elapsed estimate_pi_tasks_channel(N)
pvector = @elapsed estimate_pi_tasks_vector(N)

pchannel,pvector
pvector/serial, pchannel/serial
