import logging
from django.db import transaction
from jsonschema import validate, ValidationError
import app.models


logger = logging.getLogger(__name__)

same_attrs = ["name", "clss", "is_npc", "is_friendly", "level", "race", "background", "alignment", "experience_points", "inspiration", "proficiency_bonus", "passive_wisdom", "other_proficiencies_skills", "armor_class", "initiative", "speed", "max_hp", "cur_hp", "temp_hp", "hit_dice", "death_save_success", "death_save_failure", "attacks", "equipment", "traits", "ideals", "bonds", "flaws", "features_and_traits", "age", "eyes", "height", "weight", "backstory", "dark_gifts", "features", "allies", "treasure", "notes"]

abilities = ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]

skills = ["acrobatics", "animal_handling", "arcana", "athletics", "deception", "history", "insight", "intimidation", "investigation", "medicine", "nature", "perception", "performance", "persuasion", "religion", "sleight_of_hand", "stealth", "survival"]

spells_same_attrs = ["spellcast_ability", "spell_save_dc", "spell_attack_bonus"]

spell_same_attrs = ["name", "description", "classes", "level", "components", "material", "casting_time", "die_sides", "die_count", "extra_damage", "damage_type", "duration", "range", "school", "target"]

character_sheet_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string", "maxLength": 255},
        "clss": {"type": "string", "maxLength": 255},
        "is_npc": {"type": "boolean"},
        "is_friendly": {"type": "boolean"},
        "level": {"type": "integer", "minimum": 0},
        "race": {"type": "string", "maxLength": 255},
        "background": {"type": "string", "maxLength": 255},
        "alignment": {"type": "integer", "minimum": 0, "maximum": 8},
        "experience_points": {"type": "integer", "minimum": 0},
        "inspiration": {"type": "integer"},
        "proficiency_bonus": {"type": "integer"},
        "passive_wisdom": {"type": "integer"},
        "other_proficiencies_skills": {"type": "string", "maxLength": 4095},
        "armor_class": {"type": "integer"},
        "initiative": {"type": "integer"},
        "speed": {"type": "integer"},
        "max_hp": {"type": "integer", "minimum": 0},
        "cur_hp": {"type": "integer", "minimum": 0},
        "temp_hp": {"type": "integer", "minimum": 0},
        "hit_dice": {"type": "integer", "minimum": 0},
        "death_save_success": {"type": "integer", "minimum": 0},
        "death_save_failure": {"type": "integer", "minimum": 0},
        "attacks": {"type": "string", "maxLength": 4095},
        "equipment": {"type": "string", "maxLength": 4095},
        "traits": {"type": "string", "maxLength": 4095},
        "ideals": {"type": "string", "maxLength": 4095},
        "bonds": {"type": "string", "maxLength": 4095},
        "flaws": {"type": "string", "maxLength": 4095},
        "features_and_traits": {"type": "string", "maxLength": 4095},
        "age": {"type": "integer", "minimum": 0},
        "eyes": {"type": "string", "maxLength": 255},
        "height": {"type": "string", "maxLength": 255},
        "weight": {"type": "string", "maxLength": 255},
        "backstory": {"type": "string", "maxLength": 4095},
        "dark_gifts": {"type": ["string", "null"], "maxLength": 4095},
        "features": {"type": "string", "maxLength": 4095},
        "allies": {"type": ["string", "null"], "maxLength": 4095},
        "treasure": {"type": ["string", "null"], "maxLength": 4095},
        "notes": {"type": ["string", "null"], "maxLength": 4095},

        "abilities": {
            "type": "object",
            "properties": {
                ability: {"type": "integer"}
                for ability in abilities
            },
            "additionalProperties": False,
            "minProperties": len(abilities),
        },
        "saving": {
            "type": "object",
            "properties": {
                ability: {"type": "boolean"}
                for ability in abilities
            },
            "additionalProperties": False,
            "minProperties": len(abilities),
        },
        "skills": {
            "type": "object",
            "properties": {
                skill: {"type": "boolean"}
                for skill in skills
            },
            "additionalProperties": False,
            "minProperties": len(skills),
        },

        "spells": {
            "type": "object",
            "properties": {
                "spellcast_ability": {"type": "string", "maxLength": 127},
                "spell_save_dc": {"type": "integer"},
                "spell_attack_bonus": {"type": "integer"},
                "by_level": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "slots": {"type": "integer", "minimum": 0},
                            "spells": {
                                "type": "array",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "name": {"type": "string", "maxLength": 255},
                                        "charges": {"type": "integer", "minimum": 0},
                                    },
                                    "required": ["name"],
                                },
                            },
                        },
                    },
                    "minItems": 11, # 0-x
                    "maxItems": 11,
                },
            },
            "additionalProperties": False,
            "minProperties": 4,
        },
    },
    "additionalProperties": False,
    "minProperties": 43,
}

