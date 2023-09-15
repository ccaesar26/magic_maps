import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_routingservice.dart';
import 'package:magic_maps/injection_container.dart';
import 'package:magic_maps/repositories/landmark_repository.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState()) {
    initRepository();
  }

  late final LandmarkRepository _landmarkRepository;

  void initRepository()  {
    _landmarkRepository = InjectionContainer.singleton.get<LandmarkRepository>();
  }

  Future<void> fromLandmarkListToListOfLandmarks(LandmarkList landmarkList) async {
    emit(state.copyWith(isLoading: true));

    List<Landmark> landmarks = await _landmarkRepository.fromLandmarkListToListOfLandmarks(landmarkList);

    emit(state.copyWith(isLoading: false, landmarks: landmarks));
  }
}
