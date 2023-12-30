import 'package:gem_kit/api/gem_sdksettings.dart';
import 'package:magic_maps/repositories/sdk_settings_repository.dart';

class SdkSettingsRepositoryImplementation implements SdkSettingsRepository {
  final _token =
      "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIzZDkxNTBhNS1hZGUxLTQyMDctOWYwZS03NjEyMjQ4ZWFkZjMiLCJleHAiOjE4OTMzNjI0MDAsImlzcyI6IkdlbmVyYWwgTWFnaWMiLCJqdGkiOiI5ZThmMTk3YS03MDlkLTQwZDgtOGI5NS1mZDZhNWU5ZjMwM2IiLCJuYmYiOjE3MDM5NTU3MDR9.awn1pB7d6aFlH_B4Vt2QGWEMFVpZ270T235QkL2iL_iDdfSxNsLRJrhW-uf56noGhXzlZ0uCIvT329PpvlYvfg";

  @override
  void setAppAuthorization() {
    SdkSettings.setAppAuthorization(_token);
  }
}