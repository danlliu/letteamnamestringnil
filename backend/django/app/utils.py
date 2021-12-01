import random
import string
from django.http import HttpResponse
import app.models


def require_auth(func):
    def wrapper(*args, **kwargs):
        request = args[0]
        if not request.user.is_authenticated:
            return HttpResponse(status=401)
        return func(*args, **kwargs)
    return wrapper

def gen_code():
    return "".join(random.SystemRandom().choices(string.ascii_uppercase + string.digits + string.ascii_lowercase, k=6))

def in_party(party, user):
    info = app.models.UserPartyInfo.objects.filter(user=user, party=party)
    return len(info) == 1
