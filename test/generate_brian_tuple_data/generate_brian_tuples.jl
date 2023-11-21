using StanSample, Test

stan = "
generated quantities {
  real base = normal_rng(0, 1);
  int base_i = to_int(normal_rng(10, 10));

  tuple(real, real) pair = (base, base * 2);

  tuple(real, tuple(int, complex)) nested = (base * 3, (base_i, base * 4.0i));
  array[2] tuple(real, real) arr_pair = {pair, (base * 5, base * 6)};

  array[3] tuple(tuple(real, tuple(int, complex)), real) arr_very_nested
    = {(nested, base*7), ((base*8, (base_i*2, base*9.0i)), base * 10), (nested, base*11)};

  array[3,2] tuple(real, real) arr_2d_pair = {{(base * 12, base * 13), (base * 14, base * 15)},
                                              {(base * 16, base * 17), (base * 18, base * 19)},
                                              {(base * 20, base * 21), (base * 22, base * 23)}};
}
";

tmpdir = joinpath(@__DIR__, "..", "..", "data", "brian_tuples")
sm = SampleModel("brian_tuples", stan, tmpdir)
rc = stan_sample(sm)

chns, col_names = read_samples(sm, :array; return_parameters=true);

display(col_names)
println()

display(size(chns))
println()
