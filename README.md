# StanIO.jl

| **Project Status**          |  **Build Status** |
|:---------------------------:|:-----------------:|
|![][project-status-img] | ![][CI] |

[issues-url]: https://github.com/stanjulia/StanIO.jl/issues
[project-status-img]: https://img.shields.io/badge/lifecycle-experimental-orange.svg
[CI]: https://github.com/StanJulia/StanIO.jl/actions/workflows/CI.yml

## Purpose

A number of extensions to the Stan Programming Language have been proposed (see [Bob Carpenter](https://statmodeling.stat.columbia.edu/wp-content/uploads/2021/10/carpenter-probprog2021.pdf)).

StanIO.jl will track the consequences of these changes in both input and output needed for Stan. As this package matures, it will replace sections of code in StanSample.jl and possibly other [StanJulia](https://github.com/StanJulia) packages (e.g. StanOptimize.jl). This package is related to similar [work in python by Brian Ward](https://github.com/WardBrian/stanio).

Currently it converts Stan .csv files (including .csv files with complex variables and rectangular arrays) to DataFrames and NamedTuples.

Under consideration is to also support `tuples` in the .csv files.

