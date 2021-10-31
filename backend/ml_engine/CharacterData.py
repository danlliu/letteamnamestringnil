import json
import re
import string
from os import path


class CharacterData:
    cls = ""
    level = 0
    background = ""
    race = ""
    alignment = 0
    attrs = [] # [str, dex, con, int, wis, cha]
    ac = 0
    initiative = 0
    proficiency = 0
    perception = 0
    hp = 0
    skills = {}
    proficient_skills = []
    proficient_saves = []
    attacks = []
    features = []
    inventory = []
    gp = 0
    proficient_items = []
    languages = []

    def __init__(self, char):
        self.cls = char["class"]
        self.level = char["level"]
        self.background = char["background"]
        if self.background == "mercenary veterann":
            self.background = "mercenary veteran"

        self.race = char["race"]
        if "(" in self.race:
            self.race = re.sub(r"\(.*\)","", self.race)
        self.race = self.race.strip()

        self.alignment = char["alignment"]
        if self.alignment == "neutral neutral":
            self.alignment = "neutral"

        self.attrs = []
        for a in list(char["attributes"].items())[:6]:
            self.attrs.append(int(a[1]["true_val"]))

        self.ac = char["attributes"]["armor_class"]
        self.initiative = char["attributes"]["initiative"]
        self.proficiency = char["attributes"]["proficiency"]
        self.perception = char["attributes"]["perception"]
        self.hp = char["attributes"]["hit_points"]
        self.skills = char["skills"]
        self.proficient_skills = char["proficient_skills"]
        self.proficient_saves = char["proficient_saves"]
        
        attacks = []
        for a in char["attacks"]:
            attacks.append(a["name"])

        features = char["features"]
        
        inventory = []
        for i in char["inventory"]:
            s = string.capwords(i["name"])
            inventory.append(s)

        self.gp = char["gp"]
        proficient_items = char["proficiencies"]
        languages = char["languages"]
        
        # Additional Cleaning
        self.attacks = clean_list(attacks)
        self.features = clean_list(features)
        self.inventory = clean_list(inventory)
        self.proficient_items = clean_list(proficient_items, is_prof=True)
        self.languages = clean_list(languages)

        self.proficient_skills.sort()
        self.attacks.sort()
        self.features.sort()
        self.inventory.sort()
        self.proficient_items.sort()
        self.languages.sort()


    def to_dict(self):
        char_dict = vars(self)
        char_dict['str'] = self.attrs[0]
        char_dict['dex'] = self.attrs[1]   
        char_dict['con'] = self.attrs[2]   
        char_dict['int'] = self.attrs[3]   
        char_dict['wis'] = self.attrs[4]   
        char_dict['cha'] = self.attrs[5]       
        char_dict.pop('attrs')
        return char_dict


class DataLists:
    attr_max = {} 
    attr_min = {}
    background_list = []
    skill_list = []
    feature_list = []
    attack_list = []
    inventory_list = []
    item_proficiency_list = []
    language_list = []

    def __init__(self):
        self.attr_max = {
            "str": 0,
            "dex": 0,
            "con": 0,
            "int": 0,
            "wis": 0,
            "cha": 0,
            "ac": 0,
            "initiative": 0,
            "proficiency": 0,
            "perception": 0
        }

        self.attr_min = {
            "str": 99,
            "dex": 99,
            "con": 99,
            "int": 99,
            "wis": 99,
            "cha": 99,
            "ac": 99,
            "initiative": 99,
            "proficiency": 99,
            "perception": 99
        }

