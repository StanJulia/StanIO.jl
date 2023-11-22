using StanSample

stan = "
generated quantities {
  real base = normal_rng(0, 1);
  array[2, 1, 3] real A = {{{base, base * 1, base * 2}},
                           {{base * 3, base * 4, base * 5}}};

  array[1,1,1] real dummy = {{{base*10}}};

  array[1] tuple(real, array[1] real) dummy_tuple = {(base*11, {base*12})};
}
";

tmpdir = joinpath(@__DIR__, "..", "..", "data", "oned_sample")
sm = SampleModel("oned_sample", stan, tmpdir)
rc = stan_sample(sm)

chns, col_names = read_samples(sm, :array; return_parameters=true);

display(col_names)
println()

display(size(chns))
println()
