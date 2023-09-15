import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';

abstract interface class SearchRepository {
  Future<List<Landmark>> search(String text, Coordinates coordinates);
}