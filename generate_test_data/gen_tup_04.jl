using StanSample

stan = "
generated quantities {
    real base = normal_rng(0, 1);
    array[3,2] tuple(real, array[2] real) a = 
        {{(base * 12, {base * 13, base}), (base * 14, {base * 15, base})},
        {(base * 16, {base * 17, base}), (base * 18, {base * 19, base})},
        {(base * 20, {base * 21, base}), (base * 22, {base * 23, base})}};
}
";


tmpdir = joinpath("/Users", "rob", ".julia", "dev", "StanIO", "data", "tup_04")
sm = SampleModel("tup_04", stan, tmpdir)
rc = stan_sample(sm)

chns, col_names = read_samples(sm, :array; return_parameters=true);

display(col_names)
println()

display(size(chns))
println()

