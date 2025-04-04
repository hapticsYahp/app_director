import '../../core/experiment/experiment.dart';
import '../../core/experiment/experiment_stage.dart';
import '../../core/experiment/experiment_stage_confirm.dart';
import '../../core/experiment/experiment_stage_delay.dart';
import '../../core/experiment/experiment_stage_feedback.dart';
import '../../core/experiment/experiment_stage_message.dart';
import '../../core/experiment/experiment_stage_wait.dart';
import '../../core/graph/conditional_directed_graph.dart';

class DataProvider {
  List<Experiment<String, String>> getExperiments() {
    ConditionalDirectedGraph<String, String> linealTransitions =
        ConditionalDirectedGraph();
    linealTransitions.addRule("start", (input) => true, "setup");
    linealTransitions.addRule("setup", (input) => true, "run");
    linealTransitions.addRule(
        "run", (input) => (input == "FEEDBACK_YES"), "end");
    linealTransitions.addRule(
        "run", (input) => (input == "TIMEOUT"), "feedback");
    linealTransitions.addRule("feedback", (input) => true, "end");
    Map<String, ExperimentStage<String>> linealStages = {
      "start": ExperimentStageConfirm(
        id: "ABC123_START",
        title: "Confirmation",
        description:
            "Stage description. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam hendrerit dui at sagittis aliquam.",
        confirmationResult: "CONFIRMED",
        pomaCommands: {
          "ENTER": "= intensity 0,0,0,0",
        },
      ),
      "setup": ExperimentStageDelay(
        id: "ABC123_SETUP",
        title: "Device Setup",
        description: "The device is being configured, please wait.",
        delaySeconds: 10,
        completionResult: "COMPLETED",
        pomaCommands: {
          "ENTER": "= intensity 1,1,1,1",
          "TICK_1": "= intensity 0,0,0,0",
          "TICK_9": "= intensity 1,1,1,1",
          "TICK_10": "= intensity 0,0,0,0",
        },
      ),
      "run": ExperimentStageWait(
        id: "ABC123_WAIT",
        title: "Device Running",
        description:
            "The device is working. Confirm if you feel the vibration.",
        waitingSeconds: 15,
        timeoutResult: "TIMEOUT",
        feedbackResult: "FEEDBACK_YES",
        pomaCommands: {
          "TICK_1": "= intensity 10,10,10,10",
          "TICK_3": "= intensity 30,30,30,30",
          "TICK_5": "= intensity 50,50,50,50",
          "TICK_7": "= intensity 70,70,70,70",
          "TICK_9": "= intensity 90,90,90,90",
          "EXIT": "= intensity 0,0,0,0",
        },
      ),
      "feedback": ExperimentStageFeedback(
        id: "ABC123_FEEDBACK",
        title: "Feedback Stage",
        description: "Please indicate if you felt the vibration.",
        getResult: (scaleValue) => scaleValue.toString(),
      ),
      "end": ExperimentStageMessage(
        id: "ABC123_END",
        title: "Completed",
        description: "The experiment has concluded.",
        exitedResult: "EXITED",
        message: "Thank you.",
        pomaCommands: {
          "ENTER": "= intensity 0,0,0,0",
          "EXIT": "= intensity 0,0,0,0",
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
    complexTransitions.addRule("start", (input) => true, "setup");
    complexTransitions.addRule("setup", (input) => true, "run_70");
    complexTransitions.addRule(
        "run_70", (input) => (input == "FEEDBACK_YES"), "run_90");
    complexTransitions.addRule(
        "run_70", (input) => (input == "TIMEOUT"), "run_30");
    complexTransitions.addRule(
        "run_90", (input) => (input == "FEEDBACK_YES"), "end");
    complexTransitions.addRule(
        "run_90", (input) => (input == "TIMEOUT"), "feedback");
    complexTransitions.addRule(
        "run_30", (input) => (input == "FEEDBACK_YES"), "end");
    complexTransitions.addRule(
        "run_30", (input) => (input == "TIMEOUT"), "feedback");
    complexTransitions.addRule(
        "feedback", (input) => int.tryParse(input)! < 5, "run_70");
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
        delaySeconds: 10,
        completionResult: "COMPLETED",
      ),
      "run_30": ExperimentStageWait(
        id: "QWE-456_WAIT_30",
        title: "Device Running (30%)",
        description:
            "The device is working. Confirm if you feel the vibration.",
        waitingSeconds: 10,
        timeoutResult: "TIMEOUT",
        feedbackResult: "FEEDBACK_YES",
      ),
      "run_70": ExperimentStageWait(
        id: "QWE-456_WAIT_70",
        title: "Device Running (70%)",
        description:
            "The device is working. Confirm if you feel the vibration.",
        waitingSeconds: 10,
        timeoutResult: "TIMEOUT",
        feedbackResult: "FEEDBACK_YES",
      ),
      "run_90": ExperimentStageWait(
        id: "QWE-456_WAIT_90",
        title: "Device Running (90%)",
        description:
            "The device is working. Confirm if you feel the vibration.",
        waitingSeconds: 10,
        timeoutResult: "TIMEOUT",
        feedbackResult: "FEEDBACK_YES",
      ),
      "feedback": ExperimentStageFeedback(
        id: "QWE-456_FEEDBACK",
        title: "Feedback Stage",
        description: "Please indicate if you felt the vibration.",
        getResult: (scaleValue) => scaleValue.toString(),
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
