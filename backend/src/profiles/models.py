
from django.db import models
from django.conf import settings
from locations.models import Station  

User = settings.AUTH_USER_MODEL

# ----------------------------
# MOH Profile
# ----------------------------
class MOHProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='moh_profile'
    )
    department = models.CharField(max_length=255)
    position = models.CharField(max_length=255)
    station = models.ForeignKey(
        Station,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        help_text="The station where this MOH user is assigned"
    )

    def __str__(self):
        return f"{self.user.get_full_name()} - {self.department}"


# ----------------------------
# NGO Profile
# ----------------------------
class NGOProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='ngo_profile'
    )
    organization_name = models.CharField(max_length=255)
    position = models.CharField(max_length=255)

    def __str__(self):
        return f"{self.user.get_full_name()} - {self.organization_name}"
