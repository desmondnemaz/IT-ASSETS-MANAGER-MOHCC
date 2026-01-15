from django.db import models
from django.core.exceptions import ValidationError
from django.db import models


from django.db import models

class Province(models.Model):
    """
    Model representing a Province in the country.
    
    Fields:
    - province_name: Human-readable name of the province (e.g., Harare)
    - province_suffix: Code used for station code generation (e.g., 01)
        - National office uses 00
    """

    province_name = models.CharField(
        max_length=255,
        unique=True,
        help_text="Enter the full name of the province (e.g., Harare)."
    )
    province_suffix = models.CharField(
        max_length=5,
        unique=True,
        blank=True,
        null=True,
        help_text="Enter unique province suffix (e.g., 01). National office = 00"
    )

    def __str__(self):
        """String representation for admin and debugging."""
        return self.province_name


class District(models.Model):
    """
    Model representing a District, which belongs to a Province.
    
    Fields:
    - district_name: Human-readable name of the district
    - province: ForeignKey linking to the Province
    - district_suffix: Code used for station code generation (e.g., 01)
        - District office uses 00
    - district_code: Unique code identifying the district
    """

    district_name = models.CharField(
        max_length=255,
        help_text="Enter the full name of the district (e.g., Bulawayo Central)."
    )
    province = models.ForeignKey(
        Province,
        on_delete=models.DO_NOTHING,
        help_text="Select the province this district belongs to."
    )
    district_suffix = models.CharField(
        max_length=5,
        blank=True,
        null=True,
        help_text="Enter unique district suffix (e.g., 01). District office = 00"
    )
   

    def __str__(self):
        """String representation for admin and debugging."""
        return f"{self.district_name} ({self.province.province_name})"


class Station(models.Model):
    """
    Model representing a Station (office or facility).

    Features:
    - station_code is auto-generated from province_suffix + district_suffix + station_suffix
    - station_suffix for offices is fixed: HQ -> NC, PO -> PC, DO -> DC
    - station_suffix for facilities (FC) is variable
    - Validation ensures proper suffix, province, and district are provided
    """

    STATION_TYPE_CHOICES = [
        ('HQ', 'Headquarters Office'),
        ('PO', 'Provincial Office'),
        ('DO', 'District Office'),
        ('FC', 'Facility'),
    ]

    station_name = models.CharField(max_length=255)
    station_address = models.CharField(max_length=255, unique=True)
    station_type = models.CharField(max_length=2, choices=STATION_TYPE_CHOICES)
    province = models.ForeignKey('Province', on_delete=models.DO_NOTHING, null=True, blank=True)
    district = models.ForeignKey('District', on_delete=models.DO_NOTHING, null=True, blank=True)
    station_suffix = models.CharField(max_length=5, blank=True, null=True)
    station_code = models.CharField(max_length=20, unique=True, blank=True, null=True)

    def clean(self):
        """
        Validates station fields before saving:
        1. Ensures office station_suffix matches type (HQ/PO/DO)
        2. Ensures required province and district are provided based on station_type
        """

        # Map office types to their fixed suffix
        office_suffix_map = {
            'HQ': 'NC',
            'PO': 'PC',
            'DO': 'DC'
        }

        # --- Validate office suffix ---
        if self.station_type in office_suffix_map:
            expected_suffix = office_suffix_map[self.station_type]
            if self.station_suffix and self.station_suffix != expected_suffix:
                raise ValidationError({
                    'station_suffix': f"For {self.get_station_type_display()}, "
                                      f"suffix must be '{expected_suffix}'."
                })
            # Auto-fill suffix if missing
            if not self.station_suffix:
                self.station_suffix = expected_suffix

        # --- Validate required fields ---
        # Province required for PO, DO, FC
        if self.station_type in ['PO', 'DO', 'FC'] and not self.province:
            raise ValidationError({
                'province': f"Province is required for {self.get_station_type_display()}."
            })

        # District required for DO, FC
        if self.station_type in ['DO', 'FC'] and not self.district:
            raise ValidationError({
                'district': f"District is required for {self.get_station_type_display()}."
            })

    def save(self, *args, **kwargs):
        """
        Overrides save to:
        1. Validate the station (calls clean())
        2. Generate the station_code automatically
        """
        # Call clean() to enforce validations
        self.clean()

        # --- Determine code prefixes ---
        if self.station_type == 'HQ':
            province_suffix = '00'
            district_suffix = '00'
        elif self.station_type == 'PO':
            province_suffix = self.province.province_suffix
            district_suffix = '00'
        elif self.station_type == 'DO':
            province_suffix = self.district.province.province_suffix
            district_suffix = self.district.district_suffix
        else:  # FC
            province_suffix = self.district.province.province_suffix
            district_suffix = self.district.district_suffix
            if not self.station_suffix:
                self.station_suffix = '0A'  # default placeholder for facility

        # --- Generate full station code ---
        self.station_code = f"{province_suffix}{district_suffix}{self.station_suffix}"

        super().save(*args, **kwargs)

    def __str__(self):
        """Friendly display for admin or debugging"""
        return f"{self.station_name} ({self.station_code})"
