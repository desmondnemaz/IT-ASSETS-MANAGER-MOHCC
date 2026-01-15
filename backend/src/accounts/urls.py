# accounts/urls.py
from django.urls import path
from .views import UserRegistrationView, UserLoginView, UpdateAccountView, LogoutView, ChangePasswordView, AdminChangeUserPasswordView, AdminUserListView

urlpatterns = [
    path('register/', UserRegistrationView.as_view(), name='user-register'),
    path('login/', UserLoginView.as_view(), name='user-login'),
    path('me/update/', UpdateAccountView.as_view(), name='update-account'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('password/change/', ChangePasswordView.as_view(), name='change-password'),
    path('admin/users/', AdminUserListView.as_view(), name='admin-user-list'),
    path('admin/users/<int:user_id>/reset-password/', AdminChangeUserPasswordView.as_view(), name='admin-reset-password'),
]


