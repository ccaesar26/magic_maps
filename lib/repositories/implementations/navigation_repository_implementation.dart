import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_mapviewpreferences.dart';
import 'package:gem_kit/api/gem_navigationservice.dart';
import 'package:gem_kit/api/gem_progresslistener.dart';
import 'package:gem_kit/api/gem_routingpreferences.dart';
import 'package:gem_kit/api/gem_routingservice.dart';
import 'package:gem_kit/gem_kit_basic.dart';
import 'package:gem_kit/gem_kit_map_controller.dart';
import 'package:magic_maps/pages/home/view/instruction_model.dart';

import '../navigation_repository.dart';

class NavigationRepositoryImplementation implements NavigationRepository {
  NavigationRepositoryImplementation(this._mapController);

  final GemMapController _mapController;
  late RoutingService _routingService;
  late NavigationService _navigationService;
  List<Coordinates> waypoints = [];
  List<Route> shownRoutes = [];
  late InstructionModel currentInstruction;

  bool _haveRoutes = false;
  bool isNavigating = false;

  @override
  Future<void> initServices() async {
    _routingService = await RoutingService.create(_mapController.mapId);
    _navigationService = await NavigationService.create(_mapController.mapId);
  }

  @override
  bool get haveRoutes => _haveRoutes;

  @override
  void addCoordinates(Coordinates coordinates) {
    waypoints.add(coordinates);
  }

  @override
  void addCoordinatesFromLandmark(Landmark landmark) {
    waypoints.add(landmark.getCoordinates());
  }

  @override
  Future<ProgressListener> calculateRoute() async {
    if (waypoints.length < 2) {
      return Future.error('Not enough waypoints');
    }

    // Create a landmark list
    final landmarkWaypoints = await LandmarkList.create(_mapController.mapId);

    // Create landmarks from coordinates and add them to the list
    for (final wp in waypoints) {
      var landmark = Landmark.create();
      await landmark.setCoordinates(
          Coordinates(latitude: wp.latitude, longitude: wp.longitude));
      landmarkWaypoints.push_back(landmark);
    }

    final routePreferences = RoutePreferences();

    var result = await _routingService.calculateRoute(
        landmarkWaypoints, routePreferences, (err, routes) async {
      if (err != GemError.success || routes == null) {
        return;
      } else {
        // Get the controller's preferences
        final mapViewPreferences = _mapController.preferences();
        // Get the routes from the preferences
        final routesMap = await mapViewPreferences.routes();
        //Get the number of routes
        final routesSize = await routes.size();

        for (int i = 0; i < routesSize; i++) {
          final route = await routes.at(i);
          shownRoutes.add(route);

          final timeDistance = await route.getTimeDistance();

          final totalDistance = convertDistance(
              timeDistance.unrestrictedDistanceM +
                  timeDistance.restrictedDistanceM);

          final totalTime = convertDuration(
              timeDistance.unrestrictedTimeS + timeDistance.restrictedTimeS);
          // Add labels to the routes
          await routesMap.add(route, i == 0,
              label: '$totalDistance \n $totalTime');
        }
        // Select the first route as the main one
        final mainRoute = await routes.at(0);

        await _mapController.centerOnRoute(mainRoute);
      }
    });
    _haveRoutes = true;

    return result;
  }

  @override
  Future<void> removeRoutes() async {
    final prefs = _mapController.preferences();
    final routesMap = await prefs.routes();

    await routesMap.clear();

    for (final route in shownRoutes) {
      routesMap.remove(route);
    }

    shownRoutes = [];
    waypoints = [];
    _haveRoutes = false;
  }

  @override
  Future<void> selectRoute(Point pos) async {
    await _mapController.selectMapObjects(pos);

    final Route? selectedRoute = await _mapController
        .cursorSelectionRoutes()
        .then((routes) => routes.at(0));

    if (selectedRoute == null) {
      return;
    }

    final prefs = _mapController.preferences();

    final routesMap = await prefs.routes();

    await routesMap.setMainRoute(selectedRoute);
  }

  Future<void> _navigateOnRoute(
      {required Function(InstructionModel) onInstructionUpdated}) async {
    final routesMap = await _mapController.preferences().routes();
    final route = await routesMap.getMainRoute();

    await _navigationService.startSimulation(route, (type, instruction) async {
      if (type != NavigationEventType.navigationInstructionUpdate ||
          instruction == null) {
        isNavigating = false;
        removeRoutes();
        return;
      }

      isNavigating = true;

      final ins = await InstructionModel.fromGemInstruction(instruction);
      onInstructionUpdated(ins);

      instruction.dispose();
    });
  }

  @override
  Future<void> startSimulation() async {
    await _navigateOnRoute(onInstructionUpdated: (instruction) {
      currentInstruction = instruction;
    });

    _mapController.startFollowingPosition(
        animation: GemAnimation(
      duration: 200,
      type: EAnimation.AnimationLinear,
    ));
  }

  @override
  Future<void> stopSimulation() async {
    await _navigationService.cancelNavigation();
    removeRoutes();
  }

  String convertDistance(int meters) {
    if (meters >= 1000) {
      double kilometers = meters / 1000;
      return '${kilometers.toStringAsFixed(1)} km';
    } else {
      return '${meters.toString()} m';
    }
  }

  String convertDuration(int seconds) {
    int hours = seconds ~/ 3600; // Number of whole hours
    int minutes = (seconds % 3600) ~/ 60; // Number of whole minutes

    String hoursText = (hours > 0) ? '$hours h ' : ''; // Hours text
    String minutesText = '$minutes min'; // Minutes text

    return hoursText + minutesText;
  }
}
