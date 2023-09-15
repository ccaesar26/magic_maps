part of 'home_cubit.dart';

@immutable
class HomeState extends Equatable {
  final Landmark? focusedLandmark;
  final bool? showPanel;
  final bool? isLandmarkFavorite;
  final PanelInfo? panelInfo;
  final bool? haveRoutes;
  final bool? isNavigating;

  const HomeState({
    this.focusedLandmark,
    this.showPanel,
    this.isLandmarkFavorite,
    this.panelInfo,
    this.haveRoutes,
    this.isNavigating,
  });

  HomeState copyWith({
    Landmark? focusedLandmark,
    bool? showPanel,
    bool? isLandmarkFavorite,
    PanelInfo? panelInfo,
    bool? haveRoutes,
    bool? isNavigating,
  }) =>
      HomeState(
        focusedLandmark: focusedLandmark ?? this.focusedLandmark,
        showPanel: showPanel ?? this.showPanel,
        isLandmarkFavorite: isLandmarkFavorite ?? this.isLandmarkFavorite,
        panelInfo: panelInfo ?? this.panelInfo,
        haveRoutes: haveRoutes ?? this.haveRoutes,
        isNavigating: isNavigating ?? this.isNavigating,
      );

  @override
  List<Object?> get props => [
        focusedLandmark,
        showPanel,
        isLandmarkFavorite,
        panelInfo,
        haveRoutes,
        isNavigating,
      ];
}
