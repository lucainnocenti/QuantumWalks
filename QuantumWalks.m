(* Abort for old, unsupported versions of Mathematica *)
If[$VersionNumber < 10,
  Print["QuantumWalks requires Mathematica 10.0 or later."];
  Abort[]
];

BeginPackage["QuantumWalks`", {"QM`"}];

(* Unprotect all package symbols *)
Unprotect @@ Names["QuantumWalks`*"];
ClearAll @@ Names["QuantumWalks`*"];

QWCoinMatrixToParameters;
QWCoinParametersToMatrix;

QWStepEvolutionMatrix;
QWManyStepsEvolutionMatrix;
QWEvolve;

QWDevolve1Step;
QWComputeCoinFromState;
QWComputeCoinParametersFromState;

$QWSU2Notation;

QWProjectCoin::usage = "\
QWProjectCoin[state, projectionVector] returns the (normalized) state obtained \
by projecting the coin degree onto projectionVector.
The output state is therefore a superposition of site states (with no coin \
degree of freedom).";
QWProjectionProbability::usage = "\
QWProjectionProbability[state, projectionVector] returns the probability of \
the given projection over the coin degree of freedom.";

Begin["`Private`"];

(* We define KP just to save a few characters around *)
KP[args___] := KroneckerProduct[args];

norm2[args_] := Norm[args] ^ 2;

