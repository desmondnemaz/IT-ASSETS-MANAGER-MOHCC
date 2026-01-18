from rest_framework import serializers
from .models import Asset, Device, NonDeviceAsset, DeviceType, AssetCategory


class AssetCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = AssetCategory
        fields = ['id', 'name', 'description']


class DeviceTypeSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)

    class Meta:
        model = DeviceType
        fields = ['id', 'name', 'category', 'category_name']


class DeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Device
        fields = ['device_type', 'serial_number', 'program', 'partner', 'partner_number', 'additional_notes']


class NonDeviceAssetSerializer(serializers.ModelSerializer):
    class Meta:
        model = NonDeviceAsset
        fields = ['name', 'quantity', 'additional_notes']


class AssetSerializer(serializers.ModelSerializer):
    device = DeviceSerializer(required=False)
    non_device = NonDeviceAssetSerializer(required=False)

    class Meta:
        model = Asset
        fields = [
            'id', 'asset_code', 'asset_type', 'category', 'current_station',
            'status', 'condition', 'created_at', 'device', 'non_device'
        ]

    def validate(self, data):
        asset_type = data.get('asset_type') or getattr(self.instance, 'asset_type', None)
        if asset_type == 'DEVICE' and 'device' not in data:
            raise serializers.ValidationError("Device data must be provided for DEVICE asset_type.")
        if asset_type == 'NON_DEVICE' and 'non_device' not in data:
            raise serializers.ValidationError("NonDeviceAsset data must be provided for NON_DEVICE asset_type.")
        return data

    def create(self, validated_data):
        device_data = validated_data.pop('device', None)
        non_device_data = validated_data.pop('non_device', None)

        asset = Asset.objects.create(**validated_data)

        if asset.asset_type == 'DEVICE':
            Device.objects.create(asset=asset, **device_data)
        elif asset.asset_type == 'NON_DEVICE':
            NonDeviceAsset.objects.create(asset=asset, **non_device_data)

        return asset

    def update(self, instance, validated_data):
        device_data = validated_data.pop('device', None)
        non_device_data = validated_data.pop('non_device', None)

        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        if instance.asset_type == 'DEVICE' and device_data:
            Device.objects.update_or_create(asset=instance, defaults=device_data)
        elif instance.asset_type == 'NON_DEVICE' and non_device_data:
            NonDeviceAsset.objects.update_or_create(asset=instance, defaults=non_device_data)

        return instance
