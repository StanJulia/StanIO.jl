using StanSample

stan = "
transformed data {
  array[10] int y = {0, 1, 0, 0, 0, 0, 0, 0, 0, 1};
}
parameters {
  real<lower=0, upper=1> theta;
}
model {
  theta ~ beta(1, 1); // uniform prior on interval 0,1
  y ~ bernoulli(theta);
}
generated quantities {
  // x is a 4 x 3 matrix where i,j entry == rownum
  matrix[4, 3] z;
  for (row_num in 1 : 4) {
    for (col_num in 1 : 3) {
      z[row_num, col_num] = row_num;
    }
  }
}
";

tmpdir = joinpath(@__DIR__, "..", "..", "data", "one_row")
sm = SampleModel("one_row", stan, tmpdir)
rc = stan_sample(sm)

chns, col_names = read_samples(sm, :array; return_parameters=true)

display(col_names)
println()

display(size(chns))
println()
