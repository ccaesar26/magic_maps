import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_landmarkstore.dart';
import 'package:gem_kit/api/gem_landmarkstoreservice.dart';
import 'package:gem_kit/api/gem_mapviewpreferences.dart';
import 'package:gem_kit/api/gem_mapviewrendersettings.dart';
import 'package:gem_kit/api/gem_routingservice.dart';
import 'package:gem_kit/api/gem_sdksettings.dart';
import 'package:gem_kit/api/gem_types.dart';
import 'package:gem_kit/gem_kit_map_controller.dart';
import 'package:gem_kit/gem_kit_position.dart';
import 'package:gem_kit/widget/gem_kit_map.dart';
import 'package:magic_maps/favorites/favorites.dart';
import 'package:magic_maps/search/search.dart';
import 'package:permission_handler/permission_handler.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Landmark? _focusedLandmark;
  late GemMapController _mapController;
  late LandmarkStoreService _landmarkStoreService;
  late LandmarkStore? _favoritesStore;
  late bool _isLandmarkFavorite;
  final favoritesStoreName = 'Favorites';

  final _token =
      "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIyNjEwNDBmNy05ODVhLTRiYjUtYTVhYS04MmFjZWQ2ZGM0YmIiLCJleHAiOjE2OTY1Mzk2MDAsImlzcyI6IkdlbmVyYWwgTWFnaWMiLCJqdGkiOiIwOTI2ZGQ5NC0yNjdkLTQ5MWMtYTM5ZS00ZDIxMDQzY2Q0MGQiLCJuYmYiOjE2OTM5ODM2NzV9.xaj0aijgsmHmvLzBZo6FoLjqkbaAgT4YopHf6pGkuD1kjCHfJXTVjq1bAFxn2m-PFXMT4wJh1ZOITqtrolC5Mg";

  @override
  void initState() {
    super.initState();
  }

  Future<void> onMapCreated(GemMapController controller) async {
    _mapController = controller;
    _focusedLandmark = null;
    _isLandmarkFavorite = false;


    _landmarkStoreService = await LandmarkStoreService.create(controller.mapId);
    _favoritesStore =
        await _landmarkStoreService.getLandmarkStoreByName(favoritesStoreName);
    _favoritesStore ??=
        await _landmarkStoreService.createLandmarkStore(favoritesStoreName);
    _registerLandmarkTapCallback();

    // Create the position service
    _positionService = await PositionService.create(controller.mapId);

    SdkSettings.setAppAuthorization(_token);
  }

  // Custom method for navigating to search screen
  _onPressed(BuildContext context) async {
// Taking the coordinates at the center of the screen as reference coordinates for search.
    final x = MediaQuery.of(context).size.width / 2;
    final y = MediaQuery.of(context).size.height / 2;
    final mapCoords =
        _mapController.transformScreenToWgs(XyType(x: x.toInt(), y: y.toInt()));

// Navigating to search screen. The result will be the selected search result(Landmark)
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SearchPage(
        controller: _mapController,
        coordinates: mapCoords!,
      ),
    ));

    var historyStore =
        await _landmarkStoreService.getLandmarkStoreByName("History");

    if (historyStore == null) {
      historyStore = await _landmarkStoreService.createLandmarkStore("History");

      await historyStore.addLandmark(result);
    }

// Creating a list of landmarks to highlight.
    LandmarkList landmarkList = await LandmarkList.create(_mapController.mapId);

    if (result is! Landmark) {
      return;
    }

// Adding the result to the landmark list.
    await landmarkList.push_back(result);
    final coords = result.getCoordinates();

// Activating the highlight
    await _mapController.activateHighlight(landmarkList,
        renderSettings: RenderSettings());