# [str, dex, con, int, wis, cha]

        self.background_list = []
        self.skill_list = []
        self.feature_list = []
        self.attack_list = []
        self.inventory_list = []
        self.item_proficiency_list = []
        self.language_list = []

    def load_from_char_data(self, char_list):
        for c in char_list:
            valid = True
            for v in c.attrs:
                if v > 20: 
                    valid = False
            if c.level == 1 and valid:
                if c.attrs[0] > self.attr_max["str"]:
                    self.attr_max["str"] = c.attrs[0]
                if c.attrs[0] < self.attr_min["str"]:
                    self.attr_min["str"] = c.attrs[0]

                if c.attrs[1] > self.attr_max["dex"]:
                    self.attr_max["dex"] = c.attrs[1]
                if c.attrs[1] < self.attr_min["dex"]:
                    self.attr_min["dex"] = c.attrs[1]

                if c.attrs[2] > self.attr_max["con"]:
                    self.attr_max["con"] = c.attrs[2]
                if c.attrs[2] < self.attr_min["con"]:
                    self.attr_min["con"] = c.attrs[2]

                if c.attrs[3] > self.attr_max["int"]:
                    self.attr_max["int"] = c.attrs[3]
                if c.attrs[3] < self.attr_min["int"]:
                    self.attr_min["int"] = c.attrs[3]

                if c.attrs[4] > self.attr_max["wis"]:
                    self.attr_max["wis"] = c.attrs[4]
                if c.attrs[4] < self.attr_min["wis"]:
                    self.attr_min["wis"] = c.attrs[4]

                if c.attrs[5] > self.attr_max["cha"]:
                    self.attr_max["cha"] = c.attrs[5]
                if c.attrs[5] < self.attr_min["cha"]:
                    self.attr_min["cha"] = c.attrs[5]

                if c.ac > self.attr_max["ac"]:
                    self.attr_max["ac"] = c.ac
                if c.ac < self.attr_min["ac"]:
                    self.attr_min["ac"] = c.ac

                if c.initiative > self.attr_max["initiative"]:
                    self.attr_max["initiative"] = c.initiative
                if c.initiative < self.attr_min["initiative"]:
                    self.attr_min["initiative"] = c.initiative

                if c.proficiency > self.attr_max["proficiency"]:
                    self.attr_max["proficiency"] = c.proficiency
                if c.proficiency < self.attr_min["proficiency"]:
                    self.attr_min["proficiency"] = c.proficiency

                if c.perception > self.attr_max["perception"]:
                    self.attr_max["perception"] = c.perception
                if c.perception < self.attr_min["perception"]:
                    self.attr_min["perception"] = c.perception

            self.background_list.append(c.background)

            for s in list(c.skills.keys()):
                st = validate_string(s)
                self.skill_list.append(st)

            for f in c.features:
                st = validate_string(f)
                self.feature_list.append(st)

            for a in c.attacks:
                st = validate_string(a)
                self.attack_list.append(st)

            for i in c.inventory:    
                st = validate_string(i)
                self.inventory_list.append(st)

            for i in c.proficient_items:
                st = validate_string(i)
                self.item_proficiency_list.append(st)

            for l in c.languages:
                st = validate_string(l)
                self.language_list.append(st)


        self.background_list = list(set(self.background_list))
        self.skill_list = list(set(self.skill_list))
        self.feature_list = list(set(self.feature_list))
        self.attack_list = list(set(self.attack_list))
        self.inventory_list = list(set(self.inventory_list))
        self.item_proficiency_list = list(set(self.item_proficiency_list))
        self.language_list = list(set(self.language_list))

        self.background_list.sort()
        self.skill_list.sort()
        self.feature_list.sort()
        self.attack_list.sort()
        self.inventory_list.sort()
        self.item_proficiency_list.sort()
        self.language_list.sort()

        # Manual cleaning
        self.background_list = remove_banned_strs(self.background_list)
        self.skill_list = remove_banned_strs(self.skill_list)
        self.feature_list = remove_banned_strs(self.feature_list)
        self.attack_list = remove_banned_strs(self.attack_list)
        self.item_proficiency_list = remove_banned_strs(self.item_proficiency_list)
        self.language_list = remove_banned_strs(self.language_list)


    def load_from_file(self, fpath, encoding="utf-8"):
        f = open(fpath, "r", encoding=encoding)
        data = json.load(f)
        f.close()

        self.attr_max = data["attr_max"],
        self.attr_min = data["attr_min"],
        self.background_list = data["background_list"]
        self.skill_list = data["skill_list"]
        self.feature_list = data["feature_list"]
        self.attack_list = data["attack_list"]
        self.inventory_list = data["inventory_list"]
        self.item_proficiency_list = data["item_proficiency_list"]
        self.language_list = data["language_list"]

    
    def save_to_file(self, fpath):
        out_map = {
            "attr_max": self.attr_max,
            "attr_min": self.attr_min,
            "background_list": self.background_list,
            "skill_list": self.skill_list,
            "feature_list": self.feature_list,
            "attack_list": self.attack_list,
            "inventory_list": self.inventory_list,
            "item_proficiency_list": self.item_proficiency_list,
            "language_list": self.language_list
        }

        with open(fpath, "w", encoding='utf-8') as outfile:
            json.dump(out_map, outfile, ensure_ascii=False, indent=4)


