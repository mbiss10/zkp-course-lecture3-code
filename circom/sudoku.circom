pragma circom 2.0.0;

template NonEqual() {
    signal input in0;
    signal input in1;

    // check that (in0 - in1) is non-zero
    signal inverse;
    inverse <-- 1 / (in0 - in1);
    inverse * (in0 - in1) === 1;
}

// ensure all elements in an array of n elements are unique
template Distinct(n) {
    signal input in[n];
    component nonEqual[n][n];
    for(var i = 0; i < n; i++){
        for(var j = 0; j < i; j++){
            // use equal sign for creating component
            nonEqual[i][j] = NonEqual();

            // use <== for "gets and constrains"
            nonEqual[i][j].in0 <== in[i];
            nonEqual[i][j].in1 <== in[j];
        }
    }
}

// Enforce that 0 <= in < 16
template Bits4(){
    signal input in;
    signal bits[4];
    var bitsum = 0;
    for (var i = 0; i < 4; i++) {
        bits[i] <-- (in >> i) & 1;
        bits[i] * (bits[i] - 1) === 0;
        bitsum = bitsum + 2 ** i * bits[i];
    }
    bitsum === in;
}

// Enforce that 1 <= in <= 9
template OneToNine() {
    signal input in;
    component lowerBound = Bits4();
    component upperBound = Bits4();

    // ensure n-1 is in range 0-16 (n must be between 1 and 16, inclusive)
    lowerBound.in <== in - 1;

    // ensure n+6 is in range 0-16 (n must be between -6 and 9, inclusive)
    upperBound.in <== in + 6;
}

template Sudoku(n) {
    // solution is a 2D array: indices are (row_i, col_i)
    signal input solution[n][n];
    // puzzle is the same, but a zero indicates a blank
    signal input puzzle[n][n];

    component distinct[n];
    component inRange[n][n];

    for (var row_i = 0; row_i < n; row_i++) {
        for (var col_i = 0; col_i < n; col_i++) {
            // (We could make this a component)
            // Ensure solution matches starting values in puzzle array.
            // If puzzle cell is 0, then left value is zero. If puzzle cell is non-zero, then right term is zero if the two match.
            puzzle[row_i][col_i] * (puzzle[row_i][col_i] - solution[row_i][col_i]) === 0;
        }
    }

    for (var row_i = 0; row_i < n; row_i++) {
        for (var col_i = 0; col_i < n; col_i++) {
            // initialize n components
            if (row_i == 0) {
                distinct[col_i] = Distinct(n);
            }
        
            // ensure each solution cell is in range 1-9
            inRange[row_i][col_i] = OneToNine();
            inRange[row_i][col_i].in <== solution[row_i][col_i];

            // ensure uniqueness in rows
            distinct[col_i].in[row_i] <== solution[row_i][col_i];
        }
    }
}

component main {public[puzzle]} = Sudoku(9);
