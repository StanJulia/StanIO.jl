using StanSample

stan = "
generated quantities {
    real mu = normal_rng(0, 1);
    vector[2] v = [mu, mu * 2]';
    row_vector[3] r = mu + [mu, mu * 2, mu * 3];
    matrix[2, 3] m = mu * to_matrix(linspaced_vector(6, 5, 11), 2, 3);
    array[2] matrix[2, 3] d2;
    for (i in 1 : 2) {
        d2[i] = i * mu * to_matrix(linspaced_vector(6, 5, 11), 2, 3);
    }

    real nu = normal_rng(mu, 1);
    complex z = nu + nu * 2.0i;
    complex_vector[2] zv = to_complex([3 * nu, 5 * nu]', [nu * 4, nu * 6]');
    complex_matrix[2, 3] zm = to_complex(m, m + 1);
    array[4] complex_matrix[2, 3] zd3;
    for (i in 1 : 4) {
        zd3[i] = to_complex(d2[i], d2[i] + 1);
    }

    real base = normal_rng(0, 1);
    int base_i = to_int(normal_rng(10, 10));

    tuple(real, real) t1 = (base, base * 2);

    tuple(real, tuple(int, complex)) t2 = (base * 3, (base_i, base * 4.0i));
    array[2] tuple(real, real) t3 = {t1, (base * 5, base * 6)};

    array[3] tuple(tuple(real, tuple(int, complex)), real) t4
        = {(t2, base*7), ((base*8, (base_i*2, base*9.0i)), base * 10), (t2, base*11)};

    array[3,2] tuple(real, real) mixed = {{(base * 12, base * 13), (base * 14, base * 15)},
                                         {(base * 16, base * 17), (base * 18, base * 19)},
                                         {(base * 20, base * 21), (base * 22, base * 23)}};
}";

tmpdir = joinpath("/Users", "rob", ".julia", "dev", "StanIO", "data", "test_data")
sm = SampleModel("test_data", stan, tmpdir)
rc = stan_sample(sm)

chns, col_names = read_samples(sm, :array; return_parameters=true);

display(col_names)
println()

display(size(chns))
println()
