import sys
import json
from os import path
import random
import re

import numpy as np

import tensorflow as tf
from tensorflow.keras import layers

import CharacterData as cd
import MLModels as models
import Engine as engine

def arr_to_str(arr):
    temp = ""
    for s in arr:
        temp += s + ", "
    temp = temp.rstrip(", ")
    return temp


def rand_from_arr(arr, n):
    return random.sample(arr, n)

def long_name(s):
    long_names = {
        'str': 'strength',
        'dex': 'dexterity',
        'con': 'constitution',
        'int': 'intelligence',
        'wis': 'wisdom',
        'cha': 'charisma'
    }
    return long_names[s]

def to_score(n):
    return int(n / 2 - 5)


def to_long_name(s):
    names = {
        "str": "strength",
        "dex": "dexterity",
        "con":"constitution",
        "int": "intelligence",
        "wis": "wisdom",
        "cha": "charisma"
    }

    return names[s]


def generate_inventory(cls, background, race, str, dex, con, cls_traits, weapon_types):
    sample = {
        'cls' : cls,
        "background": background,
        "race": race,
        "str": str,
        "dex": dex, 
        "con": con
    }

    item_model = engine.get_item_model()

    pred_from_model = models.get_cat_prediction(item_model, sample)[0]

    fpath = path.abspath(path.join(path.abspath(''), "..", "game_data", "saved_character_data_lists.json"))
    data_list = cd.DataLists()
    data_list.load_from_file(fpath)

    equipt = []
    for a in cls_traits[cls]['starting_inv']:
        if len(a) == 1 and a[0] not in weapon_types.keys():
            equipt.append(a[0])

        else:
            init_len = len(a)        
            count = 1
            for n, i in enumerate(a):
                if i in weapon_types.keys():
                    a = a + weapon_types[i]
                    a.remove(i)
                elif i[-1].isdigit():
                    count = int(re.match('.*?([0-9]+)$', i).group(1))
                    a[n] = (i.rstrip('1234567890* '))

            idxs = []
            for i in a:
                idxs.append(pred_from_model[data_list.inventory_list.index(i)])

            max_pred = idxs.index(max(idxs))

            if (max_pred < init_len or a[max_pred] == 'javelins') and count > 1:
                item = a[max_pred]
                item += " *{}".format(count)

                equipt.append(item)
            else:
                equipt.append(a[max_pred])

    del item_model
            
    return equipt
        


