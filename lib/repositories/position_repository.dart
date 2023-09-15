import 'package:gem_kit/api/gem_coordinates.dart';

abstract interface class PositionRepository {
  Future<void> initPositionService();

  Future<bool> requestPermission();

  Future<void> setLiveDataSource();

  Future<void> startFollowingPosition();

  Coordinates getCurrentPosition();
}