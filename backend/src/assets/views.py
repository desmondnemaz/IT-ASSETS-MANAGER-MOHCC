from rest_framework import viewsets, filters 
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from accounts.permissions import IsAssetAdmin, get_admin_scope
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
    permission_classes = [IsAuthenticated, IsAssetAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['asset_type', 'category', 'current_station', 'status', 'condition']
    search_fields = ['asset_code', 'device__serial_number', 'device__program']
    ordering_fields = ['created_at', 'status']
    ordering = ['-created_at']

    def get_queryset(self):
        """
        Filter assets based on user jurisdiction.
        """
        qs = super().get_queryset()
        
        # Admin scope filtering
        admin_scope = get_admin_scope(self.request.user)
        
        if admin_scope is None:
            return qs.none() 
            
        if not admin_scope: # Empty dict = HQ = All access
            return qs
            
        # Map scope keys from 'station' to 'current_station'
        # e.g. {'station__province': ...} -> {'current_station__province': ...}
        # e.g. {'station': ...} -> {'current_station': ...}
        
        asset_filters = {}
        for key, value in admin_scope.items():
            if key == 'station':
                asset_filters['current_station'] = value
            elif key.startswith('station__'):
                new_key = key.replace('station__', 'current_station__', 1)
                asset_filters[new_key] = value
                
        return qs.filter(**asset_filters)

