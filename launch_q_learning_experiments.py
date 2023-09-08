import pddlgym
import random
import numpy as np
import tqdm
import os
import pickle
import re

EPISODES = 5000             #Number of simulations
EPISODE_STEP_LIMIT = 1000   #Max steps for each episode
LR = 0.1                    #Parameter alpha in Q-learning. Equals to the learning rate
GAMMA = 0.99                 #Discount factor
EPSILON = 0.1               

def get_environment(problem_index):
    env = pddlgym.make("PDDLEnvPort-v0")
    env.fix_problem_index(problem_index)
    env.seed(33)
    return env

def select_max_action(q_s):
    return np.argmax(q_s)

def get_env_actions(env):
    state, deb_info = env.reset()
    env.action_space.all_ground_literals(state) #line so gym computes num of actions for that state and thus all possible actions
    return list(env.action_space._all_ground_literals) #retrieve all possible actions por any state

def select_action(env, qs, state, actions, force_random_pick, variable_epsilon = False, ns = 0):
    if variable_epsilon:
        EPSILON = 1/ns
    else:
        EPSILON = 0.1
    if random.uniform(0, 1) > EPSILON and not force_random_pick:
        action_index =  select_max_action(qs)
        return actions[action_index], action_index
    else:
        rand_action = env.action_space.sample(state)
        return rand_action, actions.index(rand_action)

def save_object(path, name, ob):
    with open(os.path.join(path, name+'.pickle'), 'wb') as handler:
        pickle.dump(ob, handler)

def q_learning(path, index, variable_lr = False, punish_useless_actions = False, random_init = 0, variable_epsilon = False): #Number of episodes with full exploration to initialize Q
    Q = {}
    N = {}
    env = get_environment(index)
    env_actions = get_env_actions(env)
    useless_action_selection_per_episode = []
    steps_per_episode = []
    
    for episode in tqdm.tqdm(range(EPISODES)):
        useless_action_count = 0
        steps_in_episode = 0
        state, deb_info = env.reset()
        while True:
            state_count = N.get(state, 0)
            N[state] = state_count + 1

            q_s = Q.get(state, np.zeros((len(env_actions),)))

            selected_action, action_index = select_action(env, q_s, state, env_actions, episode < random_init, variable_epsilon, N[state])

            new_state, _, done, _ = env.step(selected_action)
            reward = -1 if not done else 0

            if new_state == state:
                reward = -np.inf if punish_useless_actions else reward
                useless_action_count += 1

            q_new_s = Q.get(new_state, np.zeros((len(env_actions),)))

            if variable_lr:
                delta = q_s[action_index] + (1/N[state]) * (reward + GAMMA * q_new_s[select_max_action(q_new_s)] - q_s[action_index])
            else:
                delta = q_s[action_index] + LR * (reward + GAMMA * q_new_s[select_max_action(q_new_s)] - q_s[action_index])

            q_s[action_index] = delta
            Q[state] = q_s
            state = new_state
            steps_in_episode += 1

            if done:
                print("done in: {}".format(steps_in_episode))
                break
            
            if steps_in_episode == EPISODE_STEP_LIMIT:
                print("episode aborted: max steps reached")
                break
        steps_per_episode.append(steps_in_episode)
        useless_action_selection_per_episode.append(useless_action_count)

    save_object(path, "Q", Q)
    save_object(path, "N", N)
    save_object(path, "env_actions", env_actions)
    save_object(path, "useless_action_selection_per_episode", useless_action_selection_per_episode)
    save_object(path, "steps_per_episode", steps_per_episode)

def create_folder_if_not_exists(dir):
    if not os.path.isdir(dir):
        os.mkdir(dir)

if __name__ == '__main__':
    experiment_variants = {
        "base": (False, False, 0), 
        "punish_useless_actions": (False, True, 0), 
        "punish_useless_actions_variable_alpha": (True, True, 0), 
        "variable_epsilon": (False, False, 0, True), 
        "punish_useless_actions_variable_epsilon": (False, True, 0, True), 
        "punish_useless_actions_variable_alpha_variable_epsilon": (True, True, 0, True),
        "random_Q_init": (False, False, 200), 
        "punish_useless_actions_rand_q": (False, True, 200), 
        "punish_useless_actions_variable_alpha_rand_q": (True, True, 200)
    }
    root = os.getcwd()
    results_folder = os.path.join(root, "experiment_results")
    
    create_folder_if_not_exists(results_folder)
    
    env = pddlgym.make("PDDLEnvPort-v0")
    problem_folders = [ re.sub('.*problem_port_', "", p.problem_fname).replace(".pddl", "") for p in env.problems]

    for i, folder in enumerate(problem_folders):
        folder_full_path = os.path.join(results_folder, folder)
        create_folder_if_not_exists(folder_full_path)
        for experiment in experiment_variants.keys():
            experiment_full_path = os.path.join(folder_full_path, experiment)
            create_folder_if_not_exists(experiment_full_path)

            q_learning(experiment_full_path, i, *experiment_variants[experiment])

    
    