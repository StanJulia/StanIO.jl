generated quantities {
    real base = normal_rng(0, 1);
    array[3,2] tuple(real, array[2] real) a = 
        {{(base * 12, {base * 13, base}), (base * 14, {base * 15, base})},
        {(base * 16, {base * 17, base}), (base * 18, {base * 19, base})},
        {(base * 20, {base * 21, base}), (base * 22, {base * 23, base})}};
}