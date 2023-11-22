using StanSample, Test

stan = "
generated quantities {
  real base = normal_rng(0, 1);
  real basep1 = base + 1, basep2 = base + 2;
  real basep3 = base + 3, basep4 = base + 4, basep5 = base + 5;
  array[2,3] tuple(array[2] tuple(real, vector[2]), matrix[4,5]) ultimate =
    {
      {(
        {(base, [base *2, base *3]'), (base *4, [base*5, base*6]')},
        to_matrix(linspaced_vector(20, 7, 11), 4, 5) * base
        ),
       (
        {(basep1, [basep1 *2, basep1 *3]'), (basep1 *4, [basep1*5, basep1*6]')},
        to_matrix(linspaced_vector(20, 7, 11), 4, 5) * basep1
        ),
        (
          {(basep2, [basep2 *2, basep2 *3]'), (basep2 *4, [basep2*5, basep2*6]')},
          to_matrix(linspaced_vector(20, 7, 11), 4, 5) * basep2
       )
     },
     {(
        {(basep3, [basep3 *2, basep3 *3]'), (basep3 *4, [basep3*5, basep3*6]')},
        to_matrix(linspaced_vector(20, 7, 11), 4, 5) * basep3
        ),
       (
        {(basep4, [basep4 *2, basep4 *3]'), (basep4 *4, [basep4*5, basep4*6]')},
        to_matrix(linspaced_vector(20, 7, 11), 4, 5) * basep4
        ),
        (
          {(basep5, [basep5 *2, basep5 *3]'), (basep5 *4, [basep5*5, basep5*6]')},
          to_matrix(linspaced_vector(20, 7, 11), 4, 5) * basep5
       )
     }};

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