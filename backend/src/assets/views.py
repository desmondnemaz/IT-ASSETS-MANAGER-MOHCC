from rest_framework import viewsets, filters 
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from .models import Asset, AssetCategory, DeviceType
from .serializers import (
    AssetSerializer, 
    AssetCategorySerializer, 
    DeviceTypeSerializer
)

class AssetCategoryViewSet(viewsets.ModelViewSet):
    queryset = AssetCategory.objects.all()
    serializer_class = AssetCategorySerializer
    permission_classes = [IsAuthenticated]

class DeviceTypeViewSet(viewsets.ModelViewSet):
    queryset = DeviceType.objects.all()
    serializer_class = DeviceTypeSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['category']
    search_fields = ['name']

class AssetViewSet(viewsets.ModelViewSet):
    queryset = Asset.objects.all().select_related('category', 'current_station', 'device', 'non_device')
    serializer_class = AssetSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['asset_type', 'category', 'current_station', 'status', 'condition']
    search_fields = ['asset_code', 'device__serial_number', 'device__program']
    ordering_fields = ['created_at', 'status']
    ordering = ['-created_at']
