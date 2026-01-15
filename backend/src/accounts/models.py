from django.contrib.auth.models import AbstractUser, Group, Permission
from django.core.exceptions import ValidationError
from django.db import models

class User(AbstractUser):
     # Override groups and permissions to avoid reverse accessor clash
    groups = models.ManyToManyField(
        Group,
        verbose_name='groups',
        blank=True,
        help_text='The groups this user belongs to.',
        related_name='custom_user_set',  # <- changed
        related_query_name='custom_user'
    )
    user_permissions = models.ManyToManyField(
        Permission,
        verbose_name='user permissions',
        blank=True,
        help_text='Specific permissions for this user.',
        related_name='custom_user_set',  # <- changed
        related_query_name='custom_user'
    )


    USER_TYPE_CHOICES = (
        ('MOH', 'Ministry of Health'),
        ('NGO', 'NGO'),
    )

    user_type = models.CharField(max_length=3, choices=USER_TYPE_CHOICES)
    email = models.EmailField(unique=True)
    national_id = models.CharField(max_length=20, unique=True, null=True, blank=True)
    is_admin = models.BooleanField(default=False)
    
    profile_complete = models.BooleanField(default=False, help_text="Indicates if the user has completed their profile")

  

    def clean(self):
        """
        Enforce that profile_complete can only be True if the user actually filled the profile.
        """
        # Skip check if profile_complete is False
        if self.profile_complete:
            if self.user_type == 'MOH':
                profile = getattr(self, 'moh_profile', None)
                if not profile or not (profile.department and profile.position and profile.station):
                    raise ValidationError(
                        "Cannot mark profile_complete=True: MOH profile is incomplete."
                    )
            elif self.user_type == 'NGO':
                profile = getattr(self, 'ngo_profile', None)
                if not profile or not (profile.organization_name and profile.position):
                    raise ValidationError(
                        "Cannot mark profile_complete=True: NGO profile is incomplete."
                    )

    def save(self, *args, **kwargs):
        # Call clean() before saving to enforce validation
        self.clean()
        super().save(*args, **kwargs)



    def __str__(self):
        return f"{self.get_full_name()} ({self.user_type})"

    # already inherited:
    # username
    # first_name
    # last_name
    # password
