class Word {
  final String id, english, vietnamese, idTopic;
  String status;
  String? imageUrl;
  int numberOfAnwserCorrect;
  Word(
      {required this.id,
      required this.english,
      required this.vietnamese,
      required this.idTopic,
      required this.status,
      required this.numberOfAnwserCorrect,
      this.imageUrl});

  factory Word.fromMap(String id, Map<String, dynamic> map) => Word(
        id: id,
        english: map["english"],
        vietnamese: map["vietnamese"],
        idTopic: map["idTopic"],
        status: map["status"] ?? "not learned",
        numberOfAnwserCorrect: map["numberOfAnwserCorrect"] ?? 0,
      );

  Map<String, Object?> toMap() {
    return {
      "english": english.toLowerCase(),
      "vietnamese": vietnamese.toLowerCase(),
      "idTopic": idTopic,
      "status": status,
      "numberOfAnwserCorrect": numberOfAnwserCorrect,
    };
  }
}
