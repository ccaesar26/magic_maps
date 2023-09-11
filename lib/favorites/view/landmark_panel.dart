import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magic_maps/src/colors.dart';

class LandmarkPanel extends StatelessWidget {
  final VoidCallback onCancelTap;
  final VoidCallback onFavoritesTap;
  final String name;
  final Uint8List img;
  final String coordinates;
  final String category;
  final bool isFavoriteLandmark;

  const LandmarkPanel(
      {super.key,
      required this.onCancelTap,
      required this.onFavoritesTap,
      required this.name,
      required this.img,
      required this.coordinates,
      required this.category,
      required this.isFavoriteLandmark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 184,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: ColorConstants.navajoWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: onCancelTap,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width - 8,
            height: 128,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: ColorConstants.winterHazel,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Image.memory(
                    img,
                    gaplessPlayback: true,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 158,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        coordinates,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  //padding: EdgeInsets.zero,
                  onPressed: onFavoritesTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    fixedSize: const Size(56, 56),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.bottomCenter,
                    elevation: 5,
                  ),
                  child: Icon(
                    isFavoriteLandmark
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
