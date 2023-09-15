part of 'search_cubit.dart';

@immutable
class SearchState extends Equatable {
  const SearchState({
    this.landmarks,
    this.isLoading,
  });

  final List<Landmark>? landmarks;
  final bool? isLoading;

  SearchState copyWith({
    List<Landmark>? landmarks,
    bool? isLoading,
  }) {
    return SearchState(
      landmarks: landmarks ?? this.landmarks,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    landmarks,
    isLoading,
  ];
}
