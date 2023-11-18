using StanSample, Test

stan = "
parameters {
    real r;
    matrix[2, 3] x;
    array[2, 2, 3] real<lower=0> z;
}
model {
    r ~ std_normal();

    for (i in 1:2) {
        x[i,:] ~ std_normal();
        for (j in 1:2)
            z[i, j, :] ~ std_normal();
    }
}
";

tmpdir = joinpath(@__DIR__, "..", "..", "data", "arrays")
sm = SampleModel("arrays", stan, tmpdir)
rc = stan_sample(sm)

chns, col_names = read_samples(sm, :array; return_parameters=true);

display(col_names)
println()

display(size(chns))
println()
