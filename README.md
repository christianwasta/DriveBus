# DriveBus: Emulating Human-Like Game-Playing Behaviors Using Neural-Symbolic AI (ACT-R)

## Project Overview

"Drive the Bus" is a computer science project focused on designing and developing models that emulate human-like behaviors in gameplay. Using the ACT-R cognitive architecture, we create nuanced models that interact with game interfaces unaltered from their original form. Each model is grounded in perceptual and motor skills shaped by the virtual environment. The simulation environment is the famous game called DesertBus which can be downloaded through STEAM game platform using https://store.steampowered.com/agecheck/app/638110/

## Features

- Models built on ACT-R, integrating cognitive processes with game-playing behavior.
- Diverse behavioral patterns representing distinct types of human players.
- Real-time interaction with the game environment, mimicking human input.

## Installation

```bash
# Clone the repository
git clone https://github.com/SiyuWu528/Drivebus.git
```
# Navigate to the project directory
```
cd DriveBus
```
# Usage
1. You need a Windows system to run the simulation since Steam only supports DesertBus games on Windows system
1. Download ACT-R 7.27.9 from http://act-r.psy.cmu.edu/software/
2. Download Emacs and Lisp Slime. it's best to run the ACT-R model using LISP slime since ACT-R is written in common Lisp
3. Replace the correct VisiTor file path in the ACT-R model
4. Open the desert bus game environment, and manually proceed to the start position of the bus.
5. Run the ACT-R model

# License
This project is licensed under the MIT License.

# Acknowledge
We thank Dan Bothell's help with the ACT-R model

# Contact Information
Siyu Wu - project Lead - SiyuWu528

# Cite

Please cite the following papers if you use this work as part of your research, development, or project.

```bibtex

@inproceedings{wu2023BRIMS,
  title={Cognition Models Bake-off: Lessons Learned from Creating Long-Running Cognitive Models},
  author={Wu, Siyu and Bagherzadeh, Amir and Ritter, Frank E and Tehranchi, Farnaz},
  booktitle={Proceedings of the 16th International Conference on Social Computing, Behavioral-Cultural Modeling \& Prediction and Behavior Representation in Modeling and Simulation (SBP-BRiMs)},
  year={2023},
}
```
```bibtex
@inproceedings{wu2023ICCM,
  title={Long road ahead: Lessons learned from the (soon to be) longest running cognitive model},
  author={Wu, S. and Bagherzadeh, A. and Ritter, F. and Tehranchi, F.},
  booktitle={Proceedings of the 21st International Conference on Cognitive Modeling (ICCM)},
  year={2023}
}
```



