import 'dart:async';

import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_searchpreferences.dart';
import 'package:gem_kit/api/gem_searchservice.dart';
import 'package:gem_kit/gem_kit_basic.dart';
import 'package:gem_kit/gem_kit_map_controller.dart';

import '../search_repository.dart';

class SearchRepositoryImplementation implements SearchRepository {
  SearchRepositoryImplementation(this._mapController) {
    SearchService.create(_mapController.mapId).then((value) {
      gemSearchService = value;
    });
  }

  final GemMapController _mapController;

  late SearchService gemSearchService;
  SearchPreferences preferences =
      SearchPreferences(maxmatches: 40, allowfuzzyresults: true);
  late Completer<List<Landmark>> completer;

  @override
  Future<List<Landmark>> search(String text, Coordinates coordinates,
      {SearchPreferences? preferences}) async {
    completer = Completer<List<Landmark>>();

    // Calling the search method from the sdk.
    // (err, results) - is a callback function that calls when the computing is done.
    // err is an error code, results is a list of landmarks
    gemSearchService.search(text, coordinates, (err, results) async {
      // If there is an error or there aren't any results, the method will return an empty list.
      if (err != GemError.success || results == null) {
        completer.complete([]);
        return;
      }
      final size = await results.size();
      List<Landmark> searchResults = [];

      for (int i = 0; i < size; i++) {
        final gemLmk = await results.at(i);

        searchResults.add(gemLmk);
      }

      if (!completer.isCompleted) completer.complete(searchResults);
    });

    return await completer.future;
  }
}
