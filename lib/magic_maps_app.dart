import 'package:flutter/material.dart';
import 'package:gem_kit/api/gem_routingservice.dart' as gem;
import 'package:magic_maps/src/colors.dart';

import 'favorites/favorites.dart';
import 'home/home.dart';

class MagicMapsApp extends StatelessWidget {
  const MagicMapsApp({super.key});

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/favorites':
        return MaterialPageRoute(
            builder: (context) => FavoritesPage(
                landmarkList: settings.arguments as gem.LandmarkList));
      default:
        return MaterialPageRoute(builder: (context) => const NotFoundPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hello Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorConstants.gulfStream),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 50),
            const SizedBox(height: 20),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
