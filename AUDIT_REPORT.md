# 📋 AUDITORÍA DE CALIDAD - COBERTURAPP

**Fecha:** 29/07/2026  
**Scope:** Proyecto Flutter en `/Users/felipemarin/Documents/Projects/flutter/app`  
**Estado:** Listo para publicar en GitHub (con recomendaciones)

---

## 🔴 PROBLEMAS CRÍTICOS (4)

### 1. ERROR EN TÍTULO DEL APPBAR - SINTAXIS INVÁLIDA
**Archivo:** [lib/presentation/map/map_screen.dart](lib/presentation/map/map_screen.dart#L217)  
**Línea:** 217  
**Severidad:** 🔴 CRÍTICO  
**Problema:**
```dart
title: const Text('CoberturApp ))'),  // ❌ Caracteres extra ))
```
**Impacto:** El título muestra caracteres innecesarios en la pantalla de mapa.  
**Recomendación:**
```dart
title: const Text('CoberturApp'),
```

### 2. INCONSISTENCIA DE NOMBRES DE APLICACIÓN
**Archivo:** [lib/main.dart](lib/main.dart#L9) y [lib/presentation/map/map_screen.dart](lib/presentation/map/map_screen.dart#L217)  
**Severidad:** 🔴 CRÍTICO  
**Problema:**
- Clase: `RangoApp` (main.dart:9)
- Titulo MaterialApp: `'CoberturApp'` (main.dart:15)
- AppBar: `'CoberturApp'` (map_screen.dart:217)
- Test busca: `'RANGO'` (test/home_screen_test.dart:8)

**Contexto:**
```dart
// main.dart
class RangoApp extends StatelessWidget {  // ❌ Nombre inconsistente
  ...
  title: 'CoberturApp',  // ❌ Diferente
```

**Recomendación:** Estandarizar nombre en toda la app:
- Opción A: Cambiar todo a `CoberturApp`
- Opción B: Cambiar todo a `RangoApp`
- Actualizar tests también

---

## 🟠 PROBLEMAS ALTOS (5)

### 3. CÓDIGO DUPLICADO - MÉTODOS DE CÁLCULO
**Archivos:** 
- [lib/data/csv_coverage_repository.dart](lib/data/csv_coverage_repository.dart#L79-L108)
- [lib/presentation/map/map_screen.dart](lib/presentation/map/map_screen.dart#L90-L119)

**Severidad:** 🟠 ALTO  
**Problema:** Tres métodos están duplicados:
- `_calculateBearing()` (línea 79 y 90)
- `_bearingToDirection()` (línea 94 y 104)
- `_getSignalQualityByDistance()` (línea 102 y 111)

**Impacto:** 
- Mantenimiento difícil: cambios deben replicarse en dos lugares
- Inconsistencia potencial en lógica
- Violación del principio DRY (Don't Repeat Yourself)

**Recomendación:**
1. Crear archivo `lib/domain/utils/location_utils.dart`
2. Mover métodos al nuevo archivo
3. Importar en ambos archivos que los usan

---

### 4. HARDCODED VALUES - FALTA ABSTRACCIÓN
**Archivo:** [lib/data/csv_coverage_repository.dart](lib/data/csv_coverage_repository.dart#L59)  
**Severidad:** 🟠 ALTO  
**Problema:**
```dart
final connectionStatus = nearest.distanceKm < 15  // ❌ Hardcoded magic number
    ? ConnectionStatus.connected 
    : ConnectionStatus.noConnection;
```

**Línea:** 59  
**Contexto:** Umbral de distancia para determinar si hay conexión  
**Impacto:** Difícil de probar, cambiar o configurar  

**Recomendación:**
```dart
// Crear constante en clase separada
class CoverageConstants {
  static const double connectionThresholdKm = 15.0;
  static const double excellentSignalKm = 1.0;
  static const double goodSignalKm = 2.0;
  static const double fairSignalKm = 4.0;
  static const double poorSignalKm = 6.0;
}
```

### 5. HARDCODED TEXT - FALTA ABSTRACCIÓN
**Archivo:** [lib/presentation/widgets/signal_status_card.dart](lib/presentation/widgets/signal_status_card.dart#L72)  
**Línea:** 72  
**Severidad:** 🟠 ALTO  
**Problema:**
```dart
isConnected ? operator.name.toUpperCase() : 'Última señal: 3,2 km atrás',
```

**Impacto:**
- Texto hardcodeado difícil de localizar y cambiar
- No es parametrizable
- Imposible internacionalizar (i18n)

**Recomendación:** Crear archivo de constantes de strings:
```dart
// lib/presentation/theme/app_strings.dart
class AppStrings {
  static const String lastSignalFormat = 'Última señal: 3,2 km atrás';
  static const String noConnection = 'SIN SEÑAL';
  static const String connected = 'CONECTADO';
}
```

### 6. REGIONES HARDCODEADAS
**Archivo:** [lib/data/subtel_data_service.dart](lib/data/subtel_data_service.dart#L22)  
**Línea:** 22  
**Severidad:** 🟠 ALTO  
**Problema:**
```dart
const regions = ['santiago-recoleta'];  // ❌ Hardcoded
```

**Impacto:** 
- No escalable
- Difícil agregar nuevas regiones
- Cambios requieren modificar código

**Recomendación:**
```dart
// lib/config/regions_config.dart
class RegionsConfig {
  static const List<String> availableRegions = [
    'santiago-recoleta',
    'santiago-centro',
    'valparaiso-centro',
  ];
}
```

---

## 🟡 PROBLEMAS MEDIOS (6)

### 7. VARIABLE NO UTILIZADA
**Archivo:** [lib/presentation/map/map_screen.dart](lib/presentation/map/map_screen.dart#L37)  
**Línea:** 37  
**Severidad:** 🟡 MEDIO  
**Problema:**
```dart
final List<Polyline> _coverageLines = [];  // ❌ Se declara pero nunca se llena
```

**Contexto:** Se inicializa pero nunca se asignan valores. Se usa en PolylineLayer (línea 276) pero siempre vacío.  
**Recomendación:** 
- Opción A: Implementar lógica para llenarla (características futuras mencionadas en LayerPanel)
- Opción B: Remover si no será usada próximamente
- Opción C: Agregar `// ignore: unused_field` si es intencional

### 8. VARIABLE `_isFindingBestSignal` - LÓGICA INCOMPLETA
**Archivo:** [lib/presentation/home/home_screen.dart](lib/presentation/home/home_screen.dart#L148-L156)  
**Línea:** 148-156  
**Severidad:** 🟡 MEDIO  
**Problema:**
```dart
Future<void> _handleFindBestSignal() async {
  setState(() => _isFindingBestSignal = true);
  await Future<void>.delayed(const Duration(milliseconds: 900));
  if (!mounted) return;
  setState(() => _isFindingBestSignal = false);
  // ❌ Simula búsqueda pero no implementa lógica real
  Navigator.of(context).push(...);
}
```

**Impacto:**
- Simula acción pero no hace nada real (sleep + navegar)
- Confunde al usuario sobre funcionalidad

**Recomendación:** Documentar con TODO o implementar lógica real:
```dart
Future<void> _handleFindBestSignal() async {
  setState(() => _isFindingBestSignal = true);
  try {
    // TODO: Implementar búsqueda real de mejor señal
    // Por ahora solo navega al mapa
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MapScreen()),
    );
  } finally {
    if (mounted) setState(() => _isFindingBestSignal = false);
  }
}
```

### 9. EXTENSION METHOD SIN DOCUMENTACIÓN
**Archivo:** [lib/presentation/map/map_screen.dart](lib/presentation/map/map_screen.dart#L451-L457)  
**Línea:** 451-457  
**Severidad:** 🟡 MEDIO  
**Problema:**
```dart
extension on String {
  Color hexToColor() {  // ❌ Sin documentación, alcance global en archivo
    String hexColor = replaceFirst('#', '');
    return Color(int.parse(hexColor, radix: 16) + 0xFF000000);
  }
}
```

**Impacto:**
- Extension en alcance global del archivo
- Sin validación de formato hex válido
- Podría causar excepciones si hex inválido

**Recomendación:**
1. Crear archivo separado: `lib/domain/utils/color_utils.dart`
2. Agregar validación:
```dart
extension ColorExtension on String {
  /// Convierte string hex (#RRGGBB) a Color.
  /// Ejemplo: '#FF5733'.hexToColor()
  Color hexToColor() {
    try {
      String hexColor = replaceFirst('#', '');
      if (hexColor.length != 6) {
        throw FormatException('Hex color debe tener 6 caracteres');
      }
      return Color(int.parse(hexColor, radix: 16) + 0xFF000000);
    } catch (_) {
      return Colors.grey; // Fallback
    }
  }
}
```

### 10. FALLBACK LOCATION HARDCODEADA
**Archivo:** [lib/presentation/map/map_screen.dart](lib/presentation/map/map_screen.dart#L14)  
**Línea:** 14  
**Severidad:** 🟡 MEDIO  
**Problema:**
```dart
const _fallbackCenter = LatLng(-33.4489, -70.6693);  // Santiago específico
```

**Impacto:**
- Si región cambia, ubicación es incorrecta
- No escalable a múltiples regiones

**Recomendación:**
```dart
// lib/config/location_config.dart
class LocationConfig {
  static const Map<String, LatLng> regionCenters = {
    'santiago-recoleta': LatLng(-33.4489, -70.6693),
    'valparaiso-centro': LatLng(-33.0472, -71.6127),
  };
  
  static LatLng getFallbackCenter(String region) =>
      regionCenters[region] ?? regionCenters['santiago-recoleta']!;
}
```

### 11. TEST BUSCA TEXTO INCORRECTO
**Archivo:** [test/home_screen_test.dart](test/home_screen_test.dart#L8)  
**Línea:** 8  
**Severidad:** 🟡 MEDIO  
**Problema:**
```dart
expect(find.text('RANGO'), findsOneWidget);  // ❌ Pero clase es RangoApp sin mostrar "RANGO"
```

**Contexto:** Test busca 'RANGO' pero HomeScreen no tiene ese texto visible. Probablemente copiado de versión anterior.  
**Recomendación:** Actualizar test a texto real mostrado en pantalla:
```dart
expect(find.text('Que no se escape la señal.'), findsOneWidget);
```

---

## 🔵 PROBLEMAS BAJOS (5)

### 12. COMENTARIOS OBSOLETOS O INCOMPLETOS
**Archivo:** [lib/data/csv_coverage_repository.dart](lib/data/csv_coverage_repository.dart#L24)  
**Línea:** 24  
**Severidad:** 🔵 BAJO  
**Problema:**
```dart
// Log omitido por performance  // ❌ Comentario poco útil
return [];
```

**Recomendación:** Mejorar comentarios:
```dart
// Log omitido por performance. En DEBUG mode usar: debugPrint('Error: $e');
return [];
```

### 13. STRINGS SIN INTERNACIONALIZACIÓN (i18n)
**Ubicaciones:** Múltiples archivos con strings en español hardcodeados  
**Severidad:** 🔵 BAJO  
**Ejemplos:**
- "CONECTADO" - [signal_status_card.dart](lib/presentation/widgets/signal_status_card.dart#L53)
- "ANTENA MÁS CERCANA" - [nearest_antenna_card.dart](lib/presentation/widgets/nearest_antenna_card.dart#L19)
- "ANTENAS CERCANAS" - [home_screen.dart](lib/presentation/home/home_screen.dart#L120)

**Impacto:** Imposible soportar idiomas adicionales  
**Recomendación:** Usar paquete `intl` y `flutter_localizations` cuando sea necesario.

### 14. ARCHIVOS DE ASSETS DUPLICADOS
**Archivos:** 
- [assets/images/favicon.svg](assets/images/favicon.svg) 
- [web/favicon.svg](web/favicon.svg)

**Severidad:** 🔵 BAJO  
**Problema:** Mismo archivo en dos ubicaciones  
**Recomendación:** Remover duplicado de assets/images/ y solo mantener en web/

### 15. FUNCIÓN `_getCurrentLocation()` CON LÓGICA SIMILAR
**Archivo:** [lib/data/csv_coverage_repository.dart](lib/data/csv_coverage_repository.dart#L110-L121)  
**Severidad:** 🔵 BAJO  
**Problema:** Lógica de obtener ubicación duplicada en MapScreen también  
**Recomendación:** Extraer a servicio compartido.

### 16. DOCUMENTACIÓN INCOMPLETA EN MODELOS
**Archivo:** [lib/domain/models/coverage_snapshot.dart](lib/domain/models/coverage_snapshot.dart)  
**Severidad:** 🔵 BAJO  
**Problema:** Modelo sin documentación de campos  
**Recomendación:**
```dart
class CoverageSnapshot {
  const CoverageSnapshot({
    /// Estado actual de conexión (conectado/sin conexión)
    required this.connectionStatus,
    /// Operador móvil detectado
    required this.operator,
    /// Tecnología de red (3G/4G/5G)
    required this.technology,
    // ... etc
  });
```

---

## ✅ ANÁLISIS COMPLETADOS SIN PROBLEMAS

### ✓ Estructuras de Carpetas
```
✅ lib/
   ✅ data/          (repositorios y servicios)
   ✅ domain/models/ (modelos del dominio)
   ✅ presentation/  (UI y widgets)
      ✅ home/
      ✅ map/
      ✅ theme/
      ✅ widgets/
```
**Estado:** Bien organizado, sigue patrón Clean Architecture

### ✓ Archivos en assets/
```
✅ assets/
   ✅ images/
      ✓ favicon.svg
      ✓ logo.svg
   ✅ data/
      ✓ santiago-recoleta.csv
```
**Estado:** Todos los assets referenciados en pubspec.yaml están presentes

### ✓ .gitignore
**Estado:** Adecuado - excluye:
- Archivos de construcción (`build/`, `.dart_tool/`)
- IDE config (`.idea/`, `.vscode/`)
- Deps (`**/doc/api/`, `.pub-cache/`)

**Recomendación:** Agregar:
```
# Ambientes
.env
.env.*

# Análisis local
*.iml

# MacOS
.DS_Store

# Windows
Thumbs.db
```

### ✓ pubspec.yaml
**Estado:** Dependencias bien seleccionadas
- `flutter_map: ^6.1.0` ✓
- `geolocator: ^11.0.0` ✓
- `latlong2: ^0.9.1` ✓
- `flutter_svg: ^2.0.10+1` ✓
- `flutter_compass: ^0.8.0` ✓

**Nota:** Sin dependencias duplicadas o no utilizadas

### ✓ analysis_options.yaml
**Estado:** Activa flutter_lints (recomendado)  
**Recomendación:** Habilitar reglas adicionales para producción:
```yaml
linter:
  rules:
    - prefer_single_quotes
    - avoid_print
    - avoid_debugPrint
```

### ✓ Imports
**Estado:** Todos los imports utilizados, ninguno innecesario

### ✓ No hay TODO/FIXME/HACK/XXX
**Estado:** ✅ Limpio

### ✓ No hay print()/debugPrint()
**Estado:** ✅ Limpio

### ✓ No hay secrets/API keys/tokens
**Estado:** ✅ Seguro

### ✓ No hay archivos .tmp, .backup
**Estado:** ✅ Limpio

### ✓ No hay rutas locales hardcodeadas
**Estado:** ✅ Solo assets/data/ y assets/images/ (correctas)

### ✓ No hay funciones/widgets sin utilizar
**Estado:** ✅ Todo se utiliza (excepto _coverageLines)

---

## 📊 RESUMEN DE HALLAZGOS

| Severidad | Cantidad | Acción |
|-----------|----------|--------|
| 🔴 CRÍTICO | 2 | Debe corregirse antes de publicar |
| 🟠 ALTO | 5 | Debe corregirse antes de publicar |
| 🟡 MEDIO | 5 | Debe corregirse en próximas versiones |
| 🔵 BAJO | 5 | Mejoras opcionales |
| ✅ CORRECTO | 16 | Sin problemas |

---

## 🚀 LISTA DE TAREAS PARA PUBLICAR

### Fase 1: ANTES DE PUBLICAR (Bloqueantes)
- [ ] **Corregir #1:** Remover caracteres extra en AppBar title ("CoberturApp ))")
- [ ] **Corregir #2:** Estandarizar nombre: RangoApp → CoberturApp en toda la app
- [ ] **Corregir #3:** Extraer métodos duplicados a utilidades compartidas
- [ ] **Corregir #4:** Crear constantes para hardcoded values (15 km, etc)
- [ ] **Corregir #5:** Crear AppStrings para textos hardcodeados

### Fase 2: ANTES DE PUBLICAR (Recomendado)
- [ ] **Corregir #6:** Abstraer regiones en config
- [ ] **Corregir #7:** Remover o implementar _coverageLines
- [ ] **Corregir #8:** Documentar o implementar _handleFindBestSignal
- [ ] **Corregir #9:** Extraer extension hexToColor a archivo separado con validación
- [ ] **Corregir #10:** Abstraer fallback location en config
- [ ] **Corregir #11:** Actualizar tests a textos correctos
- [ ] **Actualizar .gitignore** con patrones adicionales
- [ ] **Agregar rules** en analysis_options.yaml

### Fase 3: PRÓXIMAS VERSIONES (Mejoras)
- [ ] Implementar internacionalización (i18n)
- [ ] Remover favicon duplicado
- [ ] Mejorar documentación en modelos
- [ ] Compartir lógica de ubicación

---

## 🔒 CHECKLIST FINAL ANTES DE GITHUB

```
CÓDIGO LIMPIO:
✅ Sin TODO/FIXME/HACK/XXX
✅ Sin print()/debugPrint()
✅ Sin hardcoded rutas locales
✅ Sin API keys/secrets
✅ Sin archivos temporales/duplicados
✅ Sin imports sin usar

CALIDAD:
❌ Dos errores críticos encontrados (ver Fase 1)
❌ 5 problemas altos encontrados (ver Fase 1)
⚠️ 5 problemas medios encontrados (ver Fase 2)

DOCUMENTACIÓN:
✅ README.md presente
✅ DATA_ARCHITECTURE.md presente
✅ CSV_INTEGRATION_GUIDE.md presente
⚠️ Falta documentación de variables/constantes

TESTING:
⚠️ Un test con búsqueda de texto incorrecto
```

---

## 📝 NOTAS FINALES

**Recomendación General:** El proyecto está bien estructurado y preparado para GitHub, pero **debe corregir los 2 problemas críticos y los 5 problemas altos** antes de publicar.

**Tiempo estimado de correcciones:** 2-3 horas para completar Fase 1 y 2.

**Próximos pasos:**
1. Ejecutar `flutter analyze` y revisar
2. Ejecutar tests: `flutter test`
3. Hacer build: `flutter build web`
4. Revisar estructura final
5. Crear README actualizado
6. Pushear a GitHub

---

*Auditoría realizada el 29/07/2026*
