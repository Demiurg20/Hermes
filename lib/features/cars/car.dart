class Car {
  final int id;
  final String name;
  final String image;
  final double price;
  final double rating;
  final String type;

  Car({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.type,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json["id"],
      name: json["name"],
      image: json["image"],
      price: (json["price"] as num).toDouble(),
      rating: (json["rating"] as num).toDouble(),
      type: json["type"],
    );
  }
}