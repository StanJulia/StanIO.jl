# see documentation at https://juliadocs.github.io/Documenter.jl/stable/

using Documenter, StanIO

makedocs(
    modules = [StanIO],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Rob J Goedman",
    sitename = "StanIO.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

# Some setup is needed for documentation deployment, see “Hosting Documentation” and
# deploydocs() in the Documenter manual for more information.
deploydocs(
    repo = "github.com/goedman/StanIO.jl.git",
    push_preview = true
)
