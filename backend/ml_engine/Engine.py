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

import tensorflow as tf
from tensorflow.keras import layers

import GameData as gd
import CharacterData as cd
import CharacterGeneration as gen
import MLModels as models


# GLOBALS 

verbose = False
reload_char_data = False
debug_mode = False
overwrite_data = False
testing_mode = False

game_data = gd.GameData()
data_list = cd.DataLists()


def init_data():
    basepath = path.abspath(path.join(__file__, ".."))
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
                    if verbose:
                        print(str(row[col]) + " float")
                        print(row)
                    df.drop([i])

        df = df[df['background'].notna()]

        df.loc[df['alignment'] == "chaoic good", 'alignment'] = "chaotic good"
        df.loc[df['alignment'] == "true neutral", 'alignment'] = "neutral"
        df.loc[df['alignment'] == 'lawful neurtral', 'alignment'] = "lawful neutral"
        df.loc[df['cls'] == 'tieflign', 'cls'] = 'tiefling'
        df.loc[df['cls'] == 'kolbold', 'cls'] = 'kobold'
        df.loc[df['cls'] == 'ghallanda halfling', 'cls'] = 'ghostwise halfling'
        df.loc[df['cls'] == "jorasco halfling", 'cls'] = 'lightfoot halfling'
        df.loc[df['cls'] == 'cannith human', 'cls'] = 'human'
        df.loc[df['cls'] == 'orien human', 'cls'] = 'human'
        df.loc[df['cls'] == 'variant human', 'cls'] = 'human'
        df.loc[df['cls'] == 'half orc', 'cls'] = 'half-orc'
        df.loc[df['cls'] == 'finding half-orc', 'cls']  = 'half-orc'
        df.loc[df['cls'] == 'lyrandar half-elf', 'cls'] = 'half-elf'
        df.loc[df['cls'] == 'medani half-elf', 'cls'] = 'half-elf'
        df.loc[df['cls'] == 'eladrin elf', 'cls'] = 'high elf'

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
                print(df.head())

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


def get_models():
    basepath = path.abspath(path.join(__file__, ".."))
    align_model = tf.keras.models.load_model(path.join(basepath, 'saved_models/align_model'))
    race_model = tf.keras.models.load_model(path.join(basepath, 'saved_models/race_model'))
    background_model = tf.keras.models.load_model(path.join(basepath, 'saved_models/background_model'))

    str_model = tf.keras.models.load_model(path.join(basepath, 'saved_models/str_model'))
    dex_model = tf.keras.models.load_model(path.join(basepath, 'saved_models/dex_model'))
    con_model = tf.keras.models.load_model(path.join(basepath, 'saved_models/con_model'))
    int_model = tf.keras.models.load_model(path.join(basepath, 'saved_models/int_model'))
    wis_model = tf.keras.models.load_model(path.join(basepath, 'saved_models/wis_model'))
    cha_model = tf.keras.models.load_model(path.join(basepath, 'saved_models/cha_model'))

    attr_models = [str_model, dex_model, con_model, int_model, wis_model, cha_model]

    with open(path.join(basepath, "saved_models/model_col_names.json"), "r", encoding='utf-8') as f:
        col_names = json.load(f)

    return align_model, race_model, background_model, attr_models, col_names


## -- CHARACTER GENERATOR -- ##
# moved to CharacterGeneration.py

def generate_character(cls, alignment=''):
    return gen.generate_character(cls, alignment)


## -- TRAINING ENGINE -- ##

def run_engine(args = sys.argv[1:]):
    global verbose
    global reload_char_data
    global debug_mode
    global overwrite_data
    global testing_mode
    reload_dataframe = False
    retrain_model = False

    help_msg = """
    --help, -h : Print this help message
    --verbose, -v : Print verbose output
    --debug, -d : Debug output
    --testing : Additional tests run
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
    if "--train" in args or "-t" in args:
        retrain_model = True
    if "--testing" in args:
        testing_mode = True
        debug_mode = True

    if debug_mode:
        print("Arg Values:")
        print("debug: True")
        print("verbose: " + str(verbose))
        print("reload character data: " + str(reload_char_data))
        print("overwrite: " + str(overwrite_data))


    init_data()
    keras_mode = True
    df = load_dataframe(keras_mode, reload_dataframe)
    
    align_model = None
    race_model = None
    background_model = None
    attr_models = None
    col_names = None

    if retrain_model:
        print()
        print("Training Models...")
        print()

        align_model, race_model, background_model, attr_models, col_names = models.train_models(df, data_list, verbose, debug_mode, testing_mode)

        align_model.save('saved_models/align_model')
        race_model.save('saved_models/race_model')
        background_model.save('saved_models/background_model')
        attr_models[0].save('saved_models/str_model')
        attr_models[1].save('saved_models/dex_model')
        attr_models[2].save('saved_models/con_model')
        attr_models[3].save('saved_models/int_model')
        attr_models[4].save('saved_models/wis_model')
        attr_models[5].save('saved_models/cha_model')

        with open("saved_models/model_col_names.json", "w", encoding='utf-8') as f:
            json.dump(col_names, f, ensure_ascii=False)

    else:
        align_model, race_model, background_model, attr_models, col_names = get_models()


    


if __name__ == "__main__":
    run_engine()
