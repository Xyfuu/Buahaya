import 'dart:math' as math;

import 'fruit.dart';

enum MemberRole { owner, member }

enum MemberStatus { active, pending }

class ListMember {
  const ListMember({
    required this.id,
    required this.name,
    required this.handle,
    this.role = MemberRole.member,
    this.status = MemberStatus.active,
  });

  final String id;
  final String name;
  final String handle;
  final MemberRole role;
  final MemberStatus status;

  bool get isOwner => role == MemberRole.owner;
  bool get isPending => status == MemberStatus.pending;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final s = parts.length > 1 ? parts[0][0] + parts[1][0] : name.substring(0, math.min(2, name.length));
    return s.toUpperCase();
  }
}

class ShoppingItem {
  const ShoppingItem({required this.fruit, this.planned = 0, this.inCart = 0});

  final Fruit fruit;
  final int planned;
  final int inCart;

  int get remaining => math.max(0, planned - inCart);

  ShoppingItem copyWith({int? planned, int? inCart}) => ShoppingItem(
      fruit: fruit, planned: planned ?? this.planned, inCart: inCart ?? this.inCart);
}

class ShoppingList {
  const ShoppingList({
    required this.id,
    required this.name,
    this.store,
    this.items = const [],
    this.members = const [],
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? store;
  final List<ShoppingItem> items;
  final List<ListMember> members;
  final DateTime createdAt;

  bool get isShared => members.length > 1;
  List<ShoppingItem> get planItems => items.where((i) => i.planned > 0).toList();
  List<ShoppingItem> get cartItems => items.where((i) => i.inCart > 0).toList();
  int get fruitTypes => planItems.length;
  int get totalPlanned => planItems.fold(0, (s, i) => s + i.planned);
  int get totalRemaining => planItems.fold(0, (s, i) => s + i.remaining);
  int get activeMemberCount => members.where((m) => !m.isPending).length;

  ShoppingItem? itemFor(String fruitId) {
    for (final i in items) {
      if (i.fruit.id == fruitId) return i;
    }
    return null;
  }

  ShoppingList copyWith({
    String? name,
    String? store,
    List<ShoppingItem>? items,
    List<ListMember>? members,
  }) =>
      ShoppingList(
        id: id,
        name: name ?? this.name,
        store: store ?? this.store,
        items: items ?? this.items,
        members: members ?? this.members,
        createdAt: createdAt,
      );
}

class TripFruit {
  const TripFruit({required this.fruit, required this.count});
  final Fruit fruit;
  final int count;
}

class ShoppingTrip {
  const ShoppingTrip({
    required this.id,
    required this.name,
    required this.finishedAt,
    required this.duration,
    this.store,
    this.partners = const [],
    this.fruits = const [],
  });

  final String id;
  final String name;
  final DateTime finishedAt;
  final Duration duration;
  final String? store;
  final List<String> partners;
  final List<TripFruit> fruits;

  int get totalFruits => fruits.fold(0, (s, f) => s + f.count);
  int get fruitTypes => fruits.length;
}
