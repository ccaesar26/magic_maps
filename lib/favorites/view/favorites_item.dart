// Class for the search results.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';

import 'utility.dart';

class FavoritesItem extends StatefulWidget {
  final bool isLast;
  final Landmark landmark;
  final VoidCallback? onTap;

  const FavoritesItem(
      {super.key, this.isLast = false, required this.landmark, this.onTap});

  @override
  State<FavoritesItem> createState() => _FavoritesItemState();
}

class _FavoritesItemState extends State<FavoritesItem> {
  late Future<Uint8List?> _landmarkIconFuture;

  late Future<Coordinates> _coordsFuture;

  @override
  void initState() {
    _landmarkIconFuture = _decodeLandmarkIcon();

    _coordsFuture = _getCoordinates();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          children: [
            Row(
              children: [
                FutureBuilder<Uint8List?>(
                    future: _landmarkIconFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done ||
                          snapshot.data == null) {
                        return Container();
                      }
                      return Container(
                        padding: const EdgeInsets.all(8),
                        width: 50,
                        child: Image.memory(snapshot.data!),
                      );
                    }),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 140,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          widget.landmark.getName(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 3),
                            child: Text(
                              widget.landmark.getCategories().isNotEmpty
                                  ? widget.landmark
                                  .getCategories()
                                  .elementAt(0)
                                  .name ??
                                  ' '
                                  : ' ',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                          FutureBuilder<Coordinates>(
                            future: _coordsFuture,
                            builder: (context, snapshot) {
                              Coordinates coords;
                              String textCoords = '';

                              if (snapshot.hasData) {
                                coords = snapshot.data!;
                                textCoords =
                                "${coords.latitude}, ${coords.longitude}";
                              }

                              return SizedBox(
                                width: MediaQuery.of(context).size.width - 210,
                                child: Text(
                                  textCoords,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              );
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: IconButton(
                      onPressed: widget.onTap,
                      icon: const Icon(
                        Icons.north_west_outlined,
                        color: Colors.grey,
                      )),
                )
              ],
            ),
            if (!widget.isLast)
              const Divider(
                color: Colors.grey,
                indent: 10,
                endIndent: 20,
              )
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> _decodeLandmarkIcon() async {
    final data = widget.landmark.getImage(100, 100);
    return decodeImageData(data);
  }

  Future<Coordinates> _getCoordinates() async {
    final coords = widget.landmark.getCoordinates();
    return coords;
  }
}
