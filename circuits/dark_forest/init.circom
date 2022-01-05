pragma circom 2.0.0;

include "../circomlib/mimcsponge.circom";
include "../circomlib/comparators.circom";

// - It has to be within a Euclidean distance of 64 to the origin (0, 0)
// - Its Euclidean distance to the origin (0,0) has to be more than 32.
// - 💫 GCD(x,y) must be greater than 1 and must not be a prime number.💫 
// - It cannot be a position where other players have spawned within the last 5 minutes
// - It cannot be a position currently occupied by another player.

template Init() {
  signal input x;
  signal input y;
  signal output h;

  signal sqX;
  signal sqY;
  sqX <== x * x;
  sqY <== y * y;

  /* calculate the euclidean distance from the origin (0, 0) <=> (X, Y) */
  component comp0 = LessThan(64);
  comp0.in[0] <== sqX + sqY;
  comp0.in[1] <== 64 * 64;
  comp0.out === 1;

  /* distance must be > 32 */
  component comp1 = LessThan(64);
  comp1.in[0] <== sqX + sqY;
  comp1.in[1] <== 32 * 32;
  comp1.out === 0;

  /* check MiMCSponge(x,y) = pub */
  component mimc = MiMCSponge(2, 220, 1);
  mimc.ins[0] <== x;
  mimc.ins[1] <== y;
  mimc.k <== 0;

  h <== mimc.outs[0];
}

component main = Init();