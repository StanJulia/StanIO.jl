using StanSample

stan = "
generated quantities {
    real base = normal_rng(0, 1);
    matrix[4, 5] m = to_matrix(linspaced_vector(20, 7, 11), 4, 5) * base;
    array[2,3] tuple(array[2] tuple(real, array[2] real), matrix[4,5]) u =
    {
        {
            (
                {(base, {base *2, base *3}), (base *4, {base*5, base*6})}, m
            ),
            (
                {(base, {base *2, base *3}), (base *4, {base*5, base*6})}, m
            ),
            (
                {(base, {base *2, base *3}), (base *4, {base*5, base*6})}, m
            )
        },
        {
            (
                {(base, {base *2, base *3}), (base *4, {base*5, base*6})}, m
            ),
            (
                {(base, {base *2, base *3}), (base *4, {base*5, base*6})}, m
            ),
            (
                {(base, {base *2, base *3}), (base *4, {base*5, base*6})}, m
            )
        }
    };
}
";


tmpdir = joinpath("/Users", "rob", ".julia", "dev", "StanIO", "data", "mixed_02")
sm = SampleModel("mixed_02", stan, tmpdir)
rc = stan_sample(sm)

chns, col_names = read_samples(sm, :array; return_parameters=true);

display(col_names)
println()

display(size(chns))
println()

