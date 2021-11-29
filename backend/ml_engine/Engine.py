import sys
import ast
from os import path
from os.path import exists
import json
from pprint import pprint


import pandas as pd
import numpy as np

from sklearn.preprocessing import MultiLabelBinarizer
from tqdm.auto import tqdm
from IPython.display import display

import tensorflow as tf
from tensorflow.keras import layers

import GameData as gd
import CharacterData as cd
import MLModels as models


# GLOBALS 

verbose = False
reload_char_data = False
debug_mode = False
overwrite_data = False

game_data = gd.GameData()
data_list = cd.DataLists()


def init_data():
    basepath = path.abspath('')
    fpath = path.abspath(path.join(basepath, "..", "game_data", "saved_character_data_lists.json"))
    if exists(fpath) and not reload_char_data:
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
        if overwrite_data:
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
    one_hot_multilabels = ["proficient_skills", "proficient_saves"] 
    for tag in excluded_labels:
        df.pop(tag)
    for tag in one_hot_multilabels:
        temp = pd.DataFrame(mlb.fit_transform(df[tag]),columns=mlb.classes_, index=df.index)
        temp = temp.add_prefix(tag + "_")
        df = pd.concat([df, temp], axis=1)
        df.pop(tag)
    crossed_labels = ["attacks", "features", "inventory", "proficient_items", "languages"]
    crossed_new_tags = []
    for tag in crossed_labels:
        temp = pd.DataFrame(mlb.fit_transform(df[tag]),columns=mlb.classes_, index=df.index)
        temp = temp.add_prefix(tag + "_")
        new_tags = list(temp.columns)
        crossed_new_tags.append(new_tags)
        df = pd.concat([df, temp], axis=1)
        df.pop(tag)
    
    if verbose:
        print("Success")
    return df, crossed_new_tags


def keras_encode(df):
    if verbose:
        print("")
        print("Keras Encoding Data... ", end="", flush=True)


def load_dataframe(keras_mode, reload_dataframe):
    df = None
    if keras_mode:
        basepath = path.abspath('')
        keras_df_outfile = path.abspath(path.join(basepath, "..", "training_data", "fully_cleaned", "keras_training_dataframe.csv"))
        df = None
        if reload_dataframe:
            df = create_dataframe()

            excluded_labels = ["skills"]
            for tag in excluded_labels:
                df.pop(tag)

            if verbose:
                print("Saving keras dataframe to file... ", end="", flush=True)
            df.to_csv(keras_df_outfile, sep="|", quotechar='"')
            if verbose:
                print("Success")
        else:
            if verbose:
                print("Loading keras dataframe from file... ", end="", flush=True)
            df = pd.read_csv(keras_df_outfile, sep="|", quotechar='"', skipinitialspace=True,
            converters={13:ast.literal_eval, 12:ast.literal_eval, 19:ast.literal_eval, 15:ast.literal_eval,
            16:ast.literal_eval, 17:ast.literal_eval, 18:ast.literal_eval})

            df = df.drop(columns=["Unnamed: 0"])

            if verbose:
                print("Success")

        if verbose:
            print("Final cleaning...", flush=True)

        # TODO: figure this bs out
        list_cols = ["proficient_skills", "proficient_saves", "attacks", "features", "inventory", "proficient_items", "languages"]
        for tag in list_cols:
            # df[tag] = [np.asarray(l).astype(np.str) for l in df[tag]]
            df.pop(tag)

        for i, row in df.iterrows():
            for col in df.columns:
                if isinstance(row[col], float):
                    print(str(row[col]) + " float")
                    print(row)
                    df.drop([i])

        str_cols = ["cls", "background", "race", "alignment"]
        for tag in str_cols:
            #df[tag] = [np.str(i) for i in df[tag]]
            df[tag] = df[tag].astype('|S')

        if verbose:
            print("Complete")
            print(df.dtypes)

    else:
        basepath = path.abspath('')
        df_outfile = path.abspath(path.join(basepath, "..", "training_data", "fully_cleaned", "training_dataframe.csv"))
        cross_outfile = path.abspath(path.join(basepath, "..", "training_data", "fully_cleaned", "crossed_column_labels.json"))
        
        if reload_dataframe:
            df = create_dataframe()
            df, crossed_tags = encode_for_training(df)
            if debug_mode:
                print("Crossed Column Labels:")
                print(crossed_tags)
                print()
                print("Dataframe:")
                display(df)

            if verbose:
                print("Saving dataframe to file... ", end="", flush=True)
            df.to_csv(df_outfile, sep=",", encoding="utf-8")
            with open(cross_outfile, "w", encoding="utf-8") as outfile:
                json.dump(crossed_tags, outfile, ensure_ascii=False)
            if verbose:
                print("Success")
        else:
            if verbose:
                print("Loading dataframe from file... ", end="", flush=True)
            df = pd.read_csv(df_outfile, sep=",", encoding="utf-8")
            temp = open(cross_outfile, encoding="utf-8")
            crossed_tags = json.load(temp)
            temp.close()
            if verbose:
                print("Success")

    return df


def run_engine(args = sys.argv[1:]):
    global verbose
    global reload_char_data
    global debug_mode
    global overwrite_data
    reload_dataframe = False

    help_msg = """
    --help, -h : Print this help message
    --verbose, -v : Print verbose output
    --debug, -d : 
    --reload-char-data : Reload character data from files
    --overwrite, -o : Overwrite existing character data
    --reload-dataframe, -r : Overwrite the existing input dataframe
    """

    if "--help" in args or "-h" in args:
        print(help_msg)
        return
    if "--verbose" in args or "-v" in args:
        verbose = True
    if "--reload-char-data" in args:
        reload_char_data = True
    if "--overwrite" in args or "-o" in args:
        overwrite_data = True
    if "--debug" in args or "-d" in args:
        debug_mode = True
        verbose = True
    if "--reload-dataframe"in args or "-r" in args:
        reload_dataframe = True

    if debug_mode:
        print("Arg Values:")
        print("debug: True")
        print("verbose: " + str(verbose))
        print("reload character data: " + str(reload_char_data))
        print("overwrite: " + str(overwrite_data))


    init_data()
    keras_mode = True
    df = load_dataframe(keras_mode, reload_dataframe)
    
    if keras_mode:
        print()
        print("STARTING KERAS ENGINE:")
        print()

        models.train_models(df, data_list, verbose, debug_mode)

    


if __name__ == "__main__":
    run_engine()
