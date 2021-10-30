import json
from os import path
from os.path import exists

import numpy as np

import tensorflow as tf

import GameData as gd
import CharacterData as cd


game_data = gd.GameData()
data_list = cd.DataLists()


def init_data(load_anyway=True, save_data=True):
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
        

def run_engine():
    init_data()


if __name__ == "__main__":
    run_engine()
