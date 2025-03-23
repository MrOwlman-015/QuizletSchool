class LearningProcess {
  final String id, idTopic, idUser;
  List<String> notLearnWords = [];
  List<String> learningWords = [];
  List<String> memorizedWords = [];

  LearningProcess({
    required this.id,
    required this.idTopic,
    required this.idUser,
    required this.notLearnWords,
    required this.learningWords,
    required this.memorizedWords,
  });

  factory LearningProcess.fromMap(String id, Map<String, dynamic> map) =>
      LearningProcess(
        id: map["id"],
        idTopic: map["idTopic"],
        idUser: map["idUser"],
        notLearnWords: map["notLearnWords"],
        learningWords: map["learningWords"],
        memorizedWords: map["memorizedWords"],
      );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "idTopic": idTopic,
      "idUser": idUser,
      "notLearnWords": notLearnWords,
      "learningWords": learningWords,
      "memorizedWords": memorizedWords,
    };
  }
}
