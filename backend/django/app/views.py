import json
from django.http import HttpResponse, JsonResponse
from django.views.decorators.http import require_http_methods

EXAMPLE_PLAYER_ID = "1dc61423-9f17-4b3c-bc26-455013d03d02"
EXAMPLE_DM_ID = "e4cd7fa0-cd3e-421d-8063-bbbd9456b8ef"
EXAMPLE_PARTY_ID = "de9cf5da-cdf3-4dd2-9e14-87105e1b423a"

@require_http_methods(["GET", "POST"])
def user(request):
    if request.method == "POST":
        pass
    return JsonResponse({
        "id": EXAMPLE_PLAYER_ID,
        "username": "example_user",
        "email": "example_user@example.com",
    })

@require_http_methods(["GET", "POST"])
def parties(request):
    if request.method == "POST":
        pass
    return JsonResponse([
        EXAMPLE_PARTY_ID,
    ])

@require_http_methods(["GET", "POST"])
def party_info(request, party_id):
    if request.method == "POST":
        pass
    
    if party_id != EXAMPLE_PARTY_ID:
        return HttpResponse(status=404)

    return JsonResponse({
        "id": EXAMPLE_PARTY_ID,
        "code": "EECS441",
        "members": [
            { "id": EXAMPLE_DM_ID, "username": "example_dm" },
            { "id": EXAMPLE_PLAYER_ID, "username": "example_user" },
        ]
    })

@require_http_methods(["GET", "POST"])
def member_info(request, party_id, member_id):
    if request.method == "POST":
        pass
    
    if party_id != EXAMPLE_PARTY_ID:
        return HttpResponse(status=404)

    if member_id == EXAMPLE_DM_ID:
        return JsonResponse({
            "isDM": True,
            "sheet": None,
        }
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
                    "speed:" 30,
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

