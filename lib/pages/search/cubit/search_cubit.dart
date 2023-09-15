import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:magic_maps/injection_container.dart';
import 'package:magic_maps/repositories/search_repository.dart';
import 'package:meta/meta.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState()) {
    initRepository();
  }

  late final SearchRepository _searchRepository;

  void initRepository()  {
    _searchRepository = InjectionContainer.singleton.get<SearchRepository>();
  }

  void onSubmitted(String text, Coordinates coordinates) {
    emit(state.copyWith(isLoading: true));
    search(text, coordinates);
  }

  void onChanged(String text, Coordinates coordinates) {
    delay()
        .then((value) => emit(state.copyWith(isLoading: true)))
        .then((value) => search(text, coordinates));
  }

  Future<void> delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> search(String text, Coordinates coordinates) async {
    final result = await _searchRepository.search(text, coordinates);

    emit(SearchState(
      landmarks: result,
      isLoading: false,
    ));
  }
}
