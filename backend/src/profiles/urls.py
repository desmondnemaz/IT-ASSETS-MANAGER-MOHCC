# profiles/urls.py
from django.urls import path
from .views import FinishProfileView ,  UpdateProfileView, UserProfileView

urlpatterns = [
    path('update/', UpdateProfileView.as_view(), name='update-profile'),
    path('finish/', FinishProfileView.as_view(), name='finish-profile'),
    path('me/', UserProfileView.as_view(), name='get-profile'),
]
