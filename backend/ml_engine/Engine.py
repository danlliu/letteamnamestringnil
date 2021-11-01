import json
from os import path
from os.path import exists

import pandas as pd
from sklearn.preprocessing import MultiLabelBinarizer

import tensorflow as tf

import GameData as gd
import CharacterData as cd


game_data = gd.GameData()
data_list = cd.DataLists()


def init_data(load_anyway=False, save_data=True):
    basepath = path.abspath('')
    fpath = path.abspath(path.join(basepath, "..", "game_data", "saved_character_data_lists.json"))
    if exists(fpath) and not load_anyway:
        print("Loading Data List from file... ", end="", flush=True)
        data_list.load_from_file(fpath)
        print("Success")
    else:
        print("Loading Data List from character sheets...")
        sheet_num = 0
        while(True):
            char_path = path.abspath(path.join(basepath, "..", "training_data", "partially_cleaned", "kassoon_out_" + str(sheet_num) + ".json"))
            if not exists(char_path):
                break
            if sheet_num % 10 == 0:
                print(sheet_num, end=" ", flush=True)
            char_data = cd.read_character_json(char_path)
            data_list.load_from_char_data(char_data)
            sheet_num += 1

        if sheet_num == 0:
            print("Unable to load data. Aborting.")
            exit(1)

        print("")
        print("Data Loaded Successfully")
        if save_data:
            print("Saving data to file... ", end="", flush=True)
            data_list.save_to_file(fpath)
            print("Success")
        

def create_dataframe():
    print("Loading Character Data... ", end="", flush=True)
    basepath = path.abspath('')
    sheet_num = 0
    char_data_arr = []
    while(True):
        char_path = path.abspath(path.join(basepath, "..", "training_data", "partially_cleaned", "kassoon_out_" + str(sheet_num) + ".json"))
        if not exists(char_path):
            break
        if sheet_num % 10 == 0:
            print(sheet_num, end=" ", flush=True)
        char_data_arr.extend(cd.read_character_json(char_path))
        sheet_num += 1

    frame = pd.DataFrame.from_records([c.to_dict() for c in char_data_arr])
    print("Success")
    return frame


def encode_for_training(df):
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
    
    print("Success")
    return df


def run_engine(reload_data = False):
    init_data(load_anyway=reload_data)
    df = create_dataframe()
    df = encode_for_training(df)
    print(list(df.columns))
    display(df)


if __name__ == "__main__":
    run_engine()
