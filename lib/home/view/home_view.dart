import 'package:flutter/material.dart';
import 'package:gem_kit/api/gem_sdksettings.dart';
import 'package:gem_kit/gem_kit_map_controller.dart';
import 'package:gem_kit/widget/gem_kit_map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GemMapController mapController;

  @override
  void initState() {
    super.initState();
  }

  Future<void> onMapCreated(GemMapController controller) async {
    mapController = controller;
    SdkSettings.setAppAuthorization(
        "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIyNjEwNDBmNy05ODVhLTRiYjUtYTVhYS04MmFjZWQ2ZGM0YmIiLCJleHAiOjE2OTY1Mzk2MDAsImlzcyI6IkdlbmVyYWwgTWFnaWMiLCJqdGkiOiIwOTI2ZGQ5NC0yNjdkLTQ5MWMtYTM5ZS00ZDIxMDQzY2Q0MGQiLCJuYmYiOjE2OTM5ODM2NzV9.xaj0aijgsmHmvLzBZo6FoLjqkbaAgT4YopHf6pGkuD1kjCHfJXTVjq1bAFxn2m-PFXMT4wJh1ZOITqtrolC5Mg");
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
        leading: IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: () {},
        ),
        title: const SearchBar(
          hintText: 'Search',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            GemMap(
              onMapCreated: onMapCreated,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.my_location_rounded),
      ),
    );
  }
}
