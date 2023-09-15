import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:magic_maps/pages/favorites/cubit/favorites_cubit.dart';
import 'package:magic_maps/pages/home/cubit/home_cubit.dart';

import 'favorites_item.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesCubit>().fromLandmarkListToListOfLandmarks(context.read<HomeCubit>().favoritesList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 64,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        titleSpacing: 4,
        automaticallyImplyLeading: true,
        title: const Text("Favorites list"),
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state.isLoading != null && state.isLoading!) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state.landmarks == null) {
              return const SizedBox();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.landmarks!.length,
              controller: ScrollController(),
              itemBuilder: (context, index) {
                final lmk = state.landmarks!.elementAt(index);
                return FavoritesItem(
                  onTap: () => Navigator.of(context).pop(lmk),
                  landmark: lmk,
                );
              },
            );
        },
      ),
    );
  }
}