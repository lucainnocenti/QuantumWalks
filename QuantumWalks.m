(* Abort for old, unsupported versions of Mathematica *)
If[$VersionNumber < 10,
  Print["ReckDecomposition requires Mathematica 10.0 or later."];
  Abort[]
];

BeginPackage["QuantumWalks`", {"QM`"}];

(* Unprotect all package symbols *)
Unprotect @@ Names["QuantumWalks`*"];
ClearAll @@ Names["QuantumWalks`*"];

QWComputeCoinFrom2DState;
QWCoinMatrixToParameters;

QWStepEvolutionMatrix;
QWManyStepsEvolutionMatrix;

Begin["`Private`"];

(* We define KP just to save a few characters around *)
KP[args___] := KroneckerProduct[args];

shiftLeftMatrix[dim_Integer] := IdentityMatrix @ dim;
shiftRightMatrix[dim_Integer] := SparseArray[{
    {i_, j_} /; i == j + 1 -> 1
  },
  {#, #} & @ dim
];

controlledShiftMatrix[numberOfSteps_Integer] := Plus[
  KP[shiftLeftMatrix[numberOfSteps + 1], {{1, 0}, {0, 0}}],
  KP[shiftRightMatrix[numberOfSteps + 1], {{0, 0}, {0, 1}}]
];

coinOperatorMatrix[{theta_, xi_, zeta_}] := {
  {
    {Exp[I xi] Cos[theta], Exp[I zeta] Sin[theta]},
    {-Exp[-I zeta] Sin[theta], Exp[-I xi] Cos[theta]}
  }
};
coinOperatorMatrix[{theta_, xi_}] := coinOperatorMatrix[{theta, xi, 0}];
coinOperatorMatrix[{theta_}] := coinOperatorMatrix[{theta, 0, 0}];
coinOperatorMatrix[theta_] := coinOperatorMatrix[{theta, 0, 0}];

QWCoinMatrixToParameters[su2Matrix_] := {
  ArcTan @ Abs[su2Matrix[[1, 2]] / su2Matrix[[1, 1]]],
  Arg[su2Matrix[[1, 1]] / su2Matrix[[2, 2]]] / 2,
  Pi / 2 + Arg[su2Matrix[[1, 2]] / su2Matrix[[2, 1]]] / 2
};

(* Take a walker+coin state in 2column form, and return the coin operator
   generating it. *)
QWComputeCoinFrom2DState[state : {{_, _}..}] := Module[{col1, col2},
  col1 = Normalize @ {state[[1, 1]], state[[2, 2]]};
  col2 = Conjugate @ Cross @ col1;
  Transpose @ {col1, col2}
];


(* Functions handling evolution back and forth *)

QWStepEvolutionMatrix[numberOfSteps_Integer, coinMatrix_?MatrixQ] := Dot[
  controlledShiftMatrix @ numberOfSteps,
  KP[IdentityMatrix[numberOfSteps + 1], coinMatrix]
];
QWStepEvolutionMatrix[numberOfSteps_Integer, coinParameters_List] := Dot[
  controlledShiftMatrix @ numberOfSteps,
  KP[IdentityMatrix[numberOfSteps + 1], coinOperatorMatrix @ coinParameters]
];


QWManyStepsEvolutionMatrix[numberOfSteps_, coinParameters_List] := Fold[
  Dot[QWStepEvolutionMatrix[numberOfSteps, #2], #1] &,
  IdentityMatrix[2 * (numberOfSteps + 1)],
  coinParameters
];


(* Protect all package symbols *)
With[{syms = Names["QuantumWalks`*"]},
  SetAttributes[syms, {Protected, ReadProtected}]
];

End[];
EndPackage[];
