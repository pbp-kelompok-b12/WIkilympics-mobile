class PollOption {
  final int id;
  final String optionText;
  final int votes;

  PollOption({
    required this.id,
    required this.optionText,
    required this.votes,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) => PollOption(
    id: json['id'],
    optionText: json['option_text'],
    votes: json['votes'],
  );
}

class PollQuestion {
  final int id;
  final String questionText;
  final List<PollOption> options;

  PollQuestion({
    required this.id,
    required this.questionText,
    required this.options,
  });

  factory PollQuestion.fromJson(Map<String, dynamic> json) => PollQuestion(
    id: json['id'],
    questionText: json['question_text'],
    options: (json['options'] as List)
        .map((opt) => PollOption.fromJson(opt))
        .toList(),
  );
}