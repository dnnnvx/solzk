pragma circom 2.0.0;

template LessThan10() {

  signal input a;
  signal output out;

  signal b;
  b <-- (a+6) >> 4;

  out <== a*b;
}

component main = LessThan10();