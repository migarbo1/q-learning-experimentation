import matplotlib.pyplot as plt
import numpy as np
import pddlgym
import pickle
import os

def load_pickle_objects(path):
    objects = []
    for name in ['Q', 'N', 'steps_per_episode', 'useless_action_selection_per_episode', 'env_actions']:
        with open(os.path.join(path, name) + '.pickle', 'rb') as handle:
            objects.append(pickle.load(handle))
    return (*objects,)

def get_environment(problem_index):
    env = pddlgym.make("PDDLEnvPort-v0")
    env.fix_problem_index(problem_index)
    return env

def select_max_action(Q):
    return np.argmax(Q)

def get_env_actions(env):
    state, deb_info = env.reset()
    env.action_space.all_ground_literals(state) #line so gym computes num of actions for that state and thus all possible actions
    return list(env.action_space._all_ground_literals) #retrieve all possible actions por any state

def get_best_policy(env, Q, actions):
    policy_score = 0
    action_traze = []
    done = False
    state, _ = env.reset()
    while not done:
        act_ind = select_max_action(Q.get(state))
        action_traze.append(actions[act_ind])
        new_state, reward, done, info = env.step(actions[act_ind])
        policy_score -= 1
        state = new_state
        if policy_score < -50:
            break
    print("policy score:", policy_score)
    print("action traze:", action_traze)

def reset_plot():
    plt.close()
    plt.cla()
    plt.clf()

def prepare_collection(collection):
    means = []
    stds = []
    for i in range(0, len(collection), 20):
        means.append(np.mean(collection[i:i+20]))
        stds.append(np.std(collection[i:i+20])/2)
    return means, stds

def print_comparison(filename, title, xlabel, ylabel ,collection):
    reset_plot()
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)

    for collection_item, collection_name in collection:
        means, stds = prepare_collection(collection_item)
        plt.errorbar([i for i in range(len(means))], means, fmt='.', yerr= stds, label = collection_name)
    plt.gcf().set_size_inches(20, 13)
    plt.legend(title = 'Q-learning variants')
    plt.savefig(filename, dpi=200)
    plt.show()

if __name__ == '__main__':
    root = os.path.join(os.getcwd(), 'experiment_results')
    for index, problem in enumerate(os.listdir(root)):
        print("problem", problem)
        steps_per_episode_collection = []
        repeated_state_count_collection = []
        variant_root = os.path.join(root, problem)
        for variant in os.listdir(variant_root):
            print()
            print("variant:", variant)
            variant_joined_path = os.path.join(variant_root, variant)
            if os.path.isdir(variant_joined_path):
                Q, N, steps_per_episode, useless_action_selection_per_episode, env_actions = load_pickle_objects(variant_joined_path)

                env = get_environment(index)
                #print("actions available:", env_actions)
                best_policy = get_best_policy(env, Q, env_actions)
                steps_per_episode_collection.append((steps_per_episode, variant))
                repeated_state_count_collection.append((useless_action_selection_per_episode, variant))
        print_comparison(os.path.join(os.path.join(root, problem), 'steps_per_episode_comparison'), '('+problem+')' + ' Steps to complete each episode', 'Groups of 20 Episodes', 'Steps', steps_per_episode_collection)
        print_comparison(os.path.join(os.path.join(root, problem), 'same_state_transition_comparison'), '('+problem+')' + ' Transitions between the same state', 'Groups of 20 Episodes', 'Transitions', repeated_state_count_collection)
        print()
    
