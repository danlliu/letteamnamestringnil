from django.contrib.auth.models import User
from django.db import models

class Party(models.Model):
    code = models.CharField(max_length=255)

class UserPartyInfo(models.Model):
    user = models.ForeignKey("User", on_delete=models.CASCADE)
    party = models.ForeignKey("Party", on_delete=models.CASCADE)
    is_dm = models.BooleanField()
    sheet = models.ForeignKey("CharacterSheet", null=True, on_delete=models.SET_NULL)

    class Meta:
        unique_together = [["user", "party"]]

class CharacterSheet(models.Model):
    name = models.CharField(max_length=255)
    clss = models.CharField(max_length=255)
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
    proficiencyBonus = models.IntegerField()

    strength_saving = models.BooleanField()
    dexterity_saving = models.BooleanField()
    constitution_saving = models.BooleanField()
    intelligence_saving = models.BooleanField()
    wisdom_saving = models.BooleanField()
    charisma_saving = models.BooleanField()

    acrobatics_skill = models.BooleanField()
    animal_handling_skill = models.BooleanField()
    arcana_skill = models.BooleanField()
    athletics_skill = models.BooleanField()
    deception_skill = models.BooleanField()
    history_skill = models.BooleanField()
    insight_skill = models.BooleanField()
    intimidation_skill = models.BooleanField()
    investigation_skill = models.BooleanField()
    medicine_skill = models.BooleanField()
    nature_skill = models.BooleanField()
    perception_skill = models.BooleanField()
    performance_skill = models.BooleanField()
    persuasion_skill = models.BooleanField()
    religion_skill = models.BooleanField()
    sleight_of_hand_skill = models.BooleanField()
    stealth_skill = models.BooleanField()
    survival_skill = models.BooleanField()

    passive_wisdom = models.IntegerField()
    other_proficiencies_skills = models.CharField(max_length=4095)

    armor_class = models.IntegerField()
    initiative = models.IntegerField()
    speed = models.IntegerField()
    max_hp = models.IntegerField()
    cur_hp = models.IntegerField()
    temp_hp = models.IntegerField()
    hit_dice = models.IntegerField()
    death_save_success = models.IntegerField()
    death_save_failure = models.IntegerField()

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
    dark_gifts = models.CharField(max_length=4095)
    features = models.CharField(max_length=4095)
    allies = models.CharField(max_length=4095)
    treasure = models.CharField(max_length=4095)

    # TODO: spells