shiftLeftMatrix[dim_Integer] := IdentityMatrix @ dim;
shiftRightMatrix[dim_Integer] := SparseArray[{
    {i_, j_} /; i == j + 1 -> 1
  },
  {#, #} & @ dim
];

controlledShiftMatrix[numberOfSites_Integer] := Plus[
  KP[shiftLeftMatrix[numberOfSites], {{1, 0}, {0, 0}}],
  KP[shiftRightMatrix[numberOfSites], {{0, 0}, {0, 1}}]
];


$QWSU2Notation = "New";

QWCoinParametersToMatrix[{theta_, xi_, zeta_}] := Which[
  $QWSU2Notation == "OldDraft",
  {
    {Exp[I xi] Sin[theta], -Exp[I zeta] Cos[theta]},
    {Cos[theta], Exp[I * (zeta - xi)] Sin[theta]}
  },
  $QWSU2Notation == "Old",
  {
    {Exp[I xi] Cos[theta], Exp[I zeta] Sin[theta]},
    {Exp[-I zeta] Sin[theta], -Exp[-I xi] Cos[theta]}
  },
  $QWSU2Notation == "New",
  {
    {Exp[I xi] Cos[theta], Exp[I zeta] Sin[theta]},
    {-Exp[-I zeta] Sin[theta], Exp[-I xi] Cos[theta]}
  }
];
QWCoinParametersToMatrix[{theta_, xi_}] := QWCoinParametersToMatrix[{theta, xi, 0}];
QWCoinParametersToMatrix[{theta_}] := QWCoinParametersToMatrix[{theta, 0, 0}];
QWCoinParametersToMatrix[theta_] := QWCoinParametersToMatrix[{theta, 0, 0}];

QWCoinMatrixToParameters[su2Matrix_] := Module[{theta, xi, zeta},
  Which[
    $QWSU2Notation == "New",
    (* the value of theta obtained as below is always between 0 and Pi / 2 *)
    theta = ArcTan @ Abs[su2Matrix[[1, 2]] / su2Matrix[[1, 1]]];
    xi = Arg[su2Matrix[[1, 1]] / Cos @ theta];
    zeta = Arg[su2Matrix[[1, 2]] / Sin @ theta];
    {theta, xi, zeta},

    True,
    QWCoinMatrixToParameters::notImplementedYet = "Functionality not implemented yet.";
    Message[QWCoinMatrixToParameters::notImplementedYet];
    Abort[]
  ]
];

(* Take a walker+coin state in 2column form, and return the coin operator
   generating it. *)
QWComputeCoinFromState[state : {{_, _}..}] := Module[{col1, col2},
  col1 = Normalize @ {state[[1, 1]], state[[2, 2]]};
  col2 = Conjugate @ Cross @ col1;
  Transpose @ {col1, col2}
];
QWComputeCoinFromState[state_List] := QWComputeCoinFromState @ Partition[state, 2];


(* Functions handling forward time-evolution of the walker *)

QWStepEvolutionMatrix[numberOfSites_Integer, coinMatrix_?MatrixQ] := Dot[
  controlledShiftMatrix @ numberOfSites,
  KP[IdentityMatrix[numberOfSites], coinMatrix]
];

QWStepEvolutionMatrix[
  numberOfSites_Integer,
  coinParameters_ 
] := Dot[
  controlledShiftMatrix @ numberOfSites,
  KP[IdentityMatrix[numberOfSites],
    QWCoinParametersToMatrix @ coinParameters
  ]
];


QWManyStepsEvolutionMatrix[numberOfSites_, coinParameters_, 1] := QWStepEvolutionMatrix[
  numberOfSites, coinParameters
];

QWManyStepsEvolutionMatrix[numberOfSites_Integer, coinParameters_List, _] := Fold[
  Dot[QWStepEvolutionMatrix[numberOfSites, #2], #1] &,
  IdentityMatrix[2 * (numberOfSites)],
  coinParameters
];


QWEvolve[
  initialCoinState : {_, _}, coinParameters_List,
  numberOfSteps_Integer : 0
] := With[{
    nSteps = If[numberOfSteps == 0,
      Length @ coinParameters,
      numberOfSteps
    ]
  },
  Dot[
    QWManyStepsEvolutionMatrix[nSteps + 1, coinParameters, nSteps],
    SparseArray[
      {1 -> initialCoinState[[1]], 2 -> initialCoinState[[2]]},
      2 * (nSteps + 1)
    ]
  ]
];


(* Functions handling backtracing of the walker evolution from a final state *)
QWDevolve1Step[state : {{_, _}..}, coin_?MatrixQ] := With[{
    stateWithNoZeroElements = Most @ Transpose[
      {#[[1]], RotateLeft @ #[[2]]} & @ Transpose @ state
    ]
  },
  Dot[Inverse @ coin, #] & /@ stateWithNoZeroElements
];
QWDevolve1Step[state_List, coin_?MatrixQ] := QWDevolve1Step[
  Partition[state, 2], coin
];

QWDevolve1Step[state_] := {QWDevolve1Step[state, #], #} &[
  QWComputeCoinFromState @ state
];

QWComputeCoinParametersFromState[state : {{_, _}..}] := Nest[
  (Sow @ QWCoinMatrixToParameters @ #[[2]]; First @ #) & @ QWDevolve1Step @ # &,
  state, Length @ state - 1
] // Reap // Last // Last;

QWComputeCoinParametersFromState[stateKet_] := QWComputeCoinParametersFromState[
  Partition[stateKet, 2]
];


(* Functions handling the projection of the coin *)
QWProjectCoin[stateMatrix_?MatrixQ, projKet_List] := Normalize @ Map[
  Dot[Conjugate @ projKet, #] &,
  stateMatrix
];

QWProjectCoin[stateKet_List, projKet_List] := QWProjectCoin[
  Partition[stateKet, 2], projKet
];

QWProjectCoin[projection_][state_] := QWProjectCoin[state, projection];


QWProjectionProbability[stateMatrix_?MatrixQ, projKet_List] := norm2 @ Map[
  Dot[Conjugate @ Normalize @ projKet, #] &,
  stateMatrix
];

QWProjectionProbability[stateKet_List, projection_] := QWProjectionProbability[
  Partition[stateKet, 2], projection
];

QWProjectionProbability[projection_][state_] := QWProjectionProbability[
  state, projection
];


(* Protect all package symbols *)
With[{syms = Names["QuantumWalks`*"]},
  SetAttributes[syms, {Protected, ReadProtected}]
];

Unprotect[
  $QWSU2Notation
];

End[];
EndPackage[];
