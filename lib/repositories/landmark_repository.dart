import 'dart:math';

import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_routingservice.dart';
import 'package:magic_maps/pages/favorites/view/panel_info.dart';

abstract interface class LandmarkRepository {
  Future<void> createFavoritesStore();

  Future<Landmark?> getFocusedLandmark(Point pos);

  Future<bool> checkIfFavorite(Landmark landmark);

  Coordinates? getCoordinates(double x, double y);

  Future<void> addToHistoryStore(Landmark landmark);

  Future<void> createLandmarkList();

  Future<void> handleResultedLandmark(Landmark landmark);

  Future<void> unhighlightAll();

  Future<PanelInfo> getPanelInfo(Landmark landmark);

  Future<LandmarkList> getFavoritesList();

  Future<void> addToFavoritesStore(Landmark landmark);

  Future<void> removeFromFavoritesStore(Landmark landmark);

  Future<List<Landmark>> fromLandmarkListToListOfLandmarks(LandmarkList landmarkList);
}