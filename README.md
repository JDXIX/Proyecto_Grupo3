# Guía accesible de medicación en lectura fácil (Grupo 3)

## Descripción
Este proyecto es una aplicación desarrollada en **Flutter** orientada a apoyar a personas con **discapacidad visual** mediante una guía accesible de medicación en **lectura fácil**.

La aplicación permite:
- Consultar información clara y simple de un medicamento (para qué sirve, cómo tomarlo, advertencias).
- Reproducir dichas instrucciones mediante **audio** usando **Text To Speech (TTS)**.
- Mantener (administrar) los medicamentos e instrucciones mediante un **CRUD** en una base local **SQLite**.

> Este repositorio corresponde al trabajo del **Grupo 3**, responsable de la **base de datos, mantenimiento (CRUD) y accesibilidad (lectura fácil + audio)**.

---

## Objetivo del proyecto
Construir un sistema que, una vez identificado un medicamento (por cámara/OCR en otro módulo), permita:
1. Recibir un **ID o nombre normalizado** del medicamento.
2. Buscarlo en una base local **SQLite**.
3. Mostrar instrucciones en lectura fácil.
4. Reproducir la información por audio.

---

## Alcance del Grupo 3 (Requerimientos)
### Base de datos
- **SQLite local**
- Sin backend
- Sin conexión a internet
- Sin multiusuario

### Accesibilidad / Audio
- Reproducción de texto a voz con el plugin:
  - `flutter_tts`

### Funcionalidad final
1. Recibir un ID/nombre de medicamento (simulado o real).
2. Buscar el medicamento en SQLite.
3. Mostrar información en lectura fácil:
   - Para qué sirve
   - Cómo tomarlo
   - Advertencias
4. Reproducir en audio cada sección.
5. Ejecutar en emulador Android.

> Nota: El proyecto se desarrolla para una sola persona, por lo que no se requiere escalabilidad.

---

## Integración con el Grupo 2
El **Grupo 2** se encarga de:
- Cámara / sensor
- OCR (reconocimiento del medicamento)
- Generación del **ID del medicamento**

El **Grupo 3** recibe ese ID y realiza la consulta en SQLite para mostrar y leer la información.

Actualmente, para fines de prueba, se simula la entrada del OCR con un ID fijo (ej: `paracetamol`).

---

## Tecnologías y dependencias principales
- Flutter / Dart
- Base de datos local: `sqflite`
- Manejo de rutas: `path`
- Audio (TTS): `flutter_tts`

---

## Estructura del proyecto (Arquitectura MVC simplificada)

Se utiliza una separación clara de responsabilidades (MVC simple):

```
lib/
├── models/
│    └── medicamento.dart
│       - Modelo de datos del medicamento (estructura y mapeo a SQLite)
│
├── database/
│    └── database_helper.dart
│       - Inicialización de SQLite
│       - Creación de tabla `medicamentos`
│       - Métodos CRUD (Create, Read, Update, Delete)
│
├── services/
│    └── audio_service.dart
│       - Servicio de accesibilidad: Text To Speech (TTS)
│
├── screens/
│    ├── medicamento_screen.dart
│    │   - Pantalla principal accesible (lectura fácil + botones de audio)
│    │
│    └── crud_medicamentos_screen.dart
│        - Pantalla de mantenimiento (CRUD) para administrar medicamentos
│
└── main.dart
    - Punto de entrada de la aplicación (MaterialApp + navegación inicial)
```

---

## Base de datos (SQLite)

### ¿Dónde se guarda la base de datos?
La base de datos se almacena en el **almacenamiento interno del dispositivo/emulador**, no dentro del repositorio.

En Android normalmente se ubica en:
```
/data/data/<paquete_de_la_app>/databases/medicamentos.db
```

### Tabla utilizada
Se maneja una tabla única:

**Tabla:** `medicamentos`

**Campos:**
- `id` (TEXT, PRIMARY KEY)
- `nombre` (TEXT)
- `para_que_sirve` (TEXT)
- `como_tomar` (TEXT)
- `advertencias` (TEXT)

### Datos iniciales
En la creación de la base (primer arranque) se insertan registros de ejemplo (por ejemplo `paracetamol` e `ibuprofeno`) para facilitar pruebas y demostración.

---

## CRUD (Mantenimiento de medicamentos)
El CRUD se realiza desde la pantalla de mantenimiento:

- **Create:** Agregar medicamento
- **Read:** Listar medicamentos
- **Update:** Editar medicamento (si está implementado en tu versión)
- **Delete:** Eliminar medicamento

Este módulo permite actualizar la información sin necesidad de modificar el código.

---

## Pantalla accesible (Usuario final)
La pantalla accesible muestra:
- Nombre del medicamento
- Secciones con texto simple:
  - ¿Para qué sirve?
  - ¿Cómo tomarlo?
  - Advertencias

Cada sección tiene un botón de altavoz para reproducir la información por TTS.

---

## Ejecución del proyecto

### Requisitos previos
- Flutter instalado y configurado
- Emulador Android configurado (Android Studio o equivalente)
- Visual Studio Code con extensiones Flutter y Dart

### Instalar dependencias
Desde la raíz del proyecto:

```bash
flutter pub get
```

### Ejecutar

```bash
flutter run
```

---

## Notas importantes (presentación académica)

* El sistema está diseñado para una sola persona, por lo que se prioriza simplicidad y accesibilidad.
* La integración con OCR/cámara pertenece al Grupo 2; el Grupo 3 se enfoca en:

  * Base de datos local (SQLite)
  * CRUD de mantenimiento
  * Interfaz de lectura fácil
  * Audio TTS

---

## Autores

* Grupo 3 — Desarrollo de Aplicaciones Móviles (Flutter)