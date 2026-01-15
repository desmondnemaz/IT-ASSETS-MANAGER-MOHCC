from django.contrib import admin
from .models import Province, District, Station

# ---------------------------
# Province Admin
# ---------------------------
@admin.register(Province)
class ProvinceAdmin(admin.ModelAdmin):
    list_display = ('province_name', 'province_suffix')
    search_fields = ('province_name', 'province_suffix')

# ---------------------------
# District Admin
# ---------------------------
@admin.register(District)
class DistrictAdmin(admin.ModelAdmin):
    list_display = ('district_name', 'province', 'district_suffix')
    search_fields = ('district_name', )
    list_filter = ('province',)  # allows filtering by province in admin

# ---------------------------
# Station Admin
# ---------------------------
@admin.register(Station)
class StationAdmin(admin.ModelAdmin):
    list_display = ('station_name', 'station_code', 'station_type', 'province', 'district', 'station_suffix')
    list_filter = ('station_type', 'province', 'district')
    search_fields = ('station_name', 'station_code')
    autocomplete_fields = ('province', 'district')  # makes FK selection easier
