import sys
from os import path
from os.path import exists

import pandas as pd
from sklearn.preprocessing import MultiLabelBinarizer
from tqdm.auto import tqdm
from IPython.display import display

import tensorflow as tf

import GameData as gd
import CharacterData as cd

# GLOBALS 

verbose = False
reload_data = False

game_data = gd.GameData()
data_list = cd.DataLists()


def init_data(save_data=True):
    basepath = path.abspath('')
    fpath = path.abspath(path.join(basepath, "..", "game_data", "saved_character_data_lists.json"))
    if exists(fpath) and not reload_data:
        if verbose:
            print("Loading Data List from file... ", end="", flush=True)
        data_list.load_from_file(fpath)
        if verbose:
            print("Success")
    else:
        if verbose:
            print("Loading Data List from character sheets...")
        num_sheets = 0
        while(True):
            char_path = path.abspath(path.join(basepath, "..", "training_data", "partially_cleaned", "kassoon_out_" + str(num_sheets) + ".json"))
            if not exists(char_path):
                break
            num_sheets += 1
   
        for n in (tqdm(range(num_sheets)) if verbose else range(num_sheets)):
            char_path = path.abspath(path.join(basepath, "..", "training_data", "partially_cleaned", "kassoon_out_" + str(n) + ".json"))
            if not exists(char_path):
                break
            char_data = cd.read_character_json(char_path)
            data_list.load_from_char_data(char_data)

        if num_sheets == 0:
            print("Unable to load data. Aborting.")
            exit(1)

        if verbose:
            print("Data Loaded Successfully")
        if save_data:
            if verbose:
                print("")
                print("Saving data to file... ", end="", flush=True)
            data_list.save_to_file(fpath)
            if verbose:
                print("Success")
        

def create_dataframe():
    if verbose:
        print("")
        print("Loading Character Data... ")
    basepath = path.abspath('')
    char_data_arr = []

    num_sheets = 0
    while(True):
        char_path = path.abspath(path.join(basepath, "..", "training_data", "partially_cleaned", "kassoon_out_" + str(num_sheets) + ".json"))
        if not exists(char_path):
            break
        num_sheets += 1
    
    for n in (tqdm(range(num_sheets)) if verbose else range(num_sheets)):
        char_path = path.abspath(path.join(basepath, "..", "training_data", "partially_cleaned", "kassoon_out_" + str(n) + ".json"))
        if not exists(char_path):
            break
        char_data_arr.extend(cd.read_character_json(char_path))


    frame = pd.DataFrame.from_records([c.to_dict() for c in char_data_arr])
    if verbose:
        print("Success")
    return frame


def encode_for_training(df):
    if verbose:
        print("")
        print("Encoding Data... ", end="", flush=True)
    mlb = MultiLabelBinarizer()
    excluded_labels = ["skills"]
    one_hot_categorical = ["cls", "background", "race", "alignment"]
    for tag in one_hot_categorical:
        temp = pd.get_dummies(df[tag], prefix=tag)
        df = pd.concat([df, temp], axis=1)
        df.pop(tag)
    one_hot_multilabels = ["proficient_skills", "proficient_saves", "attacks", "features", "inventory", "proficient_items", "languages"] 
    for tag in excluded_labels:
        df.pop(tag)
    for tag in one_hot_multilabels:
        temp = pd.DataFrame(mlb.fit_transform(df[tag]),columns=mlb.classes_, index=df.index)
        temp = temp.add_prefix(tag + "_")
        df = pd.concat([df, temp], axis=1)
        df.pop(tag)
    
    if verbose:
        print("Success")
    return df


def run_engine():
    args = sys.argv[1:]
    global verbose
    global reload_data
    if "--verbose" in args or "-v" in args:
        verbose = True
    if "--reload-data" in args or "-r" in args:
        reload_data = True


    init_data()
    df = create_dataframe()
    df = encode_for_training(df)
    display(df)


if __name__ == "__main__":
    run_engine()
