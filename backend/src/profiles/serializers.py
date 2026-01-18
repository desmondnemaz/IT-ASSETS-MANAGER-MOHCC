# profiles/serializers.py
from rest_framework import serializers
from .models import MOHProfile, NGOProfile
from accounts.models import User

class MOHProfileSerializer(serializers.ModelSerializer):
    station_name = serializers.ReadOnlyField(source='station.station_name')
    province_name = serializers.ReadOnlyField(source='station.province.province_name')
    district_name = serializers.ReadOnlyField(source='station.district.district_name')

    class Meta:
        model = MOHProfile
        fields = ('department', 'position', 'station', 'station_name', 'province_name', 'district_name')

class NGOProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = NGOProfile
        fields = ('organization_name', 'position')
