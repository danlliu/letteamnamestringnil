import json
from django.core.management.base import BaseCommand
from django.db import transaction
from pathlib import Path
import app.models

spells_file_path = (Path(__file__)/".."/".."/".."/".."/".."/"game_data"/"roll_20_all_spells.json").resolve()

def main():
    with spells_file_path.open("r") as spells_file:
        spells = json.load(spells_file)
        with transaction.atomic():
            for name, data in spells.items():
                # Note: This does not store Higher Spell Slot info
                healing = data.get("Healing")
                if name == "Beacon of Hope":
                    healing = "The maximum HP possible from any Healing"
                elif name == "Mass Heal":
                    healing = "Up to 700 HP"
                elif name == "Regenerate":
                    healing = "4d8+15"
                app.models.Spell.objects.create(
                    name=name,
                    description=data["Description"],
                    classes=data["Classes"],
                    level=data["Level"],
                    components=data.get("Components"),
                    material=data.get("Material"),
                    casting_time=data.get("Casting Time"),
                    damage = data.get("Damage"),
                    healing = healing,
                    damage_type=data.get("Damage Type"),
                    duration=data["Duration"],
                    range=data.get("Range"),
                    school=data["School"],
                    target=data.get("Target"))

class Command(BaseCommand):
    def add_arguments(self, parser):
        pass

    def handle(self, *args, **options):
        main()
