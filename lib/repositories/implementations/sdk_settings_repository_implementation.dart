import 'package:gem_kit/api/gem_sdksettings.dart';
import 'package:magic_maps/repositories/sdk_settings_repository.dart';

class SdkSettingsRepositoryImplementation implements SdkSettingsRepository {
  final _token =
      "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIyNjEwNDBmNy05ODVhLTRiYjUtYTVhYS04MmFjZWQ2ZGM0YmIiLCJleHAiOjE3NzQ0NzYwMDAsImlzcyI6IkdlbmVyYWwgTWFnaWMiLCJqdGkiOiIzMjljN2MxNi05MGVkLTQwNDItOGZkYS01ODExNmY0MDEwM2YiLCJuYmYiOjE2OTQ1ODUwMTJ9.jRNP6eFHQv4JShg-ovRGbbV8v625nTx0FvZhv74VQYC9_iGYoBc6-JUNdU7rec7enSaKw-XzkmWD-PGAqxK0rg";

  @override
  void setAppAuthorization() {
    SdkSettings.setAppAuthorization(_token);
  }
}