from django.contrib import admin
from django.core.exceptions import ValidationError
from .models import Asset, AssetCategory, DeviceType, Device, NonDeviceAsset


# ------------------------
# Inline for Device
# ------------------------
class DeviceInline(admin.StackedInline):
    model = Device
    extra = 0
    min_num = 1
    max_num = 1
    fk_name = 'asset'
    fields = ('device_type', 'serial_number', 'program', 'partner', 'partner_number', 'additional_notes')
    verbose_name_plural = 'Device Details'


# ------------------------
# Inline for NonDeviceAsset
# ------------------------
class NonDeviceAssetInline(admin.StackedInline):
    model = NonDeviceAsset
    extra = 0
    min_num = 1
    max_num = 1
    fk_name = 'asset'
    fields = ('name', 'quantity', 'additional_notes')
    verbose_name_plural = 'Non-Device Details'


# ------------------------
# Asset Admin
# ------------------------
@admin.register(Asset)
class AssetAdmin(admin.ModelAdmin):
    list_display = ( 'asset_type', 'category', 'current_station', 'status', 'condition', 'created_at')
    list_filter = ('asset_type', 'status', 'condition', 'category')
    search_fields = ('asset_code',)

    # Dynamically choose inline based on asset_type
    def get_inline_instances(self, request, obj=None):
        inlines = []
        if obj:
            if obj.asset_type == 'DEVICE':
                inlines.append(DeviceInline(self.model, self.admin_site))
            elif obj.asset_type == 'NON_DEVICE':
                inlines.append(NonDeviceAssetInline(self.model, self.admin_site))
        return inlines


# ------------------------
# AssetCategory Admin
# ------------------------
@admin.register(AssetCategory)
class AssetCategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    search_fields = ('name',)


# ------------------------
# DeviceType Admin
# ------------------------
@admin.register(DeviceType)
class DeviceTypeAdmin(admin.ModelAdmin):
    list_display = ('name', 'category')
    list_filter = ('category',)
    search_fields = ('name',)
