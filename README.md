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

### Generate QW step matrix from a coin operation:
```Mathematica
QWStepEvolutionMatrix[3, HadamardMatrix[2]] // MatrixForm
```

<img src="../media/snippet_QWStepEvolutionMatrix.png?raw=true" width="600">

The function `QWCoinMatrix` can also be used as a transparent wrapper to clarify when an input should be understood as the matrix representing a coin operation.
*E.g.* in the example above we can replace `HadamardMatrix[2]` with `QWCoinMatrix[HadamardMatrix[2]]`.



See [`QuantumWalksDemonstrations.nb`](./QuantumWalksDemonstrations.nb) for other usage examples.
