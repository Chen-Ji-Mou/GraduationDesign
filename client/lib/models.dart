class Barrage {
  final String userName;
  final String content;

  Barrage(this.userName, this.content);

  Barrage.fromJsonMap(Map<String, dynamic> jsonMap)
      : userName = jsonMap['userName'],
        content = jsonMap['content'];

  Map<String, dynamic> toJsonMap() => {
        'userName': userName,
        'content': content,
      };
}
