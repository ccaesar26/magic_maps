import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gem_kit/api/gem_addressinfo.dart';
import 'package:gem_kit/api/gem_landmark.dart';

class SearchResultItem extends StatefulWidget {
  final bool isLast;
  final Landmark landmark;
  final VoidCallback? onTap;

  const SearchResultItem(
      {super.key, this.isLast = false, required this.landmark, this.onTap});

  @override
  State<SearchResultItem> createState() => _SearchResultItemState();
}

class _SearchResultItemState extends State<SearchResultItem> {
  late Future<Uint8List?> _landmarkIconFuture;
  late Future<ExtraInfo> _extraInfoFuture;
  late Future<String> _addressFuture;

  @override
  void initState() {
    _landmarkIconFuture = _decodeLandmarkIcon();
    _addressFuture = _getAddress();

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
                        margin: const EdgeInsets.only(bottom: 5),
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
                            child: Builder(
                              builder: (context) {
                                String formattedDistance = '';

                                final extraInfo =
                                widget.landmark.getExtraInfo();
                                double distance = (extraInfo.getByKey(
                                    PredefinedExtraInfoKey
                                        .gmSearchResultDistance) /
                                    1000) as double;
                                formattedDistance =
                                "${distance.toStringAsFixed(0)}km";

                                return Text(formattedDistance);
                              },
                            ),
                          ),
                          FutureBuilder<String>(
                            future: _addressFuture,
                            builder: (context, snapshot) {
                              String address = '';

                              if (snapshot.hasData) {
                                address = snapshot.data!;
                              }

                              return SizedBox(
                                width: MediaQuery.of(context).size.width - 210,
                                child: Text(
                                  address,
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
                      onPressed: () {},
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
    final data = await widget.landmark.getImage(100, 100);

    return decodeImageData(data);
  }

  Future<String> _getAddress() async {
    final addressInfo = await widget.landmark.getAddress();
    final street = await addressInfo.getField(EAddressField.StreetName);
    final city = await addressInfo.getField(EAddressField.City);
    final country = await addressInfo.getField(EAddressField.Country);

    return '$street $city $country';
  }

  Future<Uint8List?> decodeImageData(Uint8List data) async {
    Completer<Uint8List?> c = Completer<Uint8List?>();

    int width = 100;
    int height = 100;

    ui.decodeImageFromPixels(data, width, height, ui.PixelFormat.rgba8888,
            (ui.Image img) async {
          final data = await img.toByteData(format: ui.ImageByteFormat.png);
          if (data == null) {
            c.complete(null);
          }
          final list = data!.buffer.asUint8List();
          c.complete(list);
        });

    return c.future;
  }
}