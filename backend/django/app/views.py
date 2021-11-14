import json
import random
import string
from django.contrib.auth import authenticate, login
from django.http import HttpResponse, JsonResponse
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
import app.models

EXAMPLE_PLAYER_ID = "1dc61423-9f17-4b3c-bc26-455013d03d02"
EXAMPLE_DM_ID = "e4cd7fa0-cd3e-421d-8063-bbbd9456b8ef"
EXAMPLE_PARTY_ID = "de9cf5da-cdf3-4dd2-9e14-87105e1b423a"

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

same_attrs = ["name", "clss", "level", "race", "background", "alignment", "experience_points", "inspiration", "proficiency_bonus", "passive_wisdom", "other_proficiencies_skills", "armor_class", "initiative", "speed", "max_hp", "cur_hp", "temp_hp", "hit_dice", "death_save_success", "death_save_failure", "attacks", "equipment", "traits", "ideals", "bonds", "flaws", "features_and_traits", "age", "eyes", "height", "weight", "backstory", "dark_gifts", "features", "allies", "treasure", "notes"]

abilities = ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]

skills = ["acrobatics", "animal_handling", "arcana", "athletics", "deception", "history", "insight", "intimidation", "investigation", "medicine", "nature", "perception", "performance", "persuasion", "religion", "sleight_of_hand", "stealth", "survival"]

spells_same_attrs = ["spellcast_ability", "spell_save_dc", "spell_attack_bonus"]

spell_same_attrs = ["name", "description", "classes", "level", "components", "material", "casting_time", "die_sides", "die_count", "damage_type", "duration", "range", "school", "target"]


def create_character_sheet(info):
    pass

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
        json["by_level"].append({ "slots": getattr(spellsheet, f"level_{level}_spellslots") })
    json["by_level"].append({ "slots": spellsheet.level_x_slots })

    spells = app.models.CharacterSpellslot.objects.filter(character=sheet)
    for spell in spells:
        json["by_level"][spell.spell.level] = json_spell(spell)
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
@require_http_methods(["GET", "POST"])
def user(request):
    user = request.user
    if request.method == "POST":
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
        sheet = create_character_sheet(obj["sheet"])
        if sheet is None:
            return HttpResponse(status=400)
        info.sheet = sheet
        info.is_dm = bool(obj["isDM"])
        info.save()

    return JsonResponse({
        "isDM": info.is_dm,
        "sheet": json_character_sheet(info.sheet) if info.sheet is not None else None,
    })

    if member_id == EXAMPLE_DM_ID:
        return JsonResponse({
            "isDM": True,
            "sheet": None,
        })
    elif member_id == EXAMPLE_PLAYER_ID:
        return JsonResponse({
            "isDM": False,
            "sheet": {
                "name": "exampleName",
                "class": "artificer",
                "level": 3,
                "race": "Aasimar",
                "background": "Sage",
                "alignment": 2,
                "experiencePoints": 8,
                "abilityScores": {
                    "strength": -1,
                    "dexterity": 2,
                    "constitution": 1,
                    "intelligence": 4,
                    "wisdom": 1,
                    "charisma": 1,
                },
                "inspiration": 0,
                "proficiencyBonus": 2,
                "savingThrows": {
                    "strength": False,
                    "dexterity": False,
                    "constitution": True,
                    "intelligence": True,
                    "wisdom": False,
                    "charisma": False,
                },
                "skills": {
                    "acrobatics": False,
                    "animalHandling": False,
                    "arcana": True,
                    "athletics": False,
                    "deception": False,
                    "history": True,
                    "insight": False,
                    "intimidation": False,
                    "investigation": False,
                    "medicine": False,
                    "nature": False,
                    "perception": True,
                    "performance": False,
                    "persuasion": False,
                    "religion": False,
                    "sleightOfHand": True,
                    "stealth": False,
                    "survival": False,
                },
                "passiveWisdom": 13,
                "otherProficienciesAndSkills": "Common\nCelestial",
                "stats": {
                    "armorClass": 14,
                    "initiative": 2,
                    "speed": 30,
                    "maxHP": 18,
                    "curHP": 18,
                    "tempHP": 0,
                    "hitDice": "3d8",
                    "deathSaveSuccess": 0,
                    "deathSaveFailure": 0
                },
                "attacks": "Example attacks here",
                "equipment": """Hand-axe (1d6 slashing)
Spear (1d6 piercing)
Light crossbow (1d8 piercing, 20 ammo)
Scale mail (AC 14, stealth disadv)
Thieves' tools
Backpack
Crowbar
Hammer
10 pitons
10 torches
Tinderbox
10 days of rations
Waterskin
Soft of hempen rope""",
                "personality": {
                    "traits": "Example traits here",
                    "ideals": "Example ideals here",
                    "bonds": "Example bonds here",
                    "flaws": "Example flaws here",
                },
                "featuresAndTraits": """Darkvision
Celestial resistance
Healing hands
    touch, +HP = level, 1/LR
Radiant consumption
    light 10ft, dim light 20ft
    ceil(level/2) radiant dmg in 10ft (incl. self)
    extra radiant dmg/attack: +level, 1/turn""",
                "appearance": {
                    "age": 28,
                    "eyes": "blue",
                    "height": "5ft 11in",
                    "weight": "160lbs",
                },
                "backstory": "Example backstory here",
                "darkGifts": "Example darkgifts here",
                "features": "Example features here",
                "allies": "Example allies here",
                "treasure": "Example treasure here",
                "spellcasting": {
                    "ability": 18,
                    "dc": 14,
                    "attackBonus": 6,
                    "level1Slots": 3,
                    "level2Slots": 0,
                    "level3Slots": 0,
                    "level4Slots": 0,
                    "level5Slots": 0,
                    "level6Slots": 0,
                    "level7Slots": 0,
                    "level8Slots": 0,
                    "level9Slots": 0,
                },
                "spells": [
                    {
                        "name": "Light",
                        "components": ['V', 'M'],
                        "level": 0,
                        "description": "",
                        "prepared": None,
                    },
                    {
                        "name": "Fire Bolt",
                        "components": ['V', 'S'],
                        "level": 0,
                        "description": "ranged spell 1d10, inst., 120ft",
                        "prepared": None,
                    },
                    {
                        "name": "Magic Stone",
                        "components": ['V', 'S'],
                        "level": 0,
                        "description": "1-3 pebbles, blud 1d6 + spell mod, 60ft, BA",
                        "prepared": None,
                    },
                    {
                        "name": "Faerie Fire",
                        "components": ['V'],
                        "level": 1,
                        "description": "20ft cube B1/Gr/Vi 10ft light, 60ft",
                        "prepared": False,
                    },
                    {
                        "name": "Purify Food and Drink",
                        "components": ['V', 'S'],
                        "level": 1,
                        "description": "5ft sphere, 10ft",
                        "prepared": False,
                    },
                    {
                        "name": "Tasha' Caustic Brew",
                        "components": ['V', 'S', 'M'],
                        "level": 1,
                        "description": "30ft x 5ft, 2d4 acid",
                        "prepared": False,
                    },
                    {
                        "name": "Healing Word",
                        "components": ['V'],
                        "level": 1,
                        "description": "+HP = 1d4 + spell, 60ft, BA",
                        "prepared": True,
                    },
                    {
                        "name": "Ray of Sickness",
                        "components": ['V', 'S'],
                        "level": 1,
                        "description": "ranged spell, 2d8 poison, 60ft",
                        "prepared": True,
                    },
                ]
            }
        })
    else:
        return HttpResponse(status=404)

