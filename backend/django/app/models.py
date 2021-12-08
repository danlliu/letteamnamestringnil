from django.contrib.auth.models import User
from django.db import models

class Party(models.Model):
    code = models.CharField(max_length=255, unique=True)

class UserPartyInfo(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)

    party = models.ForeignKey("Party", on_delete=models.CASCADE)
    is_dm = models.BooleanField()
    sheet = models.ForeignKey("CharacterSheet", null=True, on_delete=models.SET_NULL)

    class Meta:
        unique_together = [["user", "party"]]

class NPCInfo(models.Model):
    party = models.ForeignKey("Party", on_delete=models.CASCADE)
    sheet = models.ForeignKey("CharacterSheet", null=True, on_delete=models.CASCADE)

class CharacterSheet(models.Model):
    name = models.CharField(max_length=255)
    clss = models.CharField(max_length=255)
    is_npc = models.BooleanField()
    is_friendly = models.BooleanField()
    level = models.IntegerField()
    race = models.CharField(max_length=255)
    background = models.CharField(max_length=255)
    alignment = models.IntegerField()
    experience_points = models.IntegerField()

    strength_ability = models.IntegerField()
    dexterity_ability = models.IntegerField()
    constitution_ability = models.IntegerField()
    intelligence_ability = models.IntegerField()
    wisdom_ability = models.IntegerField()
    charisma_ability = models.IntegerField()

    inspiration = models.IntegerField()
    proficiency_bonus = models.IntegerField()

    strength_saving = models.BooleanField(default=False, blank=True)
    dexterity_saving = models.BooleanField(default=False, blank=True)
    constitution_saving = models.BooleanField(default=False, blank=True)
    intelligence_saving = models.BooleanField(default=False, blank=True)
    wisdom_saving = models.BooleanField(default=False, blank=True)
    charisma_saving = models.BooleanField(default=False, blank=True)

    acrobatics_skill = models.BooleanField(default=False, blank=True)
    animal_handling_skill = models.BooleanField(default=False, blank=True)
    arcana_skill = models.BooleanField(default=False, blank=True)
    athletics_skill = models.BooleanField(default=False, blank=True)
    deception_skill = models.BooleanField(default=False, blank=True)
    history_skill = models.BooleanField(default=False, blank=True)
    insight_skill = models.BooleanField(default=False, blank=True)
    intimidation_skill = models.BooleanField(default=False, blank=True)
    investigation_skill = models.BooleanField(default=False, blank=True)
    medicine_skill = models.BooleanField(default=False, blank=True)
    nature_skill = models.BooleanField(default=False, blank=True)
    perception_skill = models.BooleanField(default=False, blank=True)
    performance_skill = models.BooleanField(default=False, blank=True)
    persuasion_skill = models.BooleanField(default=False, blank=True)
    religion_skill = models.BooleanField(default=False, blank=True)
    sleight_of_hand_skill = models.BooleanField(default=False, blank=True)
    stealth_skill = models.BooleanField(default=False, blank=True)
    survival_skill = models.BooleanField(default=False, blank=True)

    passive_wisdom = models.IntegerField()
    other_proficiencies_skills = models.CharField(max_length=4095)

    armor_class = models.IntegerField()
    initiative = models.IntegerField()
    speed = models.IntegerField()
    max_hp = models.IntegerField()
    cur_hp = models.IntegerField()
    temp_hp = models.IntegerField()
    hit_dice = models.IntegerField()
    death_save_success = models.IntegerField(default=0)
    death_save_failure = models.IntegerField(default=0)

    attacks = models.CharField(max_length=4095)
    equipment = models.CharField(max_length=4095)
    
    traits = models.CharField(max_length=4095)
    ideals = models.CharField(max_length=4095)
    bonds = models.CharField(max_length=4095)
    flaws = models.CharField(max_length=4095)

    features_and_traits = models.CharField(max_length=4095)

    age = models.IntegerField()
    eyes = models.CharField(max_length=255)
    height = models.CharField(max_length=255)
    weight = models.CharField(max_length=255)

    backstory = models.CharField(max_length=4095)
    dark_gifts = models.CharField(max_length=4095, default=None, blank=True, null=True)
    features = models.CharField(max_length=4095)
    allies = models.CharField(max_length=4095, default=None, blank=True, null=True)
    treasure = models.CharField(max_length=4095, default=None, blank=True, null=True)
    notes = models.CharField(max_length=8191, default=None, blank=True, null=True)


# Spells
class Spell(models.Model):
    name = models.CharField(max_length=255, unique=True)
    description = models.CharField(max_length=4095)
    classes = models.CharField(max_length=255) # List stored as string. Use json.dumps
    level = models.IntegerField()
    components = models.CharField(max_length=255, default=None, blank=True, null=True) # List stored as string. Use json.dumps
    material = models.CharField(max_length = 511, default=None, blank=True, null=True)
    casting_time = models.CharField(max_length=255, default="1 action", blank=True, null=True)
    damage = models.CharField(max_length=255, default=None, null=True)
    healing = models.CharField(max_length=255, default=None, null=True)
    damage_type = models.CharField(max_length=255, default=None, blank=True, null=True)
    duration = models.CharField(max_length=255)
    range = models.CharField(max_length=255, null=True)
    school = models.CharField(max_length=255)
    target = models.CharField(max_length=511, default=None, blank=True, null=True)

# Player Spellcasting
class CharacterSpellSheet(models.Model):
    character = models.ForeignKey(CharacterSheet, on_delete=models.CASCADE)
    spellcast_ability = models.CharField(max_length=127)
    spell_save_dc = models.IntegerField(default=0)
    spell_attack_bonus = models.IntegerField(default=0, blank=True)
    level_0_spellslots = models.IntegerField(default=0, blank=True)
    level_1_spellslots = models.IntegerField(default=0, blank=True)
    level_2_spellslots = models.IntegerField(default=0, blank=True)
    level_3_spellslots = models.IntegerField(default=0, blank=True)
    level_4_spellslots = models.IntegerField(default=0, blank=True)
    level_5_spellslots = models.IntegerField(default=0, blank=True)
    level_6_spellslots = models.IntegerField(default=0, blank=True)
    level_7_spellslots = models.IntegerField(default=0, blank=True)
    level_8_spellslots = models.IntegerField(default=0, blank=True)
    level_9_spellslots = models.IntegerField(default=0, blank=True)
    level_x_spellslots = models.IntegerField(default=0, blank=True) # for any extra or lvl 10+ spells

class CharacterSpellslot(models.Model):
    character = models.ForeignKey(CharacterSpellSheet, on_delete=models.CASCADE)
    spell = models.ForeignKey(Spell, on_delete=models.CASCADE)
    charges = models.IntegerField()