def remove_banned_strs(str_list):
    banned_strs = ["", "You Have", "On", "On All", "On Being", "On Me", "Per", "During A", "Bonus To Ac", "Feat", 
                        "It In The Following Ways", "Skill", "Times Per", "To Poison", "Uses", "While The Bladesong Is Active I Have The Following Benefits",
                        "Wood Elf Traits", "You Gain The Following Benefits While You Are Unarmed Or Wielding Only Monk Weapons And You Aren't Wearing Armor Or Wielding A Shield",
                        ",", ".", "/", "Ft", "Ft. Silk Rope", "G", "C", "Being Worn/equipped", "Minuti, La Magia Cessa Di Funzionare Fino Al Termine Di Un Riposo Lungo.",
                        "Letter From A Dead Colleague Posing A Question You Have Not Yet Been Able To Answer",
                        "La Magia Cessa Di Funzionare Fino Al Termine Di Un Riposo Lungo", "Attack Damage Dc", "You Aren't Wearing Armor Or Wielding A Shield",
                        "You Gain The Following Benefits While You Are Unarmed Or Wielding Only Monk Weapons", "Lb", "Lbs", "Minuti", "Determined By Your Patron", 
                        "Across The", 'La Magia Cessa Di Funzionare Fino Al Termine Di Un Riposo Lungo']

    for s in str_list:
        if s in banned_strs:
            str_list.remove(s)

    return str_list



# Manual Cleaning
def validate_string(s, cap=True):
    s = re.sub(r"\(.*\)","", s)
    s = re.sub(r"<.*>", "", s)
    s = s.strip("-()[]}{•:. ")
    if cap:
        s = string.capwords(s)

    if s.startswith("A "):
        s = s[2:]
    if s.startswith("And "):
        s = s[4:]
    if s.startswith("An "):
        s = s[3:]
    if s.startswith("Lb "):
        s = s[3:]
    if s.startswith("Feet of "):
        s = s[8:]
    if s.startswith("Feet "):
        s = s[5:]

    if "Armour" in s:
        s = s.replace("Armour", "Armor")
    if "&amp; " in s:
        s = s.replace("&amp; ", "")

    return s


