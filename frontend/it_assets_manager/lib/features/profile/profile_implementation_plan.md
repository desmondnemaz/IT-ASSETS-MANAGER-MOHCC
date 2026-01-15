# Profile View & Edit Implementation Plan

Implement the ability for users to view and update their profile information.

## Proposed Changes

### [Component] Profile Feature

#### [NEW] [profile_models.dart](file:///d:/flutterApps/IT-ASSETS-MANAGER-MOHCC/frontend/it_assets_manager/lib/features/profile/models/profile_models.dart)
- Define `UserProfileResponse` to handle the combined user and profile data from the backend.
- Define `MOHProfile` and `NGOProfile` models.

#### [MODIFY] [profile_repository.dart](file:///d:/flutterApps/IT-ASSETS-MANAGER-MOHCC/frontend/it_assets_manager/lib/features/profile/data/profile_repository.dart)
- Add `getProfile()` to fetch data from `/api/profiles/me/`.
- Add `updateProfile(Map<String, dynamic> data)` to update data via `/api/profiles/update/`.

#### [MODIFY] [profile_provider.dart](file:///d:/flutterApps/IT-ASSETS-MANAGER-MOHCC/frontend/it_assets_manager/lib/features/profile/providers/profile_provider.dart)
- Add state to store the fetched profile.
- Add `fetchProfile()` and `updateProfile()` methods.

#### [NEW] [profile_screen.dart](file:///d:/flutterApps/IT-ASSETS-MANAGER-MOHCC/frontend/it_assets_manager/lib/features/profile/presentation/profile_screen.dart)
- UI to display user details and profile information.
- Use `ResponsiveSize` for layout.

#### [NEW] [edit_profile_screen.dart](file:///d:/flutterApps/IT-ASSETS-MANAGER-MOHCC/frontend/it_assets_manager/lib/features/profile/presentation/edit_profile_screen.dart)
- UI to edit profile fields (Department, Position, Station for MOH; Organization, Position for NGO).

#### [MODIFY] [app_router.dart](file:///d:/flutterApps/IT-ASSETS-MANAGER-MOHCC/frontend/it_assets_manager/lib/core/router/app_router.dart)
- Add `/profile` and `/profile/edit` routes.

#### [MODIFY] [dashboard_screen.dart](file:///d:/flutterApps/IT-ASSETS-MANAGER-MOHCC/frontend/it_assets_manager/lib/features/dashboard/presentation/dashboard_screen.dart)
- Add "Profile" link to the Drawer/Sidebar.

## Verification Plan

### Manual Verification
- Log in as MOH user, go to Profile, verify data.
- Edit MOH profile, verify success message and updated data.
- Log in as NGO user, go to Profile, verify data.
- Edit NGO profile, verify success message and updated data.
- Test responsiveness on mobile and desktop.
