class Barrage {
  final String userName;
  final String? content;
  final Gift? gift;

  Barrage(this.userName, this.content, this.gift);

  Barrage.fromJsonMap(Map<String, dynamic> jsonMap)
      : userName = jsonMap['userName'],
        content = jsonMap['content'],
        gift =
            jsonMap['gift'] != null ? Gift.fromJsonMap(jsonMap['gift']) : null;

  Map<String, dynamic> toJsonMap() => {
        'userName': userName,
        'content': content,
        'gift': gift?.toJsonMap(),
      };
}

class Gift {
  final String id;
  final String name;
  final int backgroundColor;
  final int titleColor;
  final int price;

  Gift(this.id, this.name, this.backgroundColor, this.titleColor, this.price);

  Gift.fromJsonMap(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'],
        name = jsonMap['name'],
        backgroundColor = jsonMap['backgroundColor'],
        titleColor = jsonMap['titleColor'],
        price = jsonMap['price'];

  Map<String, dynamic> toJsonMap() => {
        'id': id,
        'name': name,
        'backgroundColor': backgroundColor,
        'titleColor': titleColor,
        'price': price,
      };
}

class Bag {
  final String id;
  final String userId;
  final String giftId;
  int number;

  Bag(this.id, this.userId, this.giftId, this.number);

  Bag.fromJsonMap(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'],
        userId = jsonMap['userId'],
        giftId = jsonMap['giftId'],
        number = jsonMap['number'];

  Map<String, dynamic> toJsonMap() => {
        'id': id,
        'userId': userId,
        'giftId': giftId,
        'number': number,
      };
}
