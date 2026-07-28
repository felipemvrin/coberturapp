# CobertuApp

CobertuApp es una aplicación móvil desarrollada en Flutter para ayudar a los usuarios a consultar y entender la cobertura móvil en Chile. La interfaz inicial incluye un dashboard con estado de conexión, señal, antenas cercanas y una acción para buscar la mejor señal.

## Características

- Pantalla principal tipo dashboard para cobertura móvil
- Estado de conexión con información de operador y tecnología
- Indicador visual de calidad de señal
- Lista de antenas cercanas con distancia y dirección
- Diseño moderno con Material 3
- Estructura preparada para evolucionar hacia datos reales, GPS y mapas

## Tecnologías

- Flutter
- Dart
- Material 3
- GitHub para control de versiones

## Requisitos

- Flutter SDK instalado
- Un emulador o dispositivo físico

## Instalación

```bash
git clone https://github.com/felipemvrin/cobertuapp.git
cd cobertuapp
flutter pub get
flutter run
```

## Estructura del proyecto

- lib/main.dart: punto de entrada de la app
- lib/presentation/: pantallas y widgets de la interfaz
- lib/domain/: modelos del dominio
- lib/data/: repositorios y fuentes de datos mock
- test/: pruebas de widget y flujo principal

## Estado actual

La app ya incluye una primera versión funcional de la pantalla principal con datos simulados para mostrar la experiencia de usuario y preparar la integración futura con información real de cobertura.

## Próximos pasos

- Integrar datos reales de cobertura
- Agregar mapa interactivo
- Incorporar ubicación GPS y orientación
- Mejorar la experiencia de búsqueda de mejor señal
