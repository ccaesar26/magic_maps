import 'package:flutter/foundation.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_mapviewpreferences.dart';
import 'package:gem_kit/gem_kit_map_controller.dart';
import 'package:gem_kit/gem_kit_position.dart';
import 'package:permission_handler/permission_handler.dart';

import '../position_repository.dart';

class PositionRepositoryImplementation implements PositionRepository {
  PositionRepositoryImplementation(this._mapController);

  final GemMapController _mapController;

  late PermissionStatus _locationPermissionStatus = PermissionStatus.denied;

  late PositionService _positionService;
  late bool _hasLiveDataSource = false;
  late Coordinates currentPosition;

  @override
  Future<void> initPositionService() async {
    _positionService = await PositionService.create(_mapController.mapId);

    await _positionService.addPositionListener((pos) {
      currentPosition = pos.coordinates;
    });
  }

  @override
  Future<bool> requestPermission() async {
    if (kIsWeb) {
      _locationPermissionStatus = PermissionStatus.granted;
    } else {
      // For Android & iOS platforms, permission_handler package is used to ask for permissions
      _locationPermissionStatus = await Permission.locationWhenInUse.request();
    }

    if (_locationPermissionStatus != PermissionStatus.granted) {
      return false;
    }

    return true;
  }

  @override
  Future<void> setLiveDataSource() async {
    if (!_hasLiveDataSource) {
      _positionService.setLiveDataSource();
      _hasLiveDataSource = true;
    }
  }

  @override
  Future<void> startFollowingPosition() async {
    if (_locationPermissionStatus == PermissionStatus.granted) {
      // Optionally, we can set an animation
      final animation = GemAnimation(type: EAnimation.AnimationLinear);

      _mapController.startFollowingPosition(animation: animation);
    }
  }

  @override
  Coordinates getCurrentPosition() {
    return currentPosition;
  }
}