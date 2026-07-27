import 'package:flutter/material.dart';

// Punto de entrada de la aplicación.
// Aquí empieza todo: Flutter ejecuta main y carga la app.
void main() {
  runApp(const MiPrimerApp());
}

// MiPrimerApp es la raíz de la interfaz.
// MaterialApp define el tema general y la pantalla inicial.
class MiPrimerApp extends StatelessWidget {
  const MiPrimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi primer app Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// HomePage maneja el estado de la pantalla.
// Se usa cuando la UI cambia, por ejemplo al presionar un botón.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _contador = 0;

  // Cambia el estado y vuelve a construir la UI.
  void _incrementar() {
    setState(() {
      _contador++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi primera pantalla'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hola, este es tu primer proyecto en Flutter',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Veces presionadas: $_contador',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _incrementar,
                    icon: const Icon(Icons.add),
                    label: const Text('Presiona aquí'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
