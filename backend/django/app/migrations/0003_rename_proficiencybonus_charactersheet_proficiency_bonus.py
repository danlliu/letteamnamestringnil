# Generated by Django 3.2.8 on 2021-11-14 15:55

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0002_alter_party_code'),
    ]

    operations = [
        migrations.RenameField(
            model_name='charactersheet',
            old_name='proficiencyBonus',
            new_name='proficiency_bonus',
        ),
    ]
