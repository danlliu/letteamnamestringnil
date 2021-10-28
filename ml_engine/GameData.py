import json
from os import path

class GameData:
    racials = {}
    items = {}
    spells = {}

    def __init__(self):
        basepath = path.abspath('')
        rf = open(path.abspath(path.join(basepath, "..", "game_data", "fandom_racial_features.json")), "r", encoding="utf-8")
        self.racials = json.load(rf)
        rf.close()

        itf = open(path.abspath(path.join(basepath, "..", "game_data", "roll_20_all_items.json")), "r", encoding="utf-8")
        self.items = json.load(itf)
        itf.close()

        sf = open(path.abspath(path.join(basepath, "..", "game_data", "roll_20_all_spells.json")), "r", encoding="utf-8")
        self.spells = json.load(sf)
        sf.close()
