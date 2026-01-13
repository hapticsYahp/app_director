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

  Widget _buildOptionTitle(SelectOption option) {
    final img = option.image;
    if (option.isNetworkImage) {
      return Image.network(img!, fit: BoxFit.contain);
    }
    if (option.isAssetImage) {
      return Image.asset(img!, fit: BoxFit.contain);
    }
    return Center(child: Text(option.label, textAlign: TextAlign.center));
  }

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
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: _options.length,
            itemBuilder: (context, index) {
              final option = _options[index];
              final selected = widget.stage.multipleSelection
                  ? _multiSelected.contains(option.value)
                  : _singleSelected == option.value;
              Widget optionTitle = _buildOptionTitle(option);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (widget.stage.multipleSelection) {
                      if (selected) {
                        _multiSelected.remove(option.value);
                      } else {
                        _multiSelected.add(option.value);
                      }
                    } else {
                      _singleSelected = option.value;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(microseconds: 150),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected ? Colors.blue : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Center(child: optionTitle),
                ),
              );
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