// Centering the map on the desired coordinates
    await _mapController.centerOnCoordinates(coords);
  }

  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 64,
        shadowColor: Colors.black12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        // systemOverlayStyle: SystemUiOverlayStyle(
        //   statusBarColor: Theme.of(context).colorScheme.inversePrimary,
        //   systemNavigationBarColor: Colors.transparent,
        // ),
        titleSpacing: 4,
        leading: IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: () {},
        ),
        title: ElevatedButton(
          focusNode: focusNode,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDEEDE4),
          ),
          onPressed: () => _onPressed(context),
          child: const SizedBox(
            height: 56,
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.search_rounded),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  )
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_rounded),
            onPressed: () => _onFavouritesButtonPressed(context),
          )
        ],
      ),
      body: Center(
        child: Stack(children: [
          GemMap(
            onMapCreated: onMapCreated,
          ),
        ]),
      ),
      floatingActionButton: SizedBox(
        height: 124,
        child: Column(
          children: <Widget>[
            FloatingActionButton(
              key: const Key('homeView_gps_floatingActionButton'),
              onPressed: _onFollowPositionButtonPressed,
              shape: const CircleBorder(),
              child: const Icon(Icons.gps_fixed_rounded),
            ),
            const SizedBox(
              height: 12,
            ),
            FloatingActionButton(
              key: const Key('homeView_directions_floatingActionButton'),
              onPressed: () {},
              child: const Icon(Icons.directions_rounded),
            ),
          ],
        ),
      ),
      bottomSheet: _focusedLandmark == null ? null : FutureBuilder<PanelInfo>(
        future: getInfo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return LandmarkPanel(
            onCancelTap: onCancelTap,
            onFavoritesTap: onFavoritesTap,
            isFavoriteLandmark: _isLandmarkFavorite,
            coordinates: snapshot.data!.formattedCoords,
            category: snapshot.data!.categoryName,
            img: snapshot.data!.image!,
            name: snapshot.data!.name,
          );
        },
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Future<PanelInfo> getInfo() async {
    late Uint8List? iconFuture;
    late String nameFuture;
    late Coordinates coordinatesFuture;
    late String coordinatesFutureText;
    late List<LandmarkCategory> categoriesFuture;

    iconFuture = await _decodeLandmarkIcon(_focusedLandmark!);
    nameFuture = _focusedLandmark!.getName();
    coordinatesFuture = _focusedLandmark!.getCoordinates();
    coordinatesFutureText =
        "${coordinatesFuture.latitude.toString()}, ${coordinatesFuture.longitude.toString()}";
    categoriesFuture = _focusedLandmark!.getCategories();

    return PanelInfo(
        image: iconFuture,
        name: nameFuture,
        categoryName:
            categoriesFuture.isNotEmpty ? categoriesFuture.first.name! : '',
        formattedCoords: coordinatesFutureText);
  }

  Future<Uint8List?> _decodeLandmarkIcon(Landmark landmark) async {
    final data = landmark.getImage(100, 100);

    return decodeImageData(data);
  }

  _registerLandmarkTapCallback() {
    _mapController.registerTouchCallback((pos) async {
      // Select the object at the tap position.
      await _mapController.selectMapObjects(pos);

      // Get the selected landmarks.
      final landmarks = await _mapController.cursorSelectionLandmarks();

      final landmarksSize = await landmarks.size();

      // Check if there is a selected Landmark.
      if (landmarksSize == 0) return;

      // Highlight the landmark on the map.
      _mapController.activateHighlight(landmarks);

      final lmk = await landmarks.at(0);
      setState(() {
        _focusedLandmark = lmk;
      });

      await _checkIfFavourite();
    });
  }

  _onFavouritesButtonPressed(BuildContext context) async {
    // Fetch landmarks from the store
    final favoritesList = await _favoritesStore!.getLandmarks();

    // Navigating to favorites screen then the result will be the selected item in the list.
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FavoritesPage(landmarkList: favoritesList),
    ));

    // Create a list of landmarks to highlight.
    LandmarkList landmarkList = await LandmarkList.create(_mapController.mapId);

    if (result is! Landmark) {
      return;
    }

    // Add the result to the landmark list.
    await landmarkList.push_back(result);
    final coordinates = result.getCoordinates();

    // Highlight the landmark on the map.
    await _mapController.activateHighlight(landmarkList,
        renderSettings: RenderSettings());

    // Centering the camera on landmark's coordinates
    await _mapController.centerOnCoordinates(coordinates);

    setState(() {
      _focusedLandmark = result;
    });
    await _checkIfFavourite();
  }

  void onCancelTap() {
    // Remove landmark highlights from the map
    _mapController.deactivateAllHighlights();

    setState(() {
      _focusedLandmark = null;
      _isLandmarkFavorite = false;
    });
  }

  void onFavoritesTap() async {
    await _checkIfFavourite();

    if (_isLandmarkFavorite) {
      // Remove the landmark to the store.
      await _favoritesStore!.removeLandmark(_focusedLandmark!);
    } else {
      // Add the landmark to the store.
      await _favoritesStore!.addLandmark(_focusedLandmark!);
    }

    setState(() {
      _isLandmarkFavorite = !_isLandmarkFavorite;
    });
  }

  _checkIfFavourite() async {
    final focusedLandmarkCoordinates = _focusedLandmark!.getCoordinates();
    final favourites = await _favoritesStore!.getLandmarks();
    final favoritesSize = await favourites.size();

    for (int i = 0; i < favoritesSize; i++) {
      final lmk = await favourites.at(i);
      final coordinates = lmk.getCoordinates();

      if (focusedLandmarkCoordinates.latitude == coordinates.latitude &&
          focusedLandmarkCoordinates.longitude == coordinates.longitude) {
        setState(() {
          _isLandmarkFavorite = true;
        });
        return;
      }
    }

    setState(() {
      _isLandmarkFavorite = false;
    });
  }

  late PermissionStatus _locationPermissionStatus = PermissionStatus.denied;

  late PositionService _positionService;
  late bool _hasLiveDataSource = false;


  _onFollowPositionButtonPressed() async {
    if (kIsWeb) {
      // On web platform permission are handled differently than other platforms.
      // The SDK handles the request of permission for location
      _locationPermissionStatus = PermissionStatus.granted;
    } else {
      // For Android & iOS platforms, permission_handler package is used to ask for permissions
      _locationPermissionStatus = await Permission.locationWhenInUse.request();
    }

    if (_locationPermissionStatus != PermissionStatus.granted) {
      return;
    }

    // After the permission was granted, we can set the live data source (in most cases the GPS)
    // The data source should be set only once, otherwise we'll get -5 error
    if (!_hasLiveDataSource) {
      _positionService.setLiveDataSource();
      _hasLiveDataSource = true;
    }

    // After data source is set, startFollowingPosition can be safely called
    if (_locationPermissionStatus == PermissionStatus.granted) {
      // Optionally, we can set an animation
      final animation = GemAnimation(type: EAnimation.AnimationLinear);

      _mapController.startFollowingPosition(animation: animation);
    }
    setState(() {});
  }

}
