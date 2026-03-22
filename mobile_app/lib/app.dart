import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart';
import 'data/repositories/route_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final routeRepository = RouteRepository(
      baseUrl: "https://us-central1/<project-id>.cloudfunctions.net",
    );

    return MaterialApp(
      title: 'Accessible Routing',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: HomeScreen(routeRepository: routeRepository),
    );
  }
}
