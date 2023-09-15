import 'dart:math';

import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_progresslistener.dart';

abstract interface class NavigationRepository {
  Future<void> initServices();

  bool get haveRoutes;

  void addCoordinates(Coordinates coordinates);

  void addCoordinatesFromLandmark(Landmark landmark);

  Future<ProgressListener> calculateRoute();

  Future<void> removeRoutes();

  Future<void> selectRoute(Point pos);

  Future<void> startSimulation();

  Future<void> stopSimulation();
}