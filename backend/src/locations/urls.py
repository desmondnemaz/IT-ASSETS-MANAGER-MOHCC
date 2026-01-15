from django.urls import path
from .views import ProvinceListView, DistrictListView, StationListView

# URL patterns for location lookups
urlpatterns = [
    path('provinces/', ProvinceListView.as_view(), name='province-list'),
    path('districts/', DistrictListView.as_view(), name='district-list'),
    path('stations/', StationListView.as_view(), name='station-list'),
]
