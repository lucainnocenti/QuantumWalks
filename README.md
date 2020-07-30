# QuantumWalks
This Mathematica package defines some basic function to ease the handling and simulation of discrete-time one-dimensional quantum walks with two-dimensional coins.

## Requirements
The [`QM`](https://github.com/lucainnocenti/QM) package is required for proper functioning.

## Installation
The easiest and recommended way is to clone (via `git clone`) this repository into the `Applications` directory (the one given by Mathematica upon evaluation of `FileNameJoin @ {$UserBaseDirectory, "Applications"}`).
Once the package is installed, it needs to be imported with ``Needs["QuantumWalks`"]``.

Alternatively, the package can be imported directly from GitHub without installing it, using

    Get["https://raw.githubusercontent.com/lucainnocenti/QuantumWalks/master/QuantumWalks.m"];


## Usage

### Generate QW step matrices from coin operations:
```Mathematica
QWStepEvolutionMatrix[3, HadamardMatrix[2]] // MatrixForm
```

<img src="../media/snippet_QWStepEvolutionMatrix.png?raw=true" height="200">

The function `QWCoinMatrix` can also be used as a transparent wrapper to clarify when an input should be understood as the matrix representing a coin operation.
*E.g.* in the example above we can replace `HadamardMatrix[2]` with `QWCoinMatrix[HadamardMatrix[2]]`.

We can get the evolution matrix corresponding to multiple QW steps using `QWManyStepsEvolutionMatrix`. For example, to compute the matrix describing *two* steps each one using a Hadamard coin operation, with a total number of sites in the underlying space of 3, we can use:
```Mathematica
QWManyStepsEvolutionMatrix[3, 
    Table[QWCoinMatrix[HadamardMatrix@2], 2]
] // MatrixForm
```

<img src="../media/snippet_QWManyStepsEvolutionMatrix.png?raw=true" height="200">

To evolve an input state on a fixed single walker position, and initial coin state either H or V, we can use

```Mathematica
numberOfSteps = 4;
evolutionMatrix = QWManyStepsEvolutionMatrix[
    numberOfSteps + 1,
    Table[QWCoinMatrix[RandomUnitary@2], numberOfSteps]
];
outputState1Up = evolutionMatrix[[All, 1]] // Chop (* output entering with |1,H> *)
outputState1Down = evolutionMatrix[[All, 2]] // Chop (* output entering with with |1,V> *)
```
Note that this requires the function `RandomUnitary` to generate random unitary evolution. This is defined *e.g.* in [QM](https://github.com/lucainnocenti/QM).


See [`QuantumWalksDemonstrations.nb`](./QuantumWalksDemonstrations.nb) for other usage examples.
