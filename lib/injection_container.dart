import 'package:gem_kit/gem_kit_map_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:magic_maps/repositories/implementations/landmark_repository_implementation.dart';
import 'package:magic_maps/repositories/implementations/navigation_repository_implementation.dart';
import 'package:magic_maps/repositories/implementations/position_repository_implementation.dart';
import 'package:magic_maps/repositories/implementations/sdk_settings_repository_implementation.dart';
import 'package:magic_maps/repositories/implementations/search_repository_implementation.dart';
import 'package:magic_maps/repositories/landmark_repository.dart';
import 'package:magic_maps/repositories/navigation_repository.dart';
import 'package:magic_maps/repositories/position_repository.dart';
import 'package:magic_maps/repositories/sdk_settings_repository.dart';
import 'package:magic_maps/repositories/search_repository.dart';

class InjectionContainer {
  static final singleton = GetIt.instance;

  static void init(GemMapController controller) {
    singleton.registerLazySingleton<LandmarkRepository>(() => LandmarkRepositoryImplementation(controller));
    singleton.registerLazySingleton<SdkSettingsRepository>(() => SdkSettingsRepositoryImplementation());
    singleton.registerLazySingleton<PositionRepository>(() => PositionRepositoryImplementation(controller));
    singleton.registerLazySingleton<SearchRepository>(() => SearchRepositoryImplementation(controller));
    singleton.registerLazySingleton<NavigationRepository>(() => NavigationRepositoryImplementation(controller));
  }
}