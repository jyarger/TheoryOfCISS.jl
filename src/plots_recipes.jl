using RecipesBase

@recipe function f(g::Function, cols::Vector{DataColumn}; xtransform=identity, ztransform=identity, contrast=8)
    xs, ys, zs = datamap(g, cols)
    xs, ys = xs[1, :], ys[:, 1]
    xlabel := get(cols[1].metadata, :xsymbol, nothing)
    ylabel := cols[1].ysymbol
    xs = xtransform.(xs)
    zs = ztransform.(zs)

    xlims --> (xs[1], xs[end])
    ylims --> (ys[1], ys[end])

    fzs = filter(!isnan, zs)
    maxz = maximum(abs.(fzs))
    stdz = std(fzs)
    clim = max(min(maxz, contrast*stdz), maxz / contrast)

    if all(x -> x >= 0, zs)
        clims --> (0.0, clim)
        color --> :ice_r
    else
        clims --> (-clim, clim)
        color --> :pu_or
    end

    # @series begin
    #     linewidth --> 1
    #     linecolor --> :black
    #     seriesalpha --> 0.3
    #     seriestype := :path
    #     primary := false
    #     markershape := :none

    #     (xs, mapreduce(col -> col.metadata.sim.eig.values, hcat, cols)')
    # end

    (xs, ys, zs)
end

@recipe function f(cols::Vector{DataColumn}; xtransform=identity, markerfunction=x->:black)
    xs, ys = ranges(cols)
    xlabel --> get(cols[1].metadata, :xsymbol, nothing)
    xs = xtransform.(xs)
    eigvalues, energy_range = energy_bands(cols)
    xlims --> (xs[1], xs[end])
    if length(ys) >= 2
        ylims --> (ys[1], ys[end])
    end
    yticks --> energy_range

    linewidth --> 1
    linecolor --> :black
    seriesalpha --> 0.3
    legend --> false
    # markercolor --> mapreduce(col -> map(markerfunction, col.data), hcat, cols)
    # seriestype := :path
    # markershape := :none

    @series begin
        μs = mapreduce(col -> col.metadata.sim.μ, vcat, cols)
        linewidth --> 1
        linecolor := :red
        linestyle --> :dash
        (xs, μs)
    end

    (xs, eigvalues)
end

@recipe function f(g::Function, slices::Vector{DataSlice}; xtransform=identity)
    xs, ys = datamap(g, slices)
    xs = xtransform.(xs)
    xlims --> (xs[1], xs[end])
    ylim = maximum(abs.(ys))
    if all(y -> y >= 0, ys)
        ylims --> (0.0, ylim)
    else
        ylims --> (-ylim, ylim)
    end

    #linewidth --> 1

    (xs, ys)
end

@recipe function f(col::DataColumn; xtransform=identity, markerfunction=x->:black)
    xs = col.metadata.sim.eig.values
    xticks --> range(floor(Int, minimum(xs)), ceil(Int, maximum(xs)), step=1)

    linewidth --> 1
    linecolor --> :black
    legend --> false

    @series begin
        μ = col.metadata.sim.μ
        linewidth --> 1
        linecolor := :red
        linestyle --> :dash
        [μ]
    end

    xs
end
