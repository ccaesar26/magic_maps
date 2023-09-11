import 'package:gem_kit/api/gem_geographicarea.dart';
import 'package:gem_kit/api/gem_searchpreferences.dart';
import 'package:gem_kit/gem_kit_basic.dart';
import 'package:gem_kit/gem_kit_map_controller.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_searchservice.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'search_result_item.dart';

class SearchPage extends StatefulWidget {
  final GemMapController controller;
  final Coordinates coordinates;
  const SearchPage(
      {super.key, required this.controller, required this.coordinates});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late SearchService gemSearchService;
  SearchPreferences preferences =
      SearchPreferences(maxmatches: 40, allowfuzzyresults: true);

  List<Landmark> landmarks = [];

  @override
  void initState() {
    SearchService.create(widget.controller.mapId).then((value) {
      gemSearchService = value;
    });

    super.initState();
  }

  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    _focusNode.requestFocus();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 64,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        title: SearchBar(
          focusNode: _focusNode,
          hintText: 'Search',
          onSubmitted: (value) => _onSubmitted(value),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: landmarks.length,
              controller: ScrollController(),
              itemBuilder: (context, index) {
                final lmk = landmarks.elementAt(index);
                return SearchResultItem(
                  onTap: () => Navigator.of(context).pop(lmk),
                  landmark: lmk,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  _onSubmitted(String text) {
    search(text, widget.coordinates, preferences: preferences);
  }

  late Completer<List<Landmark>> completer;

// Search method. Text and coordinates parameters are mandatory, preferences and geographicArea are optional.
  Future<void> search(String text, Coordinates coordinates,
      {SearchPreferences? preferences,
      RectangleGeographicArea? geographicArea}) async {
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

    final result = await completer.future;

    setState(() {
      landmarks = result;
    });
  }
}

