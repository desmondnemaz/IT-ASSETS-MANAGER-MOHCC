from rest_framework import serializers
from .models import Province, District, Station

class ProvinceSerializer(serializers.ModelSerializer):
    """
    Serializer for the Province model.
    Read-only exposure of province ID, name, and suffix.
    """
    class Meta:
        model = Province
        fields = ['id', 'province_name', 'province_suffix']


class DistrictSerializer(serializers.ModelSerializer):
    """
    Serializer for the District model.
    Includes the province ID for filtering/context.
    """
    class Meta:
        model = District
        fields = ['id', 'district_name', 'province', 'district_suffix']


class StationSerializer(serializers.ModelSerializer):
    """
    Serializer for the Station model.
    Includes formatted names for province and district for easier frontend display.
    """
    province_name = serializers.CharField(source='province.province_name', read_only=True)
    district_name = serializers.CharField(source='district.district_name', read_only=True)
    station_type_display = serializers.CharField(source='get_station_type_display', read_only=True)

    class Meta:
        model = Station
        fields = [
            'id', 
            'station_name', 
            'station_address', 
            'station_type',
            'station_type_display',
            'province', 
            'province_name',
            'district', 
            'district_name',
            'station_code'
        ]
