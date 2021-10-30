import json
from os import path

class GameData:
    racials = {}
    items = {}
    spells = {}
    race_list = []
    subrace_list = []
    item_list = []
    spell_list = []
    alignment_list = []


    def __init__(self):
        basepath = path.abspath('')
        rf = open(path.abspath(path.join(basepath, "..", "game_data", "fandom_racial_features.json")), "r", encoding="utf-8")
        self.racials = json.load(rf)
        rf.close()

        self.race_list = list(self.racials.keys())
        self.race_list.remove("Human Variant")
        self.race_list.sort()

        self.subrace_list = []
        for r in self.racials:
            if "Subclasses" in self.racials[r]:
                sr = list(self.racials[r]["Subclasses"])
                sr.sort()
                self.subrace_list.extend(sr)        

        itf = open(path.abspath(path.join(basepath, "..", "game_data", "roll_20_all_items.json")), "r", encoding="utf-8")
        self.items = json.load(itf)
        itf.close()

        self.item_list = list(self.items.keys())   
        self.item_list.sort()

        sf = open(path.abspath(path.join(basepath, "..", "game_data", "roll_20_all_spells.json")), "r", encoding="utf-8")
        self.spells = json.load(sf)
        sf.close()

        self.spell_list = list(self.spells.keys())
        self.spell_list.sort()

        self.alignment_list = ["lawful good", "neutral good", "chaotic good", "lawful neutral", "neutral", "chaotic neutral", "lawful evil", "neutral evil", "chaotic evil"]
