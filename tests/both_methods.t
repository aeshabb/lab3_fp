Test both linear and Newton methods together
  $ cat <<EOF | my_lab3 --linear --newton --step 1.0 -n 2
  > 0 0
  > 2 4
  > 4 8
  > EOF
  linear: 0 0
  linear: 1 2
  linear: 2 4
  newton: 0 0
  newton: 1 2
  newton: 2 4
  linear: 3 6
  linear: 4 8
  newton: 3 6
  newton: 4 8

Test both methods with different step size
  $ cat <<EOF | my_lab3 --linear --newton --step 0.5
  > 0 0
  > 1 1
  > 2 4
  > EOF
  linear: 0 0
  linear: 0.5 0.5
  linear: 1 1
  newton: 0 0
  newton: 0.5 0.5
  newton: 1 1
  linear: 1.5 2.5
  linear: 2 4
  newton: 1.5 2.5
  newton: 2 4

Test both methods with window size 3
  $ cat <<EOF | my_lab3 --linear --newton --step 1.0 -n 3
  > 0 0
  > 1 1
  > 2 4
  > 3 9
  > EOF
  linear: 0 0
  linear: 1 1
  linear: 2 2
  newton: 0 0
  newton: 1 1
  newton: 2 4
  linear: 2 4
  linear: 3 7
  newton: 3 9
