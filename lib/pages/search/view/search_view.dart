import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:magic_maps/pages/search/search.dart';

import 'search_result_item.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key, required this.coordinates});

  final Coordinates coordinates;

  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    _focusNode.requestFocus();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 64,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        title: SearchBar(
          focusNode: _focusNode,
          hintText: 'Search',
          onSubmitted: (value) => context.read<SearchCubit>().onSubmitted(
                value,
                coordinates,
              ),
          onChanged: (value) => context.read<SearchCubit>().onSubmitted(
                value,
                coordinates,
              ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state.isLoading != null && state.isLoading!) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state.landmarks == null) {
            return const SizedBox();
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.landmarks!.length,
                  controller: ScrollController(),
                  itemBuilder: (context, index) {
                    final lmk = state.landmarks!.elementAt(index);
                    return SearchResultItem(
                      onTap: () => Navigator.of(context).pop(lmk),
                      landmark: lmk,
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
