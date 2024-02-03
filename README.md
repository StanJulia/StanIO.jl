# StanIO.jl

| **Project Status**          |  **Build Status** |
|:---------------------------:|:-----------------:|
|![][project-status-img] | ![][CI] |

[issues-url]: https://github.com/stanjulia/StanIO.jl/issues
[project-status-img]: https://img.shields.io/badge/lifecycle-experimental-orange.svg
[CI]:https://github.com/StanJulia/StanIO.jl/actions/workflows/CI.yml/badge.svg

## Purpose

A number of extensions to the Stan Programming Language have been proposed (see [Bob Carpenter](https://statmodeling.stat.columbia.edu/wp-content/uploads/2021/10/carpenter-probprog2021.pdf)).

StanIO.jl will track the consequences of these changes in both input and output needed for Stan. As this package matures, it will replace sections of code in StanSample.jl and possibly other [StanJulia](https://github.com/StanJulia) packages (e.g. StanOptimize.jl).

This package is related to similar [work in python by Brian Ward](https://github.com/WardBrian/stanio). Handling of tuples is based on Brian's reshape.py.

Currently it converts Stan .csv files (including .csv files with complex variables, rectangular arrays, tuples and mixed tuples and arrays) to DataFrames and to NamedTuples (using `convert(NamedTuple, df)`).

## Usage

```julia
using StanIO

# Define an array of names of Stan .csv file

csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "mixed_02")))
csvfiles = joinpath.(joinpath(stanio_data, "mixed_02"), csvfiles)

a = extract_reshape(csvfiles, "m"); # Returns a nested 2D array [nsamples, nchains] of m
a[1, 1]

# or

b = extract_reshape(csvfiles, "m"; nested=false); # for a single array
b[1, 1, :, :]
```

In StanSample.jl the nested array functionality is available as:
```
ndf = read_samples(sm, :nesteddataframe)
```

## Examples

Please see this [stanio_example.jl Pluto notebook](https://github.com/StanJulia/StanExampleNotebooks.jl/blob/main/notebooks/StanIO/stanio_example.jl) or [these test script](https://github.com/StanJulia/StanIO.jl/blob/main/test) for examples.
