from django.db import models
from django.core.exceptions import ValidationError
from locations.models import Station


# ------------------------
# Asset Category
# ------------------------
class AssetCategory(models.Model):
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True)

    def __str__(self):
        return self.name


# ------------------------
# Base Asset
# ------------------------
class Asset(models.Model):
    ASSET_TYPE_CHOICES = [
        ('DEVICE', 'Device'),
        ('NON_DEVICE', 'Non-Device Asset'),
    ]

    STATUS_CHOICES = [
        ('IN_STOCK', 'In Stock'),
        ('ASSIGNED', 'Assigned'),
        ('MAINTENANCE', 'Under Maintenance'),
        ('DISPOSED', 'Disposed'),
        ('STOLEN', 'Stolen'),
    ]

    CONDITION_CHOICES = [
        ('NEW', 'New'),
        ('GOOD', 'Good / Serviceable'),
        ('FAIR', 'Fair (Minor Issues)'),
        ('DAMAGED', 'Damaged'),
        ('BEYOND_REPAIR', 'Beyond Repair'),
    ]

    
    asset_type = models.CharField(max_length=20, choices=ASSET_TYPE_CHOICES)
    category = models.ForeignKey(AssetCategory, on_delete=models.PROTECT)
    current_station = models.ForeignKey(
        Station, on_delete=models.SET_NULL, null=True, blank=True
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='IN_STOCK')
    condition = models.CharField(max_length=20, choices=CONDITION_CHOICES, default='GOOD')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.asset_code} - {self.category.name}"

    # ------------------------
    # Validation: Subtype completeness
    # ------------------------
    def clean(self):
        # Basic fields
        if not self.asset_type:
            raise ValidationError("Asset must have an asset_type.")
        if not self.category:
            raise ValidationError("Asset must belong to a category.")

        # Check subtype
        if self.asset_type == 'DEVICE':
            if not hasattr(self, 'device'):
                raise ValidationError("Device asset must have a linked Device record.")
            # Ensure required fields in Device are filled
            required_fields = ['serial_number', 'device_type']
            for field in required_fields:
                if not getattr(self.device, field):
                    raise ValidationError(f"Device field '{field}' must be filled.")

        elif self.asset_type == 'NON_DEVICE':
            if not hasattr(self, 'non_device'):
                raise ValidationError("Non-Device asset must have a linked NonDeviceAsset record.")
            # Ensure required fields in NonDeviceAsset are filled
            required_fields = ['name', 'quantity']
            for field in required_fields:
                value = getattr(self.non_device, field)
                if value is None or (isinstance(value, str) and value.strip() == ''):
                    raise ValidationError(f"NonDeviceAsset field '{field}' must be filled.")

    # ------------------------
    # Save override
    # ------------------------
    def save(self, *args, **kwargs):
        self.full_clean()  # runs clean() to enforce all validation
        super().save(*args, **kwargs)


class DeviceType(models.Model):
    name = models.CharField(max_length=50, unique=True)
    category = models.ForeignKey(AssetCategory, on_delete=models.PROTECT, related_name='device_types')

    def __str__(self):
        return self.name

class Device(models.Model):
    asset = models.OneToOneField(
        Asset,
        on_delete=models.CASCADE,
        related_name='device',
        limit_choices_to={'asset_type': 'DEVICE'},
    )
    device_type = models.ForeignKey(DeviceType, on_delete=models.PROTECT)
    serial_number = models.CharField(max_length=100, unique=True)
    program = models.CharField(max_length=100, blank=True, null=True)
    partner = models.CharField(max_length=100, blank=True, null=True)
    partner_number = models.CharField(max_length=100, blank=True, null=True)
    additional_notes = models.TextField(blank=True)

    def __str__(self):
        return f"{self.device_type} ({self.serial_number})"

class NonDeviceAsset(models.Model):
    asset = models.OneToOneField(
        Asset,
        on_delete=models.CASCADE,
        related_name='non_device',
        limit_choices_to={'asset_type': 'NON_DEVICE'},
    )
    name = models.CharField(max_length=150)
    quantity = models.PositiveIntegerField()
    additional_notes = models.TextField(blank=True)

    def __str__(self):
        return f"{self.name} (Qty: {self.quantity})"
