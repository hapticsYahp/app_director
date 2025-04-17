abstract class Trigger<T_Input> {
  const Trigger();

  bool evaluate(T_Input input);

  Map<String, dynamic> toJson(Object? Function(T_Input value) toJsonTInput);

  String getJsonType();
}
