Test Newton interpolation with 3 points
  $ cat <<EOF | my_lab3 --newton --step 0.5 -n 3
  > 0 0
  > 1 1
  > 2 4
  > EOF
  newton: 0 0
  newton: 0.5 0.25
  newton: 1 1
  newton: 1.5 2.25
  newton: 2 4

Test Newton interpolation with sliding window
  $ cat <<EOF | my_lab3 --newton --step 1.0 -n 3
  > 0 0
  > 1 1
  > 2 4
  > 3 9
  > EOF
  newton: 0 0
  newton: 1 1
  newton: 2 4
  newton: 3 9
