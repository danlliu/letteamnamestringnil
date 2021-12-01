import sys
import json
from os import path

import numpy as np

import tensorflow as tf
from tensorflow.keras import layers

import CharacterData as cd
import MLModels as models
import Engine as engine



def fill_in_character(c):
    fpath = path.abspath(path.join(path.abspath(''), "..", "game_data", "saved_character_data_lists.json"))
    f = open(fpath, 'r', encoding="utf-8")
    cls_traits = json.load(f)
    f.close()







def generate_character(cls, alignment):
    fpath = path.abspath(path.join(path.abspath(''), "..", "game_data", "saved_character_data_lists.json"))
    dl = cd.DataLists()
    dl.load_from_file(fpath)
    align_model, race_model, background_model, attr_models, col_names = engine.get_models()

    character = {}

    if alignment:
        if isinstance(alignment, int):
            alignment = dl.alignment_list[(int(np.argmax(alignment)))]
        character = {
            'cls': cls,
            'alignment': alignment
        }

    else:
        character = {
            'cls': cls
        }

        align_pred = models.get_cat_prediction(align_model, character)
        # print(align_pred)

        character['alignment'] = dl.alignment_list[(int(np.argmax(align_pred)))]
    
    race_pred = models.get_cat_prediction(race_model, character)
    # print(race_pred)
    character['race'] = dl.race_list[(int(np.argmax(race_pred)))]

    bg_pred = models.get_cat_prediction(background_model, character)
    # print(bg_pred)
    character['background'] = dl.background_list[(int(np.argmax(bg_pred)))]


    attr_preds = models.get_all_attr_predictions(attr_models, character, col_names)

    character['str'] = attr_preds[0]
    character['dex'] = attr_preds[1]
    character['con'] = attr_preds[2]
    character['int'] = attr_preds[3]
    character['wis'] = attr_preds[4]
    character['cha'] = attr_preds[5]

    character['alignment'] = int(dl.alignment_list.index(character['alignment']))

    return character
