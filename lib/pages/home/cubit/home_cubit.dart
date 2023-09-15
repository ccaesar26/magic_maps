import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_routingservice.dart' as gem;
import 'package:gem_kit/gem_kit_basic.dart';
import 'package:gem_kit/gem_kit_map_controller.dart';
import 'package:magic_maps/pages/favorites/favorites.dart';
import 'package:magic_maps/injection_container.dart';
import 'package:magic_maps/repositories/landmark_repository.dart';
import 'package:magic_maps/repositories/navigation_repository.dart';
import 'package:magic_maps/repositories/position_repository.dart';
import 'package:magic_maps/repositories/sdk_settings_repository.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  late final LandmarkRepository _landmarkRepository;
  late final SdkSettingsRepository _sdkSettingsRepository;
  late final PositionRepository _positionRepository;
  late final NavigationRepository _navigationRepository;

  void initRepository()  {
    _landmarkRepository = InjectionContainer.singleton.get<LandmarkRepository>();
    _sdkSettingsRepository = InjectionContainer.singleton.get<SdkSettingsRepository>();
    _positionRepository = InjectionContainer.singleton.get<PositionRepository>();
    _navigationRepository = InjectionContainer.singleton.get<NavigationRepository>();
  }

  late GemMapController _mapController;
  gem.LandmarkList favoritesList = gem.LandmarkList();

  Future<void> onMapCreated(GemMapController controller) async {
    _mapController = controller;

    InjectionContainer.init(controller);
    initRepository();

    emit(state.copyWith(focusedLandmark: null, isLandmarkFavorite: false));

    await _landmarkRepository.createFavoritesStore();

    _registerLandmarkTapCallback();

    _sdkSettingsRepository.setAppAuthorization();

    await _positionRepository.initPositionService();

    await _navigationRepository.initServices();
  }

  Future<void> onSearchPressed(BuildContext context) async {
    final x = MediaQuery.of(context).size.width / 2;
    final y = MediaQuery.of(context).size.height / 2;
    final mapCoordinates = _landmarkRepository.getCoordinates(x, y);

    final result = await Navigator.pushNamed(
      context,
      '/search',
      arguments: mapCoordinates,
    ) as Landmark?;

    if (result == null) {
      return;
    }

    await _landmarkRepository.addToHistoryStore(result);

    await _landmarkRepository.createLandmarkList();

    await _landmarkRepository.handleResultedLandmark(result);
  }

  Future<void> getInfo() async {
    final panelInfo = await _landmarkRepository.getPanelInfo(state.focusedLandmark!);

    emit(state.copyWith(panelInfo: panelInfo));
  }

  _registerLandmarkTapCallback() {
    _mapController.registerTouchCallback((pos) async {
      final lmk = await _landmarkRepository.getFocusedLandmark(pos);

      if (lmk == null) {
        _navigationRepository.selectRoute(pos);
        return;
      }

      emit(state.copyWith(
        focusedLandmark: lmk,
        showPanel: true,
      ));

      await _checkIfFavourite();
    });
  }

  onFavouritesButtonPressed(BuildContext context) async {
    // Fetch landmarks from the store
    favoritesList = await _landmarkRepository.getFavoritesList();

    // Navigating to favorites screen then the result will be the selected item in the list.

    final result = await Navigator.pushNamed(context, '/favorites');
    // Create a list of landmarks to highlight.

    await _landmarkRepository.createLandmarkList();

    if (result is! Landmark) {
      return;
    }

    emit(state.copyWith(
      showPanel: true,
    ));

    await _landmarkRepository.handleResultedLandmark(result);

    // setState(() {
    // focusedLandmark = result;
    emit(state.copyWith(
      focusedLandmark: result,
      //isLoading: false,
    ));
    // });
    await _checkIfFavourite();
  }

  void onCancelTap() {
    emit(state.copyWith(showPanel: false));

    // Remove landmark highlights from the map
    _landmarkRepository.unhighlightAll();
  }

  void onFavoritesTap() async {
    //emit(state.copyWith(isLoading: true));

    await _checkIfFavourite();

    if (state.isLandmarkFavorite!) {
      // Remove the landmark from the store.
      await _landmarkRepository.removeFromFavoritesStore(state.focusedLandmark!);
      emit(state.copyWith(
        isLandmarkFavorite: false,
      ));
    } else {
      // Add the landmark to the store.
      await _landmarkRepository.addToFavoritesStore(state.focusedLandmark!);
      emit(state.copyWith(
        isLandmarkFavorite: true,
      ));
    }
  }

  _checkIfFavourite() async {
    final value = await _landmarkRepository.checkIfFavorite(state.focusedLandmark!);
    emit(state.copyWith(isLandmarkFavorite: value));
  }

  onFollowPositionButtonPressed() async {
    if(! await _positionRepository.requestPermission()) {
      return;
    }

    await _positionRepository.setLiveDataSource();

    await _positionRepository.startFollowingPosition();
  }

  void calculateRouteToLandmark() async {
    if (state.focusedLandmark == null) {
      return;
    }

    final currentPosition = _positionRepository.getCurrentPosition();

    _navigationRepository.addCoordinates(currentPosition);

    _navigationRepository.addCoordinatesFromLandmark(state.focusedLandmark!);

    await _navigationRepository.calculateRoute();

    emit(state.copyWith(
      showPanel: false,
      haveRoutes: true,
    ));
  }

  void removeRoutes() async {
    await _navigationRepository.removeRoutes();

    _landmarkRepository.unhighlightAll();

    emit(state.copyWith(
      showPanel: false,
      haveRoutes: false,
    ));
  }

  void startSimulation() async {
    await _navigationRepository.startSimulation();
    emit(state.copyWith(
      isNavigating: true,
    ));
  }

  void stopSimulation() async {
    await _navigationRepository.stopSimulation();
    emit(state.copyWith(
      isNavigating: false,
    ));
  }
}
