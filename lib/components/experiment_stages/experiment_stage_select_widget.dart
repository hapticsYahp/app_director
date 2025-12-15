import 'package:flutter/material.dart';
import '../../core/experiment/experiment_stage_select.dart';

class ExperimentStageSelectWidget<T_Result> extends StatefulWidget {
  final ExperimentStageSelect<T_Result> stage;
  final void Function(T_Result result) onComplete;

  const ExperimentStageSelectWidget({
    required ValueKey<String> super.key,
    required this.stage,
    required this.onComplete,
  });

  @override
  State<ExperimentStageSelectWidget<T_Result>> createState() =>
      _ExperimentStageSelectWidgetState<T_Result>();
}

class _ExperimentStageSelectWidgetState<T_Result>
    extends State<ExperimentStageSelectWidget<T_Result>> {
  late List<SelectOption> _options;
  String? _singleSelected;
  final Set<String> _multiSelected = {};

  @override
  void initState() {
    super.initState();
    widget.stage.onEnter();
    _options = List<SelectOption>.from(widget.stage.options);
    if (widget.stage.shuffleOptions) {
      _options.shuffle();
    }
  }

  @override
  void didUpdateWidget(covariant ExperimentStageSelectWidget<T_Result> old) {
    super.didUpdateWidget(old);
    if (widget.stage != old.stage) {
      widget.stage.onEnter();
      _options = List<SelectOption>.from(widget.stage.options);
      if (widget.stage.shuffleOptions) {
        _options.shuffle();
      }
      setState(() {
        _singleSelected = null;
        _multiSelected.clear();
      });
    }
  }

  void _onConfirm() {
    if (!_hasSelection) return;
    String result;
    if (widget.stage.multipleSelection) {
      result = _multiSelected.join(";");
    } else {
      result = _singleSelected ?? "";
    }
    widget.onComplete(result as T_Result);
    widget.stage.onExit();
  }

  void _onClear() {
    setState(() {
      _singleSelected = null;
      _multiSelected.clear();
    });
  }

  bool get _hasSelection => widget.stage.multipleSelection
      ? _multiSelected.isNotEmpty
      : _singleSelected != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.stage.question.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              widget.stage.question,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _options.length,
            itemBuilder: (context, index) {
              final option = _options[index];
              if (widget.stage.multipleSelection) {
                final checked = _multiSelected.contains(option.value);
                return CheckboxListTile(
                  title: Text(option.label),
                  value: checked,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _multiSelected.add(option.value);
                      } else {
                        _multiSelected.remove(option.value);
                      }
                    });
                  },
                );
              } else {
                return RadioListTile<String>(
                  title: Text(option.label),
                  value: option.value,
                  groupValue: _singleSelected,
                  onChanged: (v) {
                    setState(() {
                      _singleSelected = v;
                    });
                  },
                );
              }
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _hasSelection ? _onClear : null,
                icon: Icon(widget.stage.clearButtonIcon),
                label: Text(widget.stage.clearButtonLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _hasSelection ? _onConfirm : null,
                icon: Icon(widget.stage.confirmButtonIcon),
                label: Text(widget.stage.confirmButtonLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