def expand_string(s, is_prof=False):
    str_map = {
        "Goblinisk And Gnomish": ["Goblinisk", "Gnomish"],
        'All Armor': ["Light Armor", "Medium Armor", "Heavy Armor"],
        'Light/medium Armor': ["Light Armor", "Medium Armor"],
        'Light/medium/heavy Armor': ["Light Armor", "Medium Armor", "Heavy Armor"],
        'All Armor/shields': ["Light Armor", "Medium Armor", "Heavy Armor", "Non-metal Shields", "Shields"],
        'All Simple Weapons': ["Simple Weapons"],
        'All Simple/martial Weapons': ["Simple Weapons", "Martial Weapons"],
        'Simple/martial Weapons': ["Simple Weapons", "Martial Weapons"],
        "Simple And Martial Weapons": ["Simple Weapons", "Martial Weapons"],
        'One Artisan Tool Or Musical Instrument': ["Artisans' Tools", "Musical Instruments"],
        'Hand Axe': ["Handaxe"],
        "Short Sword": ["Shortsword"],
        "Short Swords": ["Shortswords"],
        "Short Bow": ["Shortbow"],
        "Short Bows": ["Shortbows"],
        "Torche": ["Torch"],
        "Leatherarmor": ["Leather Armor"],
        "Weapon : Simple Weapons": ["Simple Weapons"], 
        "Tool : Weaver's Tools": ["Weaver's Tools"],
        "Playing Card Set": ["Playing Cards"],
        "Deck Of Cards": ["Playing Cards"],
        "Deck Of Playing Card": ["Playing Cards"],
        "Deck Of Playing Cards": ["Playing Cards"],
        "Longbow. Shortbow": ["Longbow", "Shortbow"],
        "Quarterstaves": ["Quarterstaffs"],
        "Troll/giant": ["Troll", "Giant"],
        "Token Of Parents": ["Token Of Your Parents"],
        "Token To Remember Your Parents By": ["Token Of Your Parents"],
        "Travelers Clothes": ["Traveler's Clothes"],
        "Set O F Dark Common Clothes": ["Common Clothes"],
        "Set Of Common Clothes": ["Common Clothes"],
        "Set Of Fine Clothes": ["Fine Clothes"],
        "Set Of Traveler's Clothes": ["Traveler's Clothes"],
        "One Set Of Traveller's Clothes": ["Traveler's Clothes"],
        "Pet Mouse - Alberto": ["Pet Mouse"],
        "Javlin": ["Javelins"],
        "Javelin": ["Javelins"],
        "Five Javelins": ["Javelins"],
        "Gold Piece": ["Gold"],
        "Gp": ["Gold"],
        "Arror": ["Arrow"],
        "Arrows. Leather Armor": ["Arrow", "Leather Armor"],
        "Explorers Pack": ["Explorer's Pack"],
        "Great Sword": ["Greatsword"],
        "Great Axe": ["Greataxe"],
        "Long Sword": ["Longsword"],
        "Long Bow": ["Longbow"],
        "Map Of The City You Grew Up In": ["Map Of Your Home City"],
        "Morning Star": ["Morningstar"],
        "Studded Leather Arm": ["Studded Leather Armor"],
        "Thieves Tools": ["Thieves' Tools"],
        "Tinder Box": ["Tinderbox"],
        "War Hammer": ["Warhammer"],
        "Medium": ["Medium Armor"],
        "Light": ["Light Armor"],
        "Heavy": ["Heavy Armor"],
        "Simple": ["Simple Weapons"],
        "Elven": ["Elvish"],
        "Elevish": ["Elvish"],
        "Dwarven": ["Dwarvish"],
        "Draconian": ["Draconic"],
        "Broken Halfling": ["Halfling"],
        "Hempen Rope": ["Hemp Rope"],
        "Crossbow Bolts": ["Bolt"],
        "Crossbow Bolt": ["Bolt"],
        "Chain Shirt": ["Chain Mail"],
        "Longsword +1": ["Longsword"],
        "Class: Oath Of Redemption": ["Oath Of Redemption"],
        "Cantrips": ["Cantrip"],
        "Dark Vision": ["Darkvision"],
        "Flutes": ["Flute"]
    }

    prof_map = {
        "Longsword": ["Longswords"],
        "Quarterstaff": ["Quarterstaffs"],
        "Shortsword": ["Shortswords"],
        "Light Crossbow": ["Light Crossbows"],
        "Hand Crossbow": ["Hand Crossbows"],
        "Sling": ["Slings"],
        "Lute": ["Lutes"],
        "Shortbow": ["Shortbows"],
        "Shield": ["Shields"],
        "Rapier": ["Rapiers"],
        "Three Musical Instruments": ["Musical Instruments"]
    }

    # 'All Simple Weapons': ["Clubs", "Daggers", "Great-Clubs", "Hand Axes", "Javelins", "Light Hammers", "Maces", "Quarterstaffs", "Sickles", "Spears"],

    if s in str_map:
        return str_map[s]
    elif is_prof and s in prof_map:
        return prof_map[s]
    else:
        return []

    
def clean_list(lst, cap=True, is_prof=False, reloop=True):
    tmp = []
    to_remove = []
    for idx, s in enumerate(lst):
        n = validate_string(s, cap=cap)
        exp = expand_string(n, is_prof=is_prof)
        
        if exp:
            to_remove.append(s)
            to_remove.append(n)
            tmp.extend(exp)
        else:
            exp = split_strings(n)
            if exp:
                to_remove.append(s)
                to_remove.append(n)
                tmp.extend(exp)
            else:
                lst[idx] = n

    if tmp:
        lst.extend(tmp)
    lst = list(set(lst))

    lst = remove_banned_strs(lst)

    if '' in lst:
        lst.remove('')

    for i in to_remove:
        if i in lst:
            lst.remove(i)

    if reloop:
        return clean_list(lst, cap=cap, is_prof=is_prof, reloop=False)
    else:
        return lst


def split_strings(s):
    arr = []
    if "," in s:
        arr = s.split(",")
    elif "And" in s:
        arr = s.split("And")

    for st in arr:
        validate_string(st)

    return arr
    

def read_character_json(fpath, encoding="utf-8"):
    f = open(fpath, "r", encoding=encoding)
    char_data = []
    temp = json.load(f)
    f.close()
    for c in temp:
        char_data.append(CharacterData(c))

    return char_data
