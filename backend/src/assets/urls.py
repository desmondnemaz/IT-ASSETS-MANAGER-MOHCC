from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import AssetViewSet, AssetCategoryViewSet, DeviceTypeViewSet

router = DefaultRouter()
router.register(r'categories', AssetCategoryViewSet)
router.register(r'device-types', DeviceTypeViewSet)
router.register(r'assets', AssetViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