def fill_in_character(c, level):
    fpath = path.abspath(path.join(path.abspath(''), "..", "game_data", "class_traits.json"))
    f = open(fpath, 'r', encoding="utf-8")
    cls_traits = json.load(f)
    f.close()


    c['name'] = ''
    c['clss'] = c['cls']


    c['level'] = level
    c['experience_points'] = 0
    c['inspiration'] = 0

    c['abilities'] = {
        "strength": c['str'],
        "dexterity": c['dex'],
        "constitution": c['con'],
        "intelligence": c['int'],
        "wisdom": c['wis'],
        "charisma": c['cha']
    }

    c['hit_dice'] = cls_traits[c['cls']]["hit dice"]
    c['max_hp'] = c['hit_dice']

    if level > 1:
        for _ in range(level - 1):
            # level scaling
            modifier = 1.039
            skipped = []
            num_to_redo = 0
            for i in c['abilities']:
                new_val = int(round(float(c['abilities'][i]) * modifier))
                if new_val == c['abilities'][i]:
                    skipped.append(i)
                else:
                    c['abilities'][i] = new_val
                if c['abilities'][i] > 20:
                    c['abilities'][i] = 20
                    modifier += 0.006
                    num_to_redo += 1
            if num_to_redo > 0 and num_to_redo < 6:
                for n in range(num_to_redo):
                    if n < len(skipped):
                        new_val = int(round(float(c['abilities'][skipped[n]]) * modifier))
                        c['abilities'][skipped[n]] = new_val

            c['max_hp'] += random.randint(1, c['hit_dice']) + c['abilities']['constitution']

    c['proficiency_bonus'] = int(2 + ((level - 1)/4))
    c['passive_wisdom'] = 0

    c['armor_class'] = 10 + to_score(c['abilities']["dexterity"])
    c['initiative'] = to_score(c['abilities']["dexterity"])

    c['cur_hp'] = c['max_hp']
    c['temp_hp'] = 0

    c['death_save_success'] = 0
    c['death_save_failure'] = 0


    rf = open(path.abspath(path.join(path.abspath(''), "..", "game_data", "fandom_racial_features.json")), "r", encoding="utf-8")
    race_traits = json.load(rf)
    rf.close()

    c['speed'] = 30
    c['height'] = "6 ft"
    c['weight'] = "180 lbs"

    for r, val in race_traits.items():
        if r == c['race'].title():
            c['speed'] = val['Speed']
            c['height'] = val['Size']['Height']
            c['weight'] = val['Size']['Weight']
            break
        elif 'Subclasses' in list(val.keys()):
            if c['race'].title() in val['Subclasses']:
                c['speed'] = val['Speed']
                c['height'] = val['Size']['Height']
                c['weight'] = val['Size']['Weight']
                break


    del race_traits


    c['age'] = random.randint(18, 80)
    c['eyes'] = 'brown'

    c['traits'] = ''
    c['ideals'] = ''
    c['bonds'] = ''
    c['flaws'] = ''
    c['backstory'] = ''
    c['dark_gifts'] = ''
    c['features'] = ''
    c['allies'] = ''
    c['treasure'] = ''
    c['notes'] = ''

    
    rf = open(path.abspath(path.join(path.abspath(''), "..", "game_data", "abilities_by_race.json")), "r", encoding="utf-8")
    race_abil = json.load(rf)
    rf.close()

    c['features_and_traits'] = arr_to_str([s.title() for s in race_abil[c['race']] + cls_traits[c['cls']]['features']])

    del race_abil

    c['other_proficiencies_skills'] = arr_to_str(cls_traits[c['cls']]['proficiencies'])

    weapon_types = {
        "simple weapon": ['dagger', 'javelins', 'light hammer', 'mace', 'quarterstaff', 'light crossbow', 'dart', 'shortbow'],
        "simple melee weapon": ['dagger', 'javelins', 'light hammer', 'mace', 'quarterstaff'],
        "martial weapon": ['battleaxe', 'longsword', 'rapier', 'shortsword', 'blowgun', 'heavy crossbow', 'hand crossbow', 'longbow', "handaxe"],
        "martial melee weapon": ['battleaxe', 'longsword', 'rapier', 'shortsword', "handaxe"],
        "musical instrument": ['lute', 'tiny banjo']
    }

    c['equipment'] = generate_inventory(c['cls'], c['background'], c['race'], c['str'], c['dex'], c['con'], cls_traits, weapon_types)

    atks = []
    for a in c['equipment']:
        b = str(re.sub(r'\d+', '', a)) 
        for wep in weapon_types.values():
            if b in wep and b not in atks: 
                atks.append(b)

    c['attacks'] = arr_to_str(atks)

    c['saving'] = {
        "strength": False,
        "dexterity": False,
        "constitution": False,
        "intelligence": False,
        "wisdom": False,
        "charisma": False
    }

    if 'str' in cls_traits[c['cls']]['saving_throws']:
        c['saving']['strength'] = True
    if 'dex' in cls_traits[c['cls']]['saving_throws']:
        c['saving']['dexterity'] = True
    if 'con' in cls_traits[c['cls']]['saving_throws']:
        c['saving']['constitution'] = True
    if 'int' in cls_traits[c['cls']]['saving_throws']:
        c['saving']['intelligence'] = True
    if 'wis' in cls_traits[c['cls']]['saving_throws']:
        c['saving']['wisdom'] = True
    if 'cha' in cls_traits[c['cls']]['saving_throws']:
        c['saving']['charisma'] = True

    c["skills"] = {
        "acrobatics": False,
        "animal_handling": False,
        "arcana": False,
        "athletics": False,
        "deception": False,
        "history": False,
        "insight": False,
        "intimidation": False,
        "investigation": False,
        "medicine": False,
        "nature": False,
        "perception": False,
        "performance": False,
        "persuasion": False,
        "religion": False,
        "sleight_of_hand": False,
        "stealth": False,
        "survival": False
    }

    temp = rand_from_arr(cls_traits[c['cls']]['skills'], cls_traits[c['cls']]['num_skills'])
    sks = [s.replace(" ", "_").lower() for s in temp]
    for s in sks:
        c['skills'][s] = True

    c['spells'] = {
        "spellcast_ability": long_name(cls_traits[c['cls']]["spellcasting_mod"]),
        "spell_save_dc": 8 + to_score(c["abilities"][to_long_name(cls_traits[c['cls']]["spellcasting_mod"])]) + c['proficiency_bonus'],
        "spell_attack_bonus": to_score(c["abilities"][to_long_name(cls_traits[c['cls']]["spellcasting_mod"])]) + c['proficiency_bonus'],
        "by_level": []        
    }


    max_n = max(cls_traits[c['cls']]["spell_slots"])

    if max_n > 0: 
        rf = open(path.abspath(path.join(path.abspath(''), "..", "game_data", "wikidot_all_spells.json")), "r", encoding="utf-8")
        all_spells = json.load(rf)
        rf.close()
        all_spells = all_spells[c['cls'].title()]

        rf = open(path.abspath(path.join(path.abspath(''), "..", "game_data", "roll_20_all_spells.json")), "r", encoding="utf-8")
        roll20_spells = json.load(rf)
        rf.close()
        roll20_spells = set(roll20_spells.keys())
        roll20_spells.remove("Eldritch Blast")
        
    for idx, n in enumerate(cls_traits[c['cls']]["spell_slots"]):
        slot = {
            "slots": n,
            "spells": []
        }
        if n > 0:
            lvl = "Level " + str(int(idx))
            if lvl == "Level 0":
                lvl = "Cantrip"
                if c['cls'] == 'warlock':
                    sp = {
                        "name": "Eldritch Blast",
                        "charges": 5
                    }
                    slot["spells"].append(sp)

            spell_list = list(all_spells[lvl].keys())
            spell_list = list(set(spell_list) & set(roll20_spells))
            spells = rand_from_arr(spell_list, n)
            for s in spells:
                sp = {
                    "name": s,
                    "charges": random.randint(1, 5)
                }
                slot["spells"].append(sp)
        c['spells']['by_level'].append(slot)

    # level x skills, only granted by gm
    c['spells']['by_level'].append({"slots": 0, "spells": []})

    del c['cls']

    del c['str']
    del c['dex']
    del c['con']
    del c['int']
    del c['wis']
    del c['cha']


    return c



