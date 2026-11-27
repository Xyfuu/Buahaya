import 'package:flutter/foundation.dart';

import '../domain/models/fruit.dart';
import '../domain/models/profile.dart';
import '../domain/models/shopping.dart';
import '../domain/repositories/shopping_repository.dart';

class ShoppingController extends ChangeNotifier {
  ShoppingController(this._repo);

  final ShoppingRepository _repo;

  ShoppingList? active;
  List<ShoppingTrip> history = const [];
  List<Fruit> catalog = const [];

    List<ShoppingItem> looseCart = const [];
  bool loading = false;

  bool get hasActive => active != null;

  int get totalFruitsBought => history.fold(0, (s, t) => s + t.totalFruits);

  Duration get averageDuration => history.isEmpty
      ? Duration.zero
      : Duration(
          minutes: history.fold<int>(0, (s, t) => s + t.duration.inMinutes) ~/ history.length);

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      catalog = await _repo.fetchFruitCatalog();
      active = await _repo.fetchActiveList();
      history = await _repo.fetchHistory();
    } catch (_) {}
    loading = false;
    notifyListeners();
  }

  void reset() {
    active = null;
    history = const [];
    looseCart = const [];
    notifyListeners();
  }

    Future<void> _persist(ShoppingList list) async {
    active = list;
    notifyListeners();
    try {
      await _repo.saveList(list);
    } catch (_) {}
  }

  List<ShoppingItem> _mutateItem(
      ShoppingList list, Fruit fruit, ShoppingItem Function(ShoppingItem) fn) {
    final items = List<ShoppingItem>.of(list.items);
    final idx = items.indexWhere((i) => i.fruit.id == fruit.id);
    final updated = fn(idx >= 0 ? items[idx] : ShoppingItem(fruit: fruit));
    if (idx >= 0) {
      items[idx] = updated;
    } else {
      items.add(updated);
    }
    return items.where((i) => i.planned > 0 || i.inCart > 0).toList();
  }

    Future<void> createList({
    required String name,
    String? store,
    required Map<String, int> quantities,
    required UserProfile owner,
    List<ListMember> extraMembers = const [],
  }) async {
    var items = <ShoppingItem>[];
    quantities.forEach((id, qty) {
      if (qty <= 0) return;
      final fruit = catalog.firstWhere((f) => f.id == id);
      items.add(ShoppingItem(fruit: fruit, planned: qty));
    });
        var draft = ShoppingList(
      id: 'list-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      store: (store == null || store.trim().isEmpty) ? null : store.trim(),
      items: items,
      createdAt: DateTime.now(),
      members: [
        ListMember(
            id: owner.id,
            name: owner.firstName,
            handle: '@${owner.username}',
            role: MemberRole.owner),
        ...extraMembers,
      ],
    );
    for (final loose in looseCart) {
      draft = draft.copyWith(
          items: _mutateItem(draft, loose.fruit, (i) => i.copyWith(inCart: i.inCart + loose.inCart)));
    }
    looseCart = const [];
    await _persist(draft);
  }

    Future<void> createSharedList({
    required String identifier,
    required String name,
    required UserProfile owner,
  }) async {
    await createList(name: name, quantities: const {}, owner: owner);
    final list = active!;
    final member = await _repo.inviteMember(listId: list.id, identifier: identifier);
    await _persist(list.copyWith(members: [...list.members, member]));
  }

    Future<void> applyPlan(Map<String, int> quantities) async {
    final list = active;
    if (list == null) return;
    var next = list;
    for (final item in list.items) {
      if (!quantities.containsKey(item.fruit.id)) {
        next = next.copyWith(items: _mutateItem(next, item.fruit, (i) => i.copyWith(planned: 0)));
      }
    }
    quantities.forEach((id, qty) {
      final fruit = catalog.firstWhere((f) => f.id == id);
      next = next.copyWith(items: _mutateItem(next, fruit, (i) => i.copyWith(planned: qty)));
    });
    await _persist(next);
  }

  Future<void> setPlanned(Fruit fruit, int qty) async {
    final list = active;
    if (list == null) return;
    await _persist(list.copyWith(
        items: _mutateItem(list, fruit, (i) => i.copyWith(planned: qty < 0 ? 0 : qty))));
  }

  Future<void> setInCart(Fruit fruit, int qty) async {
    final list = active;
    if (list == null) return;
    await _persist(list.copyWith(
        items: _mutateItem(list, fruit, (i) => i.copyWith(inCart: qty < 0 ? 0 : qty))));
  }

    Future<void> addScanned(Fruit fruit, int count) async {
    if (count <= 0) return;
    final list = active;
    if (list == null) {
      final items = List<ShoppingItem>.of(looseCart);
      final idx = items.indexWhere((i) => i.fruit.id == fruit.id);
      if (idx >= 0) {
        items[idx] = items[idx].copyWith(inCart: items[idx].inCart + count);
      } else {
        items.add(ShoppingItem(fruit: fruit, inCart: count));
      }
      looseCart = items;
      notifyListeners();
      return;
    }
    await _persist(list.copyWith(
        items: _mutateItem(list, fruit, (i) => i.copyWith(inCart: i.inCart + count))));
  }

    Future<void> finish() async {
    final list = active;
    if (list == null) return;
    try {
      final trip = await _repo.finishList(list);
      history = [trip, ...history];
    } catch (_) {
      return;
    }
    active = null;
    notifyListeners();
  }

  Future<void> deleteActive() async {
    final list = active;
    if (list == null) return;
    active = null;
    notifyListeners();
    try {
      await _repo.deleteList(list.id);
    } catch (_) {}
  }

    void joinShared(ShoppingList list) {
    active = list;
    notifyListeners();
  }

  Future<void> renameActive(String name) async {
    final list = active;
    if (list == null || name.trim().isEmpty || name.trim() == list.name) return;
    await _persist(list.copyWith(name: name.trim()));
  }

      Future<String?> invite(String identifier) async {
    final list = active;
    final id = identifier.trim();
    if (list == null) return 'No active list.';
    if (id.isEmpty) return 'Enter a username or email.';
    final normalized = id.toLowerCase().replaceFirst('@', '');
    if (list.members.any((m) =>
        m.handle.toLowerCase().replaceFirst('@', '') == normalized)) {
      return 'This person is already in the list.';
    }
    try {
      final member = await _repo.inviteMember(listId: list.id, identifier: id);
      await _persist(list.copyWith(members: [...list.members, member]));
      return null;
    } catch (_) {
      return 'Could not send the invitation.';
    }
  }

  Future<void> removeMember(String memberId) async {
    final list = active;
    if (list == null) return;
    try {
      await _repo.removeMember(listId: list.id, memberId: memberId);
    } catch (_) {}
    await _persist(list.copyWith(members: list.members.where((m) => m.id != memberId).toList()));
  }

  Future<void> stopSharing() async {
    final list = active;
    if (list == null) return;
    for (final m in list.members.where((m) => !m.isOwner)) {
      try {
        await _repo.removeMember(listId: list.id, memberId: m.id);
      } catch (_) {}
    }
    await _persist(list.copyWith(members: list.members.where((m) => m.isOwner).toList()));
  }
}
