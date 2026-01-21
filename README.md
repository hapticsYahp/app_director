# Yahp! Director

**Yahp!** (Yet Another Haptic Project) **Director** is an experimental orchestration and execution engine designed for
haptic interface research. The platform allows the definition, serialization, and execution of flexible experiments
through staged modeling (similar to state machines) with transitions between stages (conditional directed graphs).

## System Fundamentals

The system models an experiment as a set of discrete states called **Stages** and a set of flow control rules called
**Transitions**. The execution of the experiment ensures that at any given time there is only one active stage, the
completion of which triggers the evaluation of the graph to determine the next state (stage).

### Experiment Architecture

An experiment in Yahp! Director is defined by four fundamental parts:

1. **Metadata**: Unique identifier, titles, and operational descriptions.
2. **Stages**: Atomic units of interaction that define the user interface and haptic behavior over a time interval.
3. **Transition Graph**: A conditional directed graph that orchestrates the flow of the experiment based on the results
   produced by the stages.
4. **Checkpoints**: Explicit definitions for the initial stage, successful completion, and abort.

## Technical and Functional Specification

### Stage Types

The engine supports various types of specialized stages, each with its own lifecycle and specific configuration
parameters:

- **Confirm**: waits for an explicit action from the user.
- **Delay**: waits a certain amount of time before continuing.
- **Wait**: combines a temporary wait with the possibility of interruption by the user.
- **Feedback**: obtains quantitative data using scales (e.g., a value from 1 to 10).
- **Select**: presents multiple options (text or image) with support for randomization.
- **Message**: displays a static message without transition controls.
- **Shuffle**: An orchestrator for sub-flows that randomly executes a collection of stages, ideal for establishing
  non-deterministic transitions.

### Lifecycle and PoMA Protocol

Each stage manages lifecycle events that can trigger commands to external haptic devices using the **PoMA** protocol.
These events are:

- `ENTER`: executed when the stage is activated.
- `EXIT`: executed when the stage is exited.
- `TICK_<ms>`: executed periodically at timed stages, allowing synchronized haptic patterns; `ms` indicates a value in
  milliseconds (e.g., `TICK_1000`, `TICK_2500`, etc.).

Commands must follow the PoMA specification syntax and be compatible with the "Yahp!" platform, for example:

- `= enabled_motors 1,1,0,0,0,0` (activation of actuators).
- `= intensity 50,50` (power adjustment).

Maintaining this consistency is the responsibility of the experiment definition author.

### Rule System (`Triggers`)

Transitions between stages are governed by logic functions that evaluate the result of a stage to determine the next
stage to execute (activate):

- **Unconditional Logic**: `Always`, `Never`. The transition is static.
- **Direct Comparison**: `Equals`, `Distinct`. The transition is conditional; the result of the previous stage is
  evaluated for equality.
- **Magnitude Relationships**: `GreaterThan`, `LesserThan`. The result of the previous stage is compared numerically
  against reference values.

### JSON Serialization

The system uses a formal JSON specification for experiment persistence and loading. This allows experiments to be
portable, versionable, and easily modified without altering the engine's source code.

### Experiments Execution (`Trials`)

A **Trial** represents a single instance of an experiment being executed. To start a trial, the system requires the
definition of three elements:

1. **Experiment**: the logical definition of the flow and stages.
2. **Subject**: the individual participating in the trial, allowing for traceability of the results.
3. **Haptic Device**: a PoMA-compliant device responsible for executing the programmed stimuli.

During the experiment, the system persistently records all events (stage changes, commands sent, user responses) for
later analysis.

### Additional Documentation

For comprehensive details on experiment modeling and examples with pUML graphs,
see [Experiment Definition](doc/experiments/README.md).

## Implementation and Use

### Runtime Requirements

For the engine to function, the following is required:

- **Database**: a configured **MongoDB** instance. The system uses specialized collections (`experiments`, `subjects`,
  `devices`, `trials`) for persistence. The connection is defined using the `MONGODB_CONN_STR` variable in the
  environment file (`.env`).
- **PoMA Connectivity**: a haptic device enabled and accessible via network (TCP/IP) for command orchestration.
- **Execution Environment**: a Flutter SDK (stable channel) configured for mobile development.

### Setting Up the Development Environment

To set up a local development environment, follow these steps:

1. **Clone the repository** and navigate to the project's root folder:
   ```bash
   git clone <repository_url>
   cd <project_root_folder>
   ```

2. **Install dependencies**:

   download the necessary packages defined in `pubspec.yaml`:
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**:

   copy the example file (`.env.example`) and configure the necessary variables (e.g., the MongoDB URI):
   ```bash
   cp .env.example .env
   vi .env
   ```

4. **Generate source code**:

   the project uses code generation for JSON serialization and other components. Run the following command to generate
   the `.g.dart` files:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Deployment and Execution

To start the development environment and run the application on an emulator or connected device:

```bash
flutter run
```

For deployment on a physical **Android** device, ensure USB debugging is enabled and run:

```bash
flutter run --release
```

---

*Yahp! Director is a collaborative development by:*

- ***LIFIA** (Laboratorio de Investigación y Formación en Informática Avanzada), Facultad de Informática, Universidad
  Nacional de La Plata; and*
- *Stream S.A.*

*La Plata, Argentina.*

