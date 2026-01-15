from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.views import APIView
from django.contrib.auth import get_user_model, authenticate
from accounts.permissions import get_admin_scope
from .serializers import (
    UserRegistrationSerializer, 
    UserLoginSerializer, 
    UserUpdateSerializer, 
    LogoutSerializer, 
    ChangePasswordSerializer, 
    AdminUserListSerializer
)

User = get_user_model()

class UserRegistrationView(generics.CreateAPIView):
    serializer_class = UserRegistrationSerializer
    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        return Response({
            "message": "User registered successfully.",
            "user": {
                "id": user.id,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "username": user.username,
                "email": user.email,
                "user_type": user.user_type,
                "profile_complete": user.profile_complete,
                "is_admin": user.is_admin,
            }
        }, status=status.HTTP_201_CREATED)

class UserLoginView(generics.GenericAPIView):
    serializer_class = UserLoginSerializer
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']

        tokens = serializer.create_tokens(user)

        return Response({
            "message": "Login successful",
            "user": {
                "id": user.id,
                "username": user.username,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "email": user.email,
                "user_type": user.user_type,
                "profile_complete": user.profile_complete,
                "is_admin": user.is_admin,
            },
            "tokens": tokens
        }, status=status.HTTP_200_OK)

class UpdateAccountView(APIView):
    permission_classes = [IsAuthenticated]

    def put(self, request):
        user = request.user
        if not user.profile_complete:
            return Response(
                {"error": "Complete profile before updating account details."},
                status=status.HTTP_403_FORBIDDEN
            )

        serializer = UserUpdateSerializer(
            user,
            data=request.data,
            partial=True,
            context={'request': request}
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response({
            "message": "Account updated successfully",
            "user": serializer.data
        }, status=status.HTTP_200_OK)

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = LogoutSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            {"message": "Logged out successfully"},
            status=status.HTTP_205_RESET_CONTENT
        )

class ChangePasswordView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user
        serializer = ChangePasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        if not user.check_password(serializer.validated_data['old_password']):
            return Response(
                {"old_password": "Incorrect password"},
                status=status.HTTP_400_BAD_REQUEST
            )

        user.set_password(serializer.validated_data['new_password'])
        user.save()
        return Response(
            {"message": "Password changed successfully"},
            status=status.HTTP_200_OK
        )

class AdminChangeUserPasswordView(generics.UpdateAPIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, user_id):
        admin_user = request.user
        if not admin_user.is_admin:
            return Response(
                {"error": "Admin access required."},
                status=status.HTTP_403_FORBIDDEN
            )

        try:
            target_user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)

        scope_filter = get_admin_scope(admin_user)
        if scope_filter is not None:
            if not User.objects.filter(id=target_user.id, **scope_filter).exists():
                return Response(
                    {"error": "You cannot reset password for this user."},
                    status=status.HTTP_403_FORBIDDEN
                )

        new_password = request.data.get("new_password")
        if not new_password:
            return Response(
                {"error": "New password is required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        target_user.set_password(new_password)
        target_user.save()
        return Response(
            {"message": f"Password updated successfully for {target_user.username}."},
            status=status.HTTP_200_OK
        )

class AdminUserListView(generics.ListAPIView):
    serializer_class = AdminUserListSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        admin_user = self.request.user
        if not admin_user.is_admin:
            return User.objects.none()

        scope_filter = get_admin_scope(admin_user)
        if scope_filter is None:
            return User.objects.none()
            
        return User.objects.filter(**scope_filter).order_by('username')
