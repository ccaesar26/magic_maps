import 'dart:async';
import 'package:flutter/material.dart';

import 'package:gem_kit/api/gem_routingservice.dart';
import 'package:gem_kit/api/gem_landmark.dart';

import 'favorites_item.dart';

class FavoritesPage extends StatefulWidget {
  final LandmarkList landmarkList;
  const FavoritesPage({super.key, required this.landmarkList});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
  }

  // Utility method to convert a LandmarkList object to a Dart list of landmarks
  Future<List<Landmark>> _fromLandmarkListToListOfLandmarks() async {
    var length = await widget.landmarkList.size();
    List<Landmark> landmarks = [];

    for (int i = 0; i < length; i++) {
      Landmark landmark = await widget.landmarkList.at(i);
      landmarks.add(landmark);
    }
    return landmarks.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 64,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        titleSpacing: 4,
        automaticallyImplyLeading: true,
        title: const Text("Favorites list"),
      ),
      body: FutureBuilder<List<Landmark>>(
          future: _fromLandmarkListToListOfLandmarks(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: snapshot.data!.length,
              controller: ScrollController(),
              itemBuilder: (context, index) {
                final lmk = snapshot.data!.elementAt(index);
                return FavoritesItem(
                  onTap: () => Navigator.of(context).pop(lmk),
                  landmark: lmk,
                );
              },
            );
          }),
    );
  }
}