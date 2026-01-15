# profiles/views.py
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from profiles.permissions import IsProfileComplete
from rest_framework.response import Response
from .models import MOHProfile, NGOProfile
from .serializers import MOHProfileSerializer, NGOProfileSerializer
from accounts.models import User
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404

from .models import MOHProfile, NGOProfile
from .serializers import MOHProfileSerializer, NGOProfileSerializer

class FinishProfileView(generics.GenericAPIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user
        user_type = user.user_type

        if user_type == 'MOH':
            serializer = MOHProfileSerializer(data=request.data)
        elif user_type == 'NGO':
            serializer = NGOProfileSerializer(data=request.data)
        else:
            return Response({"error": "Invalid user type."}, status=status.HTTP_400_BAD_REQUEST)

        serializer.is_valid(raise_exception=True)

        # Save profile
        profile, created = None, None
        if user_type == 'MOH':
            profile, created = MOHProfile.objects.update_or_create(
                user=user,
                defaults=serializer.validated_data
            )
        elif user_type == 'NGO':
            profile, created = NGOProfile.objects.update_or_create(
                user=user,
                defaults=serializer.validated_data
            )

        # Mark user profile_complete = True
        user.profile_complete = True
        user.save()

        return Response({
            "message": "Profile completed successfully.",
            "profile": serializer.data,
            "profile_complete": user.profile_complete
        }, status=status.HTTP_200_OK)



# Update profile
class UpdateProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def put(self, request):
        user = request.user

        if not user.profile_complete:
            return Response(
                {"error": "Complete profile first."},
                status=status.HTTP_403_FORBIDDEN
            )

        # Determine profile model and serializer
        if user.user_type == 'MOH':
            profile = get_object_or_404(MOHProfile, user=user)
            serializer_class = MOHProfileSerializer
        elif user.user_type == 'NGO':
            profile = get_object_or_404(NGOProfile, user=user)
            serializer_class = NGOProfileSerializer
        else:
            return Response(
                {"error": "Invalid user type"},
                status=status.HTTP_400_BAD_REQUEST
            )

        serializer = serializer_class(profile, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response({
            "message": "Profile updated successfully",
            "profile": serializer.data
        }, status=status.HTTP_200_OK)


# profile-view
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import MOHProfile, NGOProfile
from .serializers import MOHProfileSerializer, NGOProfileSerializer

class UserProfileView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        user_type = user.user_type

        if user_type == 'MOH':
            try:
                profile = MOHProfile.objects.get(user=user)
                serializer = MOHProfileSerializer(profile)
            except MOHProfile.DoesNotExist:
                return Response({"error": "MOH profile not found"}, status=status.HTTP_404_NOT_FOUND)
        elif user_type == 'NGO':
            try:
                profile = NGOProfile.objects.get(user=user)
                serializer = NGOProfileSerializer(profile)
            except NGOProfile.DoesNotExist:
                return Response({"error": "NGO profile not found"}, status=status.HTTP_404_NOT_FOUND)
        else:
            return Response({"error": "Invalid user type"}, status=status.HTTP_400_BAD_REQUEST)

        return Response({
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
            "profile": serializer.data
        }, status=status.HTTP_200_OK)