def create_character_sheet(info, is_npc):
    try:
        validate(instance=info, schema=character_sheet_schema)
    except ValidationError as e:
        logger.warn(f"Got validation error: {e}")
        return None

    if info["is_npc"] != is_npc:
        logger.warn(f"is_npc: Expected {is_npc}, got {info['is_npc']}")
        return None

    with transaction.atomic():
        sheet = app.models.CharacterSheet()
        for attr in same_attrs:
            setattr(sheet, attr, info[attr])
        for ability, val in info["abilities"].items():
            setattr(sheet, f"{ability}_ability", val)
        for ability, val in info["saving"].items():
            setattr(sheet, f"{ability}_saving", val)
        for skill, val in info["skills"].items():
            setattr(sheet, f"{skill}_skill", val)
        sheet.save()

        spellsheet = app.models.CharacterSpellSheet(character=sheet)
        for attr in spells_same_attrs:
            setattr(spellsheet, attr, info["spells"][attr])
        for level, level_info in enumerate(info["spells"]["by_level"]):
            if level == 10:
                level = "x"
            setattr(spellsheet, f"level_{level}_spellslots", level_info["slots"])
        spellsheet.save()

        for level, level_info in enumerate(info["spells"]["by_level"]):
            for spell_info in level_info["spells"]:
                spell = app.models.Spell.objects.filter(name=spell_info["name"])
                if len(spell) != 1:
                    transaction.rollback()
                    logger.warn(f"Unknown spell f{spell_info['name']}")
                    return None
                spell = spell[0]
                spellslot = app.models.CharacterSpellslot(character=spellsheet, spell=spell, charges=spell_info["charges"])
                spellslot.save()

        return sheet

def json_spell(spellslot):
    json = {}
    for attr in spell_same_attrs:
        json[attr] = getattr(spellslot.spell, attr)
    json["charges"] = spellslot.charges
    return json

def json_spells(sheet):
    spellsheet = app.models.CharacterSpellSheet.objects.filter(character=sheet)
    if len(spellsheet) != 1:
        return None
    spellsheet = spellsheet[0]
    json = {}
    for attr in spells_same_attrs:
        json[attr] = getattr(spellsheet, attr)
    json["by_level"] = []
    for level in range(0, 10):
        json["by_level"].append({ "slots": getattr(spellsheet, f"level_{level}_spellslots"), "spells": [] })
    json["by_level"].append({ "slots": spellsheet.level_x_spellslots, "spells": [] })

    spells = app.models.CharacterSpellslot.objects.filter(character=spellsheet)
    for spell in spells:
        json["by_level"][spell.spell.level]["spells"].append(json_spell(spell))
    return json

def json_character_sheet(sheet):
    json = {}
    for attr in same_attrs:
        json[attr] = getattr(sheet, attr)
    json["abilities"] = {}
    json["saving"] = {}
    for ability in abilities:
        json["abilities"][ability] = getattr(sheet, f"{ability}_ability")
        json["saving"][ability] = getattr(sheet, f"{ability}_saving")
    json["skills"] = {}
    for skill in skills:
        json["skills"][ability] = getattr(sheet, f"{skill}_skill")
    json["spells"] = json_spells(sheet)
    return json


