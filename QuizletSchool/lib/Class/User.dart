class Users {
  final String id, email, bookMarkFolder, folderID;
  String name;
  String? avatarUrl;
  List<String> favoriteTopics = [];
  List<String> favoriteWords = [];

  Users({
    required this.id,
    required this.name,
    required this.email,
    required this.bookMarkFolder,
    required this.folderID,
    this.avatarUrl,
    required this.favoriteTopics,
    required this.favoriteWords,
  });

  factory Users.fromMap(String id, Map<String, dynamic> map) => Users(
        id: id,
        name: map["name"],
        email: map["email"],
        avatarUrl: map["avatarUrl"] ?? "",
        folderID: map["folderID"],
        bookMarkFolder: "bookmark_topics",
        favoriteTopics: List.from(map["favoriteTopics"]),
        favoriteWords: List.from(map["favoriteWords"]),
      );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "avatarUrl": avatarUrl,
      "folderID": folderID,
      "favoriteTopics": favoriteTopics,
      "favoriteWords": favoriteWords,
    };
  }
}
