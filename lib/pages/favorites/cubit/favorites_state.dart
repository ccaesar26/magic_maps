part of 'favorites_cubit.dart';

@immutable
class FavoritesState extends Equatable {
  final bool? isLoading;
  final List<Landmark>? landmarks;

  const FavoritesState({
    this.isLoading,
    this.landmarks,
  });

  FavoritesState copyWith({
    bool? isLoading,
    List<Landmark>? landmarks,
  }) =>
      FavoritesState(
        isLoading: isLoading ?? this.isLoading,
        landmarks: landmarks ?? this.landmarks,
      );

  @override
  List<Object?> get props => [
        isLoading,
        landmarks,
      ];
}
