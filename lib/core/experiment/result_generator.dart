abstract class ResultGenerator<T_Result> {
  const ResultGenerator();

  T_Result getResult(int value);

  Map<String, dynamic> toJson();

  String getJsonType();
}
