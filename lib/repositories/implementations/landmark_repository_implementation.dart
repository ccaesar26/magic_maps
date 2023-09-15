import 'dart:math';
import 'dart:typed_data';

import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_landmarkstore.dart';
import 'package:gem_kit/api/gem_landmarkstoreservice.dart';
import 'package:gem_kit/api/gem_mapviewrendersettings.dart';
import 'package:gem_kit/api/gem_routingservice.dart';
import 'package:gem_kit/api/gem_types.dart';
import 'package:gem_kit/gem_kit_map_controller.dart';
import 'package:magic_maps/pages/favorites/view/panel_info.dart';
import 'package:magic_maps/pages/favorites/view/utility.dart';

import '../landmark_repository.dart';

class LandmarkRepositoryImplementation implements LandmarkRepository {
  LandmarkRepositoryImplementation(this._mapController);

  final GemMapController _mapController;

  late LandmarkStoreService _landmarkStoreService;
  final _favoritesStoreName = 'Favorites';
  LandmarkStore? _favoritesStore;

  LandmarkList? _landmarkList;

  @override
  Future<void> createFavoritesStore() async {
    _landmarkStoreService =
        await LandmarkStoreService.create(_mapController.mapId);

    _favoritesStore =
        await _landmarkStoreService.getLandmarkStoreByName(_favoritesStoreName);
    _favoritesStore ??=
        await _landmarkStoreService.createLandmarkStore(_favoritesStoreName);
  }

  @override
  Future<Landmark?> getFocusedLandmark(Point pos) async {
    // Select the object at the tap position.
    await _mapController.selectMapObjects(pos);

    // Get the selected landmarks.
    final landmarks = await _mapController.cursorSelectionLandmarks();

    final landmarksSize = await landmarks.size();

    // Check if there is a selected Landmark.
    if (landmarksSize == 0) return null;

    // Highlight the landmark on the map.
    _mapController.activateHighlight(landmarks);

    final lmk = await landmarks.at(0);

    _centerOnLandmark(lmk);

    return lmk;
  }

  @override
  Future<bool> checkIfFavorite(Landmark landmark) async {
    final focusedLandmarkCoordinates = landmark.getCoordinates();
    final favourites = await _favoritesStore!.getLandmarks();
    final favoritesSize = await favourites.size();

    for (var i = 0; i < favoritesSize; i++) {
      final lmk = await favourites.at(i);
      final coordinates = lmk.getCoordinates();

      if (focusedLandmarkCoordinates.latitude == coordinates.latitude &&
          focusedLandmarkCoordinates.longitude == coordinates.longitude) {
        return true;
      }
    }

    return false;
  }

  @override
  Future<LandmarkList> getFavoritesList() async {
    return await _favoritesStore!.getLandmarks();
  }

  @override
  Coordinates? getCoordinates(double x, double y) {
    return _mapController
        .transformScreenToWgs(XyType(x: x.toInt(), y: y.toInt()));
  }

  @override
  Future<void> addToHistoryStore(Landmark landmark) async {
    var historyStore =
        await _landmarkStoreService.getLandmarkStoreByName("History");

    if (historyStore == null) {
      historyStore = await _landmarkStoreService.createLandmarkStore("History");

      await historyStore.addLandmark(landmark);
    }
  }

  @override
  Future<void> createLandmarkList() async {
    _landmarkList = await LandmarkList.create(_mapController.mapId);
  }

  @override
  Future<void> handleResultedLandmark(Landmark landmark) async {
    _addToLandmarkList(landmark);
    _highlightLandmarkList();
    _centerOnLandmark(landmark);
  }

  Future<void> _addToLandmarkList(Landmark landmark) async {

    await _landmarkList!.push_back(landmark);
  }

  Future<void> _highlightLandmarkList() async {
    await _mapController.activateHighlight(
      _landmarkList!,
      renderSettings: RenderSettings(),
    );
  }

  Future<void> _centerOnLandmark(Landmark landmark) async {
    final coordinates = landmark.getCoordinates();

    await _mapController.centerOnCoordinates(coordinates);
  }

  @override
  Future<void> unhighlightAll() async {
    await _mapController.deactivateHighlight();
  }

  @override
  Future<PanelInfo> getPanelInfo(Landmark landmark) async {
    late Uint8List? iconFuture;
    late String nameFuture;
    late Coordinates coordinatesFuture;
    late String coordinatesFutureText;
    late List<LandmarkCategory> categoriesFuture;

    iconFuture = await _decodeLandmarkIcon(landmark);
    nameFuture = landmark.getName();
    coordinatesFuture = landmark.getCoordinates();
    coordinatesFutureText =
        "${coordinatesFuture.latitude.toString()}, ${coordinatesFuture.longitude.toString()}";
    categoriesFuture = landmark.getCategories();

    return PanelInfo(
      image: iconFuture,
      name: nameFuture,
      categoryName:
          categoriesFuture.isNotEmpty ? categoriesFuture.first.name! : '',
      formattedCoords: coordinatesFutureText,
    );
  }

  @override
  Future<void> addToFavoritesStore(Landmark landmark) async {
    await _favoritesStore!.addLandmark(landmark);
  }

  @override
  Future<void> removeFromFavoritesStore(Landmark landmark) async {
    await _favoritesStore!.removeLandmark(landmark);
  }

  @override
  Future<List<Landmark>> fromLandmarkListToListOfLandmarks(LandmarkList landmarkList) async {
    var length = await landmarkList.size();
    List<Landmark> landmarks = [];

    for (int i = 0; i < length; i++) {
      Landmark landmark = await landmarkList.at(i);
      landmarks.add(landmark);
    }
    return landmarks.reversed.toList();
  }

  Future<Uint8List?> _decodeLandmarkIcon(Landmark landmark) async {
    final data = landmark.getImage(100, 100);

    return decodeImageData(data);
  }
}
