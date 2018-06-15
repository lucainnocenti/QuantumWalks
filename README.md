# QuantumWalks
This Mathematica package defines some basic function to ease the handling and simulation of discrete time quantum walks in some simple scenarios.

## Requirements
The [`QM`](https://github.com/lucainnocenti/QM) package is required for proper functioning.

## Installation
The easiest and recommended way is to clone (via `git clone`) this repository into the `Applications` directory (the one given by Mathematica upon evaluation of `FileNameJoin @ {$UserBaseDirectory, "Applications"}`).

If you don't want to use git, you can evaluate the following in a Mathematica session, which should automatically download and install the latest version of the repository (without putting it under version control).
This needs to be done only once.

    Module[{tmpFile, applicationsFolder, targetFolder},
        tmpFile = URLDownload @ "https://github.com/lucainnocenti/QuantumWalks/archive/master.zip";
        applicationsFolder = FileNameJoin @ {$UserBaseDirectory, "Applications"};
        targetFolder = FileNameJoin @ {applicationsFolder, "QuantumWalks"};
        If[DirectoryQ @ targetFolder,
            Print["The QuantumWalks folder already exists, which probably means that the package is already installed. Delete this folder with its content and run again this command to reinstall the package from scratch."]; Abort[],
            ExtractArchive[tmpFile, applicationsFolder];
            RenameDirectory[
                FileNameJoin @ {applicationsFolder, "QuantumWalks-master"},
                targetFolder
            ]
        ]
    ];

Once the package is installed, it needs to be imported with ``Needs["QuantumWalks`"]``.

## Usage

See [`QuantumWalksDemonstrations.nb`](./QuantumWalksDemonstrations.nb) for some usage examples.