def generate_character(cls, alignment=None, race='', level=1):
    fpath = path.abspath(path.join(path.abspath(''), "..", "game_data", "saved_character_data_lists.json"))
    dl = cd.DataLists()
    dl.load_from_file(fpath)
    align_model, race_model, background_model = engine.get_classifier_models()

    rf = open(path.abspath(path.join(path.abspath(''), "..", "game_data", "abilities_by_race.json")), "r", encoding="utf-8")
    race_traits = json.load(rf)
    rf.close()

    character = {}

    if alignment:
        if isinstance(alignment, int):
            alignment = dl.alignment_list[alignment]
        character = {
            'cls': cls,
            'alignment': alignment
        }
        
        del align_model

    else:
        character = {
            'cls': cls
        }

        align_pred = models.get_cat_prediction(align_model, character)
        # print(align_pred)
        del align_model

        character['alignment'] = dl.alignment_list[(int(np.argmax(align_pred)))]
    
    if race:
        character['race'] = race
        del race_model
    else:
        race_pred = models.get_cat_prediction(race_model, character)
        del race_model
        # print(race_pred)
        race_pred = list(race_pred[0])
        max_val = max(list(race_pred))
        max_idx = list(race_pred).index(max_val)
        character['race'] = str(dl.race_list[max_idx])
        while True:
            if character['race'] in race_traits:
                break
            if max_val < 0.0:
                break
            race_pred[max_idx] = -1.0
            max_val = max(list(race_pred))
            max_idx = list(race_pred).index(max_val)
            character['race'] = dl.race_list[max_idx]

    bg_pred = models.get_cat_prediction(background_model, character)
    del background_model
    # print(bg_pred)

    character['background'] = dl.background_list[(int(np.argmax(bg_pred)))]

    attr_models, col_names = engine.get_attr_models()
    attr_preds = models.get_all_attr_predictions(attr_models, character, col_names)
    del attr_models

    character['str'] = attr_preds[0]
    character['dex'] = attr_preds[1]
    character['con'] = attr_preds[2]
    character['int'] = attr_preds[3]
    character['wis'] = attr_preds[4]
    character['cha'] = attr_preds[5]

    character['alignment'] = int(dl.alignment_list.index(character['alignment']))

    del dl
    del race_traits

    character = fill_in_character(character, level)

    return character
