# Yahp! Director

**Yahp!** (Yet Another Haptic Project) **Director** es un motor de orquestación y ejecución de ensayos
experimentales diseñado para la investigación en interfaces hápticas. La plataforma permite la definición, serialización
y ejecución de experimentos flexibles mediante una modelización en etapas (símil máquinas de estados) con transiciones
entre ellas (grafos dirigidos condicionales).

## Fundamentos del Sistema

El sistema modela un experimento como un conjunto de estados discretos denominados **Etapas** (`Stages`) y un conjunto
de reglas de control de flujo denominadas **Transiciones** (`Transitions`). La ejecución del ensayo garantiza que en
todo
momento exista una única etapa activa, cuya finalización dispara la evaluación del grafo para determinar el siguiente
estado (etapa).

### Arquitectura de Experimentos

Un experimento en Yahp! Director se define mediante cuatro componentes fundamentales:

1. **Metadatos**: Identificación única, títulos y descripciones operativas.
2. **Etapas (`Stages`)**: Unidades atómicas de interacción que definen la interfaz de usuario y el comportamiento
   háptico durante un intervalo de tiempo.
3. **Grafo de Transiciones**: Un grafo dirigido condicional que orquesta el flujo del experimento basándose en los
   resultados producidos por las etapas.
4. **Puntos de Control**: Definiciones explícitas para la etapa inicial, de finalización exitosa y de aborto.

## Especificación Técnica y Funcional

### Tipos de Etapas

El motor soporta diversos tipos de etapas especializadas, cada una con un ciclo de vida propio y parámetros de
configuración específicos:

- **Confirmación**: espera una acción explícita del usuario.
- **Demora**: espera una cantidad de tiempo antes de continuar.
- **Espera**: combina una espera temporal con la posibilidad de interrupción por parte del usuario.
- **Feedback**: recolección de datos cuantitativos mediante escalas (ej.: un valor de 1 a 10).
- **Selección**: presentación de opciones múltiples (texto o imagen) con soporte para aleatorización.
- **Mensaje**: visualización de un mensaje estático sin controles de transición.
- **Randomización**: orquestador de sub-flujos con ejecución aleatoria de un pool de etapas. Útil para definir
  transiciones aleatorias.

### Ciclo de Vida y Protocolo PoMA

Cada etapa gestiona eventos de ciclo de vida que pueden disparar comandos hacia dispositivos hápticos externos mediante
el protocolo **PoMA**. Estos eventos son:

- `ENTER`: Ejecutado al activar la etapa.
- `EXIT`: Ejecutado al abandonar la etapa.
- `TICK_<ms>`: Ejecutados periódicamente en etapas temporales, permitiendo patrones hápticos sincronizados; `ms` indica
  un valor en milisegundos (ej.: `TICK_1000`, `TICK_2500`, etc.).

Los comandos deben seguir la sintaxis de la especificación PoMA y ser compatibles con la plataforma Yahp!, por ejemplo:

- `= enabled_motors 1,1,0,0,0,0` (activación de actuadores).
- `= intensity 50,50` (ajuste de potencia).

Mantener esta coherencia es responsabilidad del autor de la definición del experimento.

### Sistema de Reglas (`Triggers`)

Las transiciones entre etapas se rigen por funciones lógicas que evalúan el resultado de una etapa para determinar la
siguiente etapa a ejecutar (activar):

- **Lógica Incondicional**: `Always`, `Never`. La transición es estática.
- **Comparación Directa**: `Equals`, `Distinct`. La transición es condicional, se evalúa por igualdad el resultado de la
  etapa previa.
- **Relaciones de Magnitud**: `GreaterThan`, `LesserThan`. El resultao de la etapa previa se compara numéricamente
  contra valores de referencia.

### Serialización JSON

El sistema utiliza una especificación JSON formal para la persistencia y carga de experimentos. Esto permite que los
experimentos sean portables, versionables y fácilmente modificables sin alterar el código fuente del motor.

### Ejecución de Ensayos (`Trials`)

Un **Ensayo** (`Trial`) representa una instancia única de ejecución de un experimento. Para iniciar un ensayo, el
sistema requiere la definición de tres elementos:

1. **Experimento**: la definición lógica del flujo y las etapas.
2. **Sujeto**: el individuo o entidad que participa en el ensayo, permitiendo la trazabilidad de los resultados.
3. **Dispositivo Háptico**: un dispositivo compatible con el protocolo PoMA encargado de ejecutar los estímulos
   programados.

Durante el ensayo, el sistema registra de forma persistente todos los eventos (cambios de etapa, comandos enviados,
respuestas del usuario) para su posterior análisis.

### Documentación Adicional

Para detalles exhaustivos sobre la modelización de experimentos y ejemplos con gráficos pUML,
consultar [Definición de Experimentos](doc/experiments/README.md).

## Implementación y Uso

### Requisitos de Ejecución

Para el funcionamiento del motor, es necesario contar con:

- **Base de Datos**: una instancia de **MongoDB** configurada. El sistema utiliza colecciones especializadas (
  `experiments`, `subjects`, `devices`, `trials`) para la persistencia. La conexión se define mediante la variable
  `MONGODB_CONN_STR` en el archivo de entorno (`.env`).
- **Conectividad PoMA**: un dispositivo háptico habilitado y accesible vía red (TCP/IP) para la orquestación de
  comandos.
- **Ambiente de Ejecución**: Flutter SDK (canal stable) configurado para el desarrollo móvil.

### Configuración del Ambiente de Desarrollo

Para establecer un entorno de desarrollo local, se debe seguir estos pasos:

1. **Clonar el repositorio** y ubicarse en la carpeta root del proyecto:
   ```bash
   git clone <repository_url>
   cd <project_root_folder>
   ```
2. **Instalar dependencias**:
   descargar los paquetes necesarios definidos en `pubspec.yaml`:
   ```bash
   flutter pub get
   ```
3. **Configurar variables de entorno**:
   copiar el archivo de ejemplo (`.env.example`) y configurar las variables necesarias (ej.: la URI de MongoDB):
   ```bash
   cp .env.example .env
   ```
4. **Generar código fuente**:
   el proyecto utiliza generación de código para la serialización JSON y otros componentes. Ejecutar el siguiente
   comando para generar los archivos `.g.dart`:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Despliegue y Ejecución

Para iniciar el entorno de desarrollo y ejecutar la aplicación en un emulador o dispositivo conectado:

```bash
flutter run
```

Para el despliegue en un dispositivo físico **Android**, asegurarse de tener habilitado el modo de depuración USB y
ejecutar:

```bash
flutter run --release
```

---

*Yahp! Director es un desarrollo en colaboración de:*

- ***LIFIA** (Laboratorio de Investigación y Formación en Informática Avanzada), Facultad de Informática, Universidad
  Nacional de La Plata; y*
- *Stream S.A.*

*La Plata, Argentina.*

