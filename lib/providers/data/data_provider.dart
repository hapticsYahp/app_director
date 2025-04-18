import 'package:wifi_app/core/graph/trigger_always.dart';
import 'package:wifi_app/core/graph/trigger_equals.dart';
import 'package:wifi_app/core/graph/trigger_lesser_than.dart';
import '../../core/experiment/experiment.dart';
import '../../core/experiment/experiment_stage.dart';
import '../../core/experiment/experiment_stage_confirm.dart';
import '../../core/experiment/experiment_stage_delay.dart';
import '../../core/experiment/experiment_stage_feedback.dart';
import '../../core/experiment/experiment_stage_message.dart';
import '../../core/experiment/experiment_stage_wait.dart';
import '../../core/experiment/result_generator_to_string.dart';
import '../../core/graph/conditional_directed_graph.dart';

class DataProvider {
  List<Experiment<String, String>> getExperiments() {
    ConditionalDirectedGraph<String, String> linealTransitions =
        ConditionalDirectedGraph();
    linealTransitions.addRule("start", TriggerAlways(), "setup");
    linealTransitions.addRule("setup", TriggerAlways(), "run");
    linealTransitions.addRule("run", TriggerEquals("FEEDBACK_YES"), "end");
    linealTransitions.addRule("run", TriggerEquals("TIMEOUT"), "feedback");
    linealTransitions.addRule("feedback", TriggerAlways(), "end");
    Map<String, ExperimentStage<String>> linealStages = {
      "start": ExperimentStageConfirm(
        id: "ABC123_START",
        title: "Confirmation",
        description:
            "Stage description. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam hendrerit dui at sagittis aliquam.",
        confirmationResult: "CONFIRMED",
        pomaCommands: {
          "ENTER": "= intensity 0,0",
        },
      ),
      "setup": ExperimentStageDelay(
        id: "ABC123_SETUP",
        title: "Device Setup",
        description: "The device is being configured, please wait.",
        delayMs: 10_000,
        tickProgressMs: 1_000,
        completionResult: "COMPLETED",
        pomaCommands: {
          "TICK_1000": "= intensity 0,0",
          "TICK_2000": "= intensity 50,50",
          "TICK_3000": "= intensity 0,0",
          "TICK_4000": "= intensity 50,50",
          "TICK_5000": "= intensity 0,0",
          "TICK_6000": "= intensity 50,50",
          "TICK_7000": "= intensity 0,0",
          "TICK_8000": "= intensity 50,50",
          "TICK_9000": "= intensity 0,0",
        },
      ),
      "run": ExperimentStageWait(
        id: "ABC123_WAIT",
        title: "Device Running",
        description:
            "The device is working. Confirm if you feel the vibration.",
        waitingMs: 15_000,
        tickProgressMs: 500,
        timeoutResult: "TIMEOUT",
        feedbackResult: "FEEDBACK_YES",
        pomaCommands: {
          "TICK_1000": "= intensity 10,10",
          "TICK_3000": "= intensity 30,30",
          "TICK_5500": "= intensity 50,50",
          "TICK_7000": "= intensity 70,70",
          "TICK_9500": "= intensity 90,90",
          "EXIT": "= intensity 0,0",
        },
      ),
      "feedback": ExperimentStageFeedback<String>(
        id: "ABC123_FEEDBACK",
        title: "Feedback Stage",
        description: "Please indicate if you felt the vibration.",
        resultGenerator: ResultGeneratorToString(),
        defaultResult: "NO_RESULT",
      ),
      "end": ExperimentStageMessage(
        id: "ABC123_END",
        title: "Completed",
        description: "The experiment has concluded.",
        exitedResult: "EXITED",
        message: "Thank you.",
        pomaCommands: {
          "ENTER": "= intensity 0,0",
          "EXIT": "= intensity 0,0",
        },
      ),
    };
    Experiment<String, String> linealExperiment = Experiment<String, String>(
      id: "ABC123",
      title: "Lineal Experiment",
      description:
          "Experiment description. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam hendrerit dui at sagittis aliquam. Fusce faucibus nec lorem quis scelerisque.",
      stages: linealStages,
      transitions: linealTransitions,
    );

    ConditionalDirectedGraph<String, String> complexTransitions =
        ConditionalDirectedGraph();
    complexTransitions.addRule("start", TriggerAlways(), "setup");
    complexTransitions.addRule("setup", TriggerAlways(), "run_70");
    complexTransitions.addRule(
        "run_70", TriggerEquals("FEEDBACK_YES"), "run_90");
    complexTransitions.addRule("run_70", TriggerEquals("TIMEOUT"), "run_30");
    complexTransitions.addRule("run_90", TriggerEquals("FEEDBACK_YES"), "end");
    complexTransitions.addRule("run_90", TriggerEquals("TIMEOUT"), "feedback");
    complexTransitions.addRule("run_30", TriggerEquals("FEEDBACK_YES"), "end");
    complexTransitions.addRule("run_30", TriggerEquals("TIMEOUT"), "feedback");
    complexTransitions.addRule("feedback", TriggerLesserThan(5), "run_70");
    Map<String, ExperimentStage<String>> complexStages = {
      "start": ExperimentStageConfirm(
        id: "QWE-456_START",
        title: "Confirmation",
        description:
            "Stage description. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam hendrerit dui at sagittis aliquam.",
        confirmationResult: "CONFIRMED",
      ),
      "setup": ExperimentStageDelay(
        id: "QWE-456_SETUP",
        title: "Device Setup",
        description: "The device is being configured, please wait.",
        delayMs: 10_000,
        completionResult: "COMPLETED",
      ),
      "run_30": ExperimentStageWait(
        id: "QWE-456_WAIT_30",
        title: "Device Running (30%)",
        description:
            "The device is working. Confirm if you feel the vibration.",
        waitingMs: 10_000,
        timeoutResult: "TIMEOUT",
        feedbackResult: "FEEDBACK_YES",
      ),
      "run_70": ExperimentStageWait(
        id: "QWE-456_WAIT_70",
        title: "Device Running (70%)",
        description:
            "The device is working. Confirm if you feel the vibration.",
        waitingMs: 10_000,
        timeoutResult: "TIMEOUT",
        feedbackResult: "FEEDBACK_YES",
      ),
      "run_90": ExperimentStageWait(
        id: "QWE-456_WAIT_90",
        title: "Device Running (90%)",
        description:
            "The device is working. Confirm if you feel the vibration.",
        waitingMs: 10_000,
        timeoutResult: "TIMEOUT",
        feedbackResult: "FEEDBACK_YES",
      ),
      "feedback": ExperimentStageFeedback<String>(
        id: "QWE-456_FEEDBACK",
        title: "Feedback Stage",
        description: "Please indicate if you felt the vibration.",
        resultGenerator: ResultGeneratorToString(),
        defaultResult: "NO_RESULT",
      ),
      "end": ExperimentStageMessage(
        id: "QWE-456_END",
        title: "Completed",
        description: "The experiment has concluded.",
        exitedResult: "EXITED",
        message: "Thank you.",
      ),
    };
    Experiment<String, String> complexExperiment = Experiment(
      id: "QWE-456",
      title: "Complex Experiment",
      description:
          "Experimento complejo que varía la ejecución de etapas según feedbacks obtenidos.",
      stages: complexStages,
      transitions: complexTransitions,
    );

    List<Experiment<String, String>> experiments = [
      linealExperiment,
      complexExperiment
    ];

    return experiments;
  }
}
