Test linear interpolation with default step
  $ cat <<EOF | my_lab3 --linear --step 1.0
  > 0 0
  > 2 4
  > EOF
  linear: 0 0
  linear: 1 2
  linear: 2 4

Test linear interpolation with custom step
  $ cat <<EOF | my_lab3 --linear --step 0.5
  > 0 0
  > 1 1
  > EOF
  linear: 0 0
  linear: 0.5 0.5
  linear: 1 1

Test linear interpolation with larger window
  $ cat <<EOF | my_lab3 --linear --step 1.0 -n 3
  > 0 0
  > 1 1
  > 2 4
  > 3 9
  > EOF
  linear: 0 0
  linear: 1 1
  linear: 2 2
  linear: 2 4
  linear: 3 7
