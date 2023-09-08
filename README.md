# Q-learning experimentation
Repository containing experiments and variations over the Q-learning algorithm using pddl gym and a baseline plannification problem

**Steps for reproductibility**

Clone and install pddlgym
```
git clone https://github.com/tomsilver/pddlgym.git

cd pddlgym

pip install -e .

```
Copy domain and problem definitions to pddlgym folder

```
mkdir pddl/port

cd ..

cp pddl_code/port.pddl pddlgym/pddlgym/pddl

cp pddl_code/custom_problems/* pddlgym/pddlgym/pddl/port
```
Open `pddlgym/pddlgym/__init__.py` and add port definition to the existing environments:

```
...
for env_name, kwargs in [
        ("port", {'operators_as_actions' : True,
                     'dynamic_action_space' : True}),
        ("gripper", 
...
```
Now e have all the requierements needed to launch the experiments:
```
python launch_q_learning_experiments.py > experiment_results/output.txt
```
And plot the results:
```
python plot_results.py
```