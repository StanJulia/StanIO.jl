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