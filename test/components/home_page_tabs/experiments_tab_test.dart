import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yahp_director/components/home_page_tabs/experiments_tab.dart';
import 'package:yahp_director/core/experiment/experiment.dart';
import 'package:yahp_director/core/experiment/experiment_stage_message.dart';
import 'package:yahp_director/core/graph/trigger_always.dart';
import 'package:yahp_director/core/serialization/serializable_conditional_directed_graph.dart';
import 'package:yahp_director/core/serialization/serializable_experiment.dart';
import 'package:yahp_director/core/trial/device_trial.dart';
import 'package:yahp_director/core/trial/experiment_trial.dart';
import 'package:yahp_director/core/trial/subject_trial.dart';
import 'package:yahp_director/providers/config/config_notifier.dart';
import 'package:yahp_director/providers/config/device_trial_notifier.dart';
import 'package:yahp_director/providers/config/subject_trial_notifier.dart';
import 'package:yahp_director/providers/data/data_provider.dart';
import 'package:yahp_director/providers/poma/poma_client.dart';
import 'package:yahp_director/providers/poma/transport/poma_transport.dart';
import 'package:yahp_director/providers/poma/transport/tcp_poma_transport.dart';

class FakePomaTransport implements PomaTransport {
  bool connected = false;
  final StreamController<Uint8List> _incomingController =
      StreamController<Uint8List>.broadcast();
  final StreamController<String> _debugController =
      StreamController<String>.broadcast();

  bool openCalled = false;
  bool closeCalled = false;

  @override
  bool isValidConnection() => true;

  @override
  bool isConnected() => connected;

  @override
  Future<void> open() async {
    openCalled = true;
    connected = true;
  }

  @override
  Future<void> close() async {
    closeCalled = true;
    connected = false;
  }

  @override
  Stream<Uint8List> get incoming => _incomingController.stream;

  @override
  Stream<String> get onDebug => _debugController.stream;

  @override
  Future<void> send(Uint8List data) async {}

  @override
  void dispose() {
    connected = false;
  }
}

class TestSerializableExperiment extends SerializableExperiment {
  TestSerializableExperiment({
    required super.id,
    required super.title,
    required super.description,
    required super.stages,
    required super.serializableTransitions,
    super.initialStageId,
    super.lastStageId,
    super.cancelStageId,
  });

  bool get hasAnyListeners => hasListeners;
}

class FakeDataProvider extends DataProvider {
  final List<SerializableExperiment> mockExperiments;

  FakeDataProvider(super.config, {this.mockExperiments = const []});

  @override
  Future<List<SerializableExperiment>> getExperiments() async {
    return mockExperiments;
  }

  @override
  Future<ExperimentTrial> createTrial(
    Experiment experiment,
    SubjectTrial subject,
    DeviceTrial device,
  ) async {
    return ExperimentTrial('trial_1', experiment, subject, device);
  }

  @override
  Future<void> saveTrialEvents(ExperimentTrial trial) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  TestSerializableExperiment createSampleExperiment(String id, String title) {
    final stage = ExperimentStageMessage(
      id: 'stg_1',
      title: 'Stage 1',
      message: 'Hello World',
      exitedResult: 'DONE',
    );
    final transitions = SerializableConditionalDirectedGraph();
    transitions.addRule('stg_1', TriggerAlways<String>(), 'stg_1');

    return TestSerializableExperiment(
      id: id,
      title: title,
      description: 'Test experiment description',
      stages: {'stg_1': stage},
      serializableTransitions: transitions,
    );
  }

  Widget createTestWidget({
    required FakeDataProvider dataProvider,
    required SubjectTrialNotifier subjectNotifier,
    required DeviceTrialNotifier deviceNotifier,
    PomaClient? pomaClient,
  }) {
    final configNotifier = ConfigNotifier();
    final client = pomaClient ??
        PomaClient(
          TcpPomaTransport(host: '127.0.0.1', port: 8080),
        );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConfigNotifier>.value(value: configNotifier),
        ChangeNotifierProvider<SubjectTrialNotifier>.value(
          value: subjectNotifier,
        ),
        ChangeNotifierProvider<DeviceTrialNotifier>.value(
          value: deviceNotifier,
        ),
        Provider<PomaClient>.value(value: client),
        Provider<DataProvider>.value(value: dataProvider),
      ],
      child: const MaterialApp(home: Scaffold(body: ExperimentsTab())),
    );
  }

  testWidgets(
    'ExperimentsTab attaches listener on start and removes listener on close and dispose',
    (WidgetTester tester) async {
      final sampleExp = createSampleExperiment('exp_1', 'Exp 1');
      final dataProvider = FakeDataProvider(
        ConfigNotifier(),
        mockExperiments: [sampleExp],
      );
      final subjectNotifier = SubjectTrialNotifier();
      subjectNotifier.selectSubject(SubjectTrial(id: 's1', name: 'Subject 1'));
      final deviceNotifier = DeviceTrialNotifier();
      deviceNotifier.selectDevice(DeviceTrial(id: 'd1', name: 'Device 1'));

      expect(sampleExp.hasAnyListeners, isFalse);

      await tester.pumpWidget(
        createTestWidget(
          dataProvider: dataProvider,
          subjectNotifier: subjectNotifier,
          deviceNotifier: deviceNotifier,
        ),
      );
      await tester.pumpAndSettle();

      // Open Dropdown and select the experiment
      await tester.tap(
        find.byType(DropdownButtonFormField<Experiment<String, String>>),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Exp 1').last);
      await tester.pumpAndSettle();

      // Listener should now be attached
      expect(sampleExp.hasAnyListeners, isTrue);

      // Now close the experiment
      final closeButton = find.widgetWithText(ElevatedButton, 'Close');
      if (closeButton.evaluate().isNotEmpty) {
        await tester.tap(closeButton);
        await tester.pumpAndSettle();
        expect(sampleExp.hasAnyListeners, isFalse);
      }
    },
  );

  testWidgets(
    'ExperimentsTab removes listener on dispose if widget unmounts while experiment active',
    (WidgetTester tester) async {
      final sampleExp = createSampleExperiment('exp_1', 'Exp 1');
      final dataProvider = FakeDataProvider(
        ConfigNotifier(),
        mockExperiments: [sampleExp],
      );
      final subjectNotifier = SubjectTrialNotifier();
      subjectNotifier.selectSubject(SubjectTrial(id: 's1', name: 'Subject 1'));
      final deviceNotifier = DeviceTrialNotifier();
      deviceNotifier.selectDevice(DeviceTrial(id: 'd1', name: 'Device 1'));

      expect(sampleExp.hasAnyListeners, isFalse);

      await tester.pumpWidget(
        createTestWidget(
          dataProvider: dataProvider,
          subjectNotifier: subjectNotifier,
          deviceNotifier: deviceNotifier,
        ),
      );
      await tester.pumpAndSettle();

      // Select experiment
      await tester.tap(
        find.byType(DropdownButtonFormField<Experiment<String, String>>),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Exp 1').last);
      await tester.pumpAndSettle();

      expect(sampleExp.hasAnyListeners, isTrue);

      // Unmount the widget tree by pumping an empty Container
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      // When disposed, removeListener was called
      expect(sampleExp.hasAnyListeners, isFalse);
    },
  );

  testWidgets(
    'ExperimentsTab connects and disconnects using provided PomaClient directly',
    (WidgetTester tester) async {
      final fakeTransport = FakePomaTransport();
      final pomaClient = PomaClient(fakeTransport);
      final dataProvider = FakeDataProvider(ConfigNotifier());
      final subjectNotifier = SubjectTrialNotifier();
      final deviceNotifier = DeviceTrialNotifier();

      await tester.pumpWidget(
        createTestWidget(
          dataProvider: dataProvider,
          subjectNotifier: subjectNotifier,
          deviceNotifier: deviceNotifier,
          pomaClient: pomaClient,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Connect'), findsOneWidget);
      expect(pomaClient.isConnected(), isFalse);
      expect(fakeTransport.openCalled, isFalse);

      // Tap Connect
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();

      expect(fakeTransport.openCalled, isTrue);
      expect(pomaClient.isConnected(), isTrue);
      expect(find.text('Disconnect'), findsOneWidget);

      // Tap Disconnect
      await tester.tap(find.text('Disconnect'));
      await tester.pumpAndSettle();

      expect(fakeTransport.closeCalled, isTrue);
      expect(pomaClient.isConnected(), isFalse);
      expect(find.text('Connect'), findsOneWidget);
    },
  );
}
