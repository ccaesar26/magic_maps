import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gem_kit/widget/gem_kit_map.dart';
import 'package:magic_maps/pages/favorites/favorites.dart';
import 'package:magic_maps/pages/home/home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 64,
        shadowColor: Colors.black12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        titleSpacing: 4,
        leading: IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: () {},
        ),
        title: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDEEDE4),
          ),
          onPressed: () => context.read<HomeCubit>().onSearchPressed(context),
          child: const SizedBox(
            height: 56,
            child: Row(
              children: [
                Icon(Icons.search_rounded),
                SizedBox(
                  width: 8,
                ),
                Text('Search',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    )),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_rounded),
            onPressed: () =>
                context.read<HomeCubit>().onFavouritesButtonPressed(context),
          )
        ],
      ),
      body: Center(
        child: GemMap(
          onMapCreated: context.read<HomeCubit>().onMapCreated,
        ),
      ),
      floatingActionButton: SizedBox(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.haveRoutes == null || state.haveRoutes == false) {
              return _defaultFloatingActionButton(context);
            } else {
              return SizedBox(
                child: Column(
                  children: [
                    _defaultFloatingActionButton(context),
                    const SizedBox(
                      height: 12,
                    ),
                    FloatingActionButton(
                      heroTag: 'homeView_directions_red_floatingActionButton',
                      key: const Key('homeView_directions_red_floatingActionButton'),
                      onPressed: context.read<HomeCubit>().removeRoutes,
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.cancel_rounded),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      bottomSheet: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.showPanel == null || state.showPanel == false) {
            return const SizedBox();
          }
          context.read<HomeCubit>().getInfo();
          if (state.panelInfo == null) {
            return const LandmarkPanelLoading();
          }
          return LandmarkPanel(
            onCancelTap: context.read<HomeCubit>().onCancelTap,
            onFavoritesTap: context.read<HomeCubit>().onFavoritesTap,
            isFavoriteLandmark: state.isLandmarkFavorite!,
            coordinates: state.panelInfo!.formattedCoords,
            category: state.panelInfo!.categoryName,
            img: state.panelInfo!.image!,
            name: state.panelInfo!.name,
          );
        },
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}

Widget _defaultFloatingActionButton(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      FloatingActionButton(
        heroTag: 'homeView_gps_floatingActionButton',
        key: const Key('homeView_gps_floatingActionButton'),
        onPressed: context.read<HomeCubit>().onFollowPositionButtonPressed,
        shape: const CircleBorder(),
        child: const Icon(Icons.gps_fixed_rounded),
      ),
      const SizedBox(
        height: 12,
      ),
      BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
        if (state.haveRoutes == null || state.haveRoutes == false) {
          return FloatingActionButton(
            key: const Key('homeView_directions_default_floatingActionButton'),
            onPressed: context.read<HomeCubit>().calculateRouteToLandmark,
            child: const Icon(Icons.directions_rounded),
          );
        } else {
          return FloatingActionButton(
            heroTag: 'homeView_directions_red_floatingActionButton',
            key: const Key('homeView_directions_red_floatingActionButton'),
            onPressed: context.read<HomeCubit>().removeRoutes,
            backgroundColor: Colors.red,
            child: const Icon(Icons.cancel_rounded),
          );
        }
      }),
    ],
  );
}
