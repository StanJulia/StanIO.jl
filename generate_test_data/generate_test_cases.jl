using StanSample

stan = "
parameters {
    real r;
    real mu;
    real nu;
    matrix[2, 3] x;
    tuple(real, real) bar;
    tuple(real, tuple(real, real)) bar2;
    tuple(real, tuple(real, tuple(real, real))) bar3;
}
model {
    r ~ std_normal();

    for (i in 1:2) {
        x[i,:] ~ std_normal();
    }

    bar.1 ~ std_normal();
    bar.2 ~ std_normal();
    bar2.1 ~ std_normal();
    bar2.2.1 ~ std_normal();
    bar2.2.2 ~ std_normal();
    bar3.1 ~ std_normal();
    bar3.2.1 ~ std_normal();
    bar3.2.2.1 ~ std_normal();
    bar3.2.2.2 ~ std_normal();

    mu ~ normal(0, 1);
    nu ~ normal(mu, 1);
}
generated quantities {
    complex z;
    complex_vector[2] zv;
    z = nu + nu * 2.0i;
    zv = to_complex([3 * nu, 5 * nu]', [nu * 4, nu * 6]');
    }
";

tmpdir = joinpath("/Users", "rob", ".julia", "dev", "StanIO", "data", "test_data")
sm = SampleModel("test_data", stan, tmpdir)
rc = stan_sample(sm)

chns, col_names = read_samples(sm, :array; return_parameters=true);

display(col_names)
println()

display(size(chns))
println()
