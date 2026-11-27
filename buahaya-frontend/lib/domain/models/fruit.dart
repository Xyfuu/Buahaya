class Fruit {
  const Fruit({
    required this.id,
    required this.name,
    required this.emoji,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String emoji;
  final String? imageUrl;

  @override
  bool operator ==(Object other) => other is Fruit && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
