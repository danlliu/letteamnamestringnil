import json
import logging
import sys
from django.contrib.auth import authenticate, login
from django.contrib.auth.models import User
from django.http import HttpResponse, JsonResponse
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
from app.utils import require_auth, gen_code, in_party
from app.charactersheet import create_character_sheet, json_character_sheet, json_spells
import app.models


sys.path.append('../ml_engine')
from CharacterGeneration import generate_character

logger = logging.getLogger(__name__)

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
        if len(User.objects.filter(username=obj["username"])) != 0:
            return HttpResponse(status=409)
        user = User.objects.create_user(obj["username"], email=None, password=obj["password"])
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
        return HttpResponse("Not authenticated", status=401)
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
    app.models.UserPartyInfo.objects.create(
        user=request.user, party=party, is_dm=obj["is_dm"], sheet=None)
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
            sheet = create_character_sheet(obj["sheet"], is_npc=False)
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

@csrf_exempt
@require_http_methods(["GET", "POST"])
@require_auth
def npc_info(request, party_code, npc_id):
    parties = app.models.Party.objects.filter(code=party_code)
    if len(parties) != 1:
        return HttpResponse(status=403)
    party = parties[0]

    if not in_party(party, request.user):
        return HttpResponse(status=403)

    info = app.models.NPCInfo.objects.filter(party=party, id=npc_id)
    if len(info) != 1:
        logger.warn(f"400 due to info len: {len(info)}")
        return HttpResponse(status=400)
    info = info[0]

    if request.method == "POST":
        try:
            obj = json.loads(request.body)
        except json.JSONDecodeError:
            logger.warn("400 due to JSONDecodeError")
            return HttpResponse(status=400)
        if "sheet" not in obj:
            logger.warn("400 due to missing 'sheet'")
            return HttpResponse(status=400)
        if obj["sheet"] is not None:
            sheet = create_character_sheet(obj["sheet"], is_npc=True)
            if sheet is None:
                logger.warn("400 due to failure to create sheet")
                return HttpResponse(status=400)
        else:
            sheet = None
        if info.sheet is not None:
            info.sheet.delete()
        info.sheet = sheet
        info.save()

    return JsonResponse({
        "sheet": json_character_sheet(info.sheet) if info.sheet is not None else None,
    })

@csrf_exempt
@require_http_methods(["GET", "POST"])
@require_auth
def party_npcs(request, party_code):
    parties = app.models.Party.objects.filter(code=party_code)
    if len(parties) != 1:
        return HttpResponse(status=403)
    party = parties[0]

    if not in_party(party, request.user):
        return HttpResponse(status=403)

    if request.method == "POST":
        info = app.models.NPCInfo.objects.create(party=party, sheet=None)
        return JsonResponse({
            "id": info.id,
        })
    else:
        npcs = app.models.NPCInfo.objects.all().filter(party=party)
        return JsonResponse([npc.id for npc in npcs], safe=False)

@csrf_exempt
@require_http_methods(["GET"])
@require_auth
def party_spells(request, party_code):
    parties = app.models.Party.objects.filter(code=party_code)
    if len(parties) != 1: 
        return HttpResponse(status=403)
    party = parties[0]

    if not in_party(party, request.user):
        return HttpResponse(status=403)

    user_party_info = app.models.UserPartyInfo.objects.filter(party=party)

    result = []
    for userinfo in user_party_info:
        username = userinfo.user.username
        sheet = userinfo.sheet
        dm = userinfo.is_dm
        
        if sheet and not dm:
            user_spells = json_spells(sheet)
           
            for level in range(10): 
                for spell in user_spells['by_level'][level]['spells']:
                    cur_spell = [level, username] 

                    if spell['damage_type'] != None:
                        cur_spell += ['ATK', spell['damage_type'], spell['damage'], spell['range']]
                    elif spell['healing'] != None:
                        cur_spell += ['HEAL', spell['healing'], spell['range']]
                    else:
                        cur_spell += ['DEF/UTIL']
                
                    result.append(cur_spell)
        
        result.sort()

    return JsonResponse(result, safe=False)

@csrf_exempt
@require_http_methods(["POST"])
@require_auth
def generate(request):
    try:
        obj = json.loads(request.body)
    except json.JSONDecodeError:
        return HttpResponse(status=400)
    if "clss" not in obj or not isinstance(obj["clss"], str):
        return HttpResponse(status=400)
    if obj.get("alignment") is not None and not isinstance(obj.get("alignment"), int):
        return HttpResponse(status=400)
    clss = obj["clss"]
    alignment = obj.get("alignment")
    sheet_json = generate_character(clss, alignment) if alignment is not None else generate_character(clss)
    return JsonResponse(sheet_json)
