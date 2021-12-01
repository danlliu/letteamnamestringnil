import json
import logging
import random
import string
from django.contrib.auth import authenticate, login
from django.contrib.auth.models import User
from django.db import transaction
from django.http import HttpResponse, JsonResponse
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
from jsonschema import validate, ValidationError
import app.models


logger = logging.getLogger(__name__)

def require_auth(func):
    def wrapper(*args, **kwargs):
        request = args[0]
        if not request.user.is_authenticated:
            return HttpResponse(status=401)
        return func(*args, **kwargs)
    return wrapper


def in_party(party, user):
    info = app.models.UserPartyInfo.objects.filter(user=user, party=party)
    return len(info) == 1

def gen_code():
    return "".join(random.SystemRandom().choices(string.ascii_uppercase + string.digits + string.ascii_lowercase, k=6))

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

def create_character_sheet(info):
    try:
        validate(instance=info, schema=character_sheet_schema)
    except ValidationError as e:
        logger.warn(f"Got validation error: {e}")
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

@csrf_exempt
@require_http_methods(["GET", "POST", "PUT"])
def user(request):
    user = request.user
    if request.method == "PUT":
        # Creates an account
        try:
            obj = json.loads(request.body)
        except json.JSONDecodeError:
            return HttpResponse(status=400)
        if user.is_authenticated or "username" not in obj or "password" not in obj or not isinstance(obj["password"], str):
            return HttpResponse(status=400)
        user = User.objects.create_user(obj["username"], email=None, password=obj["password"])
        if user is None:
            return HttpResponse(status=409)
        login(request, user)
    elif request.method == "POST":
        # Performs a login
        try:
            obj = json.loads(request.body)
        except json.JSONDecodeError:
            return HttpResponse(status=400)
        if user.is_authenticated or "username" not in obj or "password" not in obj:
            return HttpResponse(status=400)
        user = authenticate(username=obj["username"], password=obj["password"])
        login(request, user)
    if not user.is_authenticated:
        return HttpResponse(status=401)
    return JsonResponse({
        "id": user.id,
        "username": user.username,
        "email": user.email,
    })

@csrf_exempt
@require_http_methods(["GET", "POST"])
@require_auth
def parties(request):
    if request.method == "POST":
        # Create a new party
        party = app.models.Party.objects.create(code=gen_code())
        app.models.UserPartyInfo.objects.create(user=request.user, party=party, is_dm=True, sheet=None)

    parties = app.models.UserPartyInfo.objects.all().filter(user=request.user)
    return JsonResponse(list(map(lambda p: p.party.code, parties)), safe=False)

@csrf_exempt
@require_http_methods(["POST"])
@require_auth
def join_party(request):
    try:
        obj = json.loads(request.body)
    except json.JSONDecodeError:
        return HttpResponse(status=400)
    if "code" not in obj or "is_dm" not in obj:
        return HttpResponse(status=400)
    parties = app.models.Party.objects.filter(code=obj["code"])
    if len(parties) != 1:
        return HttpResponse(status=400)
    party = parties[0]
    app.models.UserPartyInfo.create(
        user=request.user, party=party, is_dm=is_dm, sheet=None)
    return HttpResponse(status=201)

@csrf_exempt
@require_http_methods(["GET"])
@require_auth
def party_info(request, party_code):
    parties = app.models.Party.objects.filter(code=party_code)
    if len(parties) != 1:
        return HttpResponse(status=401)
    party = parties[0]

    userinfos = app.models.UserPartyInfo.objects.filter(party=party)

    return JsonResponse({
        "code": party.code,
        "members": [
            { "id": info.user.id, "username": info.user.username, }
            for info in userinfos
        ]
    })

@csrf_exempt
@require_http_methods(["GET", "POST"])
@require_auth
def member_info(request, party_code, member_id):
    parties = app.models.Party.objects.filter(code=party_code)
    if len(parties) != 1:
        return HttpResponse(status=403)
    party = parties[0]

    if not in_party(party, request.user):
        return HttpResponse(status=403)

    users = app.models.User.objects.filter(id=member_id)
    if len(users) != 1:
        return HttpResponse(status=400)
    user = users[0]

    info = app.models.UserPartyInfo.objects.filter(user=user, party=party)
    if len(info) != 1:
        return HttpResponse(status=400)
    info = info[0]

    if request.method == "POST":
        try:
            obj = json.loads(request.body)
        except json.JSONDecodeError:
            return HttpResponse(status=400)
        if "sheet" not in obj or "isDM" not in obj:
            return HttpResponse(status=400)
        if obj["sheet"] is not None:
            sheet = create_character_sheet(obj["sheet"])
            if sheet is None:
                return HttpResponse(status=400)
        else:
            sheet = None
        if info.sheet is not None:
            info.sheet.delete()
        info.sheet = sheet
        info.is_dm = bool(obj["isDM"])
        info.save()

    return JsonResponse({
        "isDM": info.is_dm,
        "sheet": json_character_sheet(info.sheet) if info.sheet is not None else None,
    })
