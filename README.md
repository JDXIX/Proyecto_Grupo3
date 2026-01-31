# VOXIA - Guía accesible de medicación en lectura fácil

## Descripción
**VOXIA** es una aplicación desarrollada en **Flutter** diseñada para apoyar a personas con **discapacidad visual** mediante una guía accesible de medicación centrada en la **lectura fácil** y la **asistencia por voz**.

El sistema es el resultado de la integración exitosa de los esfuerzos de los Grupos 2 y 3, ofreciendo una solución completa que abarca desde el reconocimiento físico del medicamento hasta la gestión y lectura de su información.

La aplicación permite:
- **Reconocimiento OCR**: Identificar medicamentos mediante la cámara o fotos de la galería.
- **Búsqueda Avanzada**: Localizar rápidamente medicamentos específicos en la base de datos local.
- **Lectura Fácil**: Consultar información clara y simple (para qué sirve, cómo tomarlo, advertencias).
- **Asistencia por Voz**: Reproducir las instrucciones mediante **audio** usando **Text To Speech (TTS)**.
- **Gestión Completa (CRUD)**: Administrar el inventario de medicamentos en una base local **SQLite**.

---

## Objetivo del proyecto
Construir un ecosistema funcional que permita a un usuario con dificultades visuales:
1. **Identificar** un medicamento usando visión artificial (OCR).
2. **Consultar** automáticamente la base de datos local **SQLite**.
3. **Escuchar** las instrucciones en un lenguaje sencillo y comprensible.
4. **Gestionar** su propio catálogo de medicamentos de manera autónoma.

---

## Funcionalidades Implementadas
### Gestión de Medicentamos (Grupo 3)
- **Base de Datos SQLite**: Almacenamiento local persistente y seguro.
- **Buscador Inteligente**: Filtrado en tiempo real en la lista de medicamentos.
- **CRUD Completo**: Añadir, editar, listar y eliminar medicamentos con interfaz intuitiva.
- **Accesibilidad**: Botones grandes, contrastes adecuados y soporte TTS por sección.

### Reconocimiento y Visión (Grupo 2)
- **Escaneo con Cámara**: Captura de texto en vivo para identificación.
- **Importación de Galería**: Reconocimiento de texto desde imágenes existentes.
- **Normalización**: Procesamiento del texto reconocido para coincidir con la base de datos.

---

## Tecnologías y dependencias principales
- **Framework**: Flutter / Dart
- **Base de datos**: `sqflite`
- **Reconocimiento de Texto**: `google_mlkit_text_recognition`
- **Cámara y Visión**: `camera`, `image_picker`
- **Audio (TTS)**: `flutter_tts`
- **Permisos**: `permission_handler`

---

## Estructura del proyecto
La arquitectura sigue un patrón modular para facilitar el mantenimiento:

```
lib/
├── models/      - Definición de entidades (Medicamento).
├── database/    - Configuración de SQLite y carga de semillas (Seeds).
├── services/    - Lógica de Audio y Servicios de Sistema.
├── screens/
│    ├── recognition/ - Módulos de Cámara y OCR (Grupo 2).
│    ├── medicamento/ - Pantalla de lectura fácil y audio.
│    └── maintenance/ - Panel CRUD y Buscador (Grupo 3).
├── theme/       - Sistema de diseño y colores (AppTheme).
└── widgets/     - Componentes de UI reutilizables.
```

---

## Ejecución del proyecto

### Requisitos previos
- Flutter SDK (^3.9.0)
- Dispositivo físico o Emulador Android con soporte para cámara.

### Instalación
1. Clonar el repositorio.
2. Instalar dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecutar la aplicación:
   ```bash
   flutter run
   ```

---

## Notas de la Versión Final
* Se ha logrado una integración total entre el módulo de visión y el de base de datos.
* El sistema funciona 100% offline, garantizando disponibilidad y privacidad.
* La interfaz ha sido pulida para ofrecer una experiencia premium y accesible.

---

## Autores
* **Grupo 2**: Módulo de Visión, OCR y Cámara.
* **Grupo 3**: Módulo de Base de Datos, Gestión (CRUD) y Accesibilidad.
