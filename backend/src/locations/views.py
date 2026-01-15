from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from .models import Province, District, Station
from .serializers import ProvinceSerializer, DistrictSerializer, StationSerializer

# ---------------------------------------------------------------------------
# PROVINCE VIEWS
# ---------------------------------------------------------------------------
class ProvinceListView(generics.ListAPIView):
    """
    API endpoint that allows provinces to be viewed.
    No filtering needed usually, as the list is small (10).
    """
    queryset = Province.objects.all().order_by('province_name')
    serializer_class = ProvinceSerializer
    permission_classes = [IsAuthenticated]


# ---------------------------------------------------------------------------
# DISTRICT VIEWS
# ---------------------------------------------------------------------------
class DistrictListView(generics.ListAPIView):
    """
    API endpoint that allows districts to be viewed.
    
    Query Parameters:
    - province_id: Filter districts by a specific province.
    """
    serializer_class = DistrictSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = District.objects.all().order_by('district_name')
        
        # Filter by province if provided in query params
        province_id = self.request.query_params.get('province_id')
        if province_id:
            queryset = queryset.filter(province_id=province_id)
            
        return queryset


# ---------------------------------------------------------------------------
# STATION VIEWS
# ---------------------------------------------------------------------------
class StationListView(generics.ListAPIView):
    """
    API endpoint that allows stations (Facilities/Offices) to be viewed.
    
    Query Parameters:
    - province_id: Filter by province
    - district_id: Filter by district
    - type: Filter by station type (HQ, PO, DO, FC)
    """
    serializer_class = StationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Station.objects.all().order_by('station_name')
        
        # --- Filtering Logic ---
        province_id = self.request.query_params.get('province_id')
        district_id = self.request.query_params.get('district_id')
        station_type = self.request.query_params.get('type')

        if province_id:
            queryset = queryset.filter(province_id=province_id)
        
        if district_id:
            queryset = queryset.filter(district_id=district_id)

        if station_type:
            queryset = queryset.filter(station_type=station_type)

        return queryset
