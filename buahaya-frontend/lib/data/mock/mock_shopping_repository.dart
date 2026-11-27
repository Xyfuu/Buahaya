import '../../domain/models/fruit.dart';
import '../../domain/models/shopping.dart';
import '../../domain/repositories/shopping_repository.dart';
import 'mock_seed.dart';

class MockShoppingRepository implements ShoppingRepository {
  ShoppingList? _active = MockSeed.activeList();
  final List<ShoppingTrip> _history = MockSeed.history();

  Future<void> _latency() => Future<void>.delayed(const Duration(milliseconds: 200));

  @override
  Future<List<Fruit>> fetchFruitCatalog() async {
    await _latency();
    return MockSeed.catalog;
  }

  @override
  Future<ShoppingList?> fetchActiveList() async {
    await _latency();
    return _active;
  }

  @override
  Future<ShoppingList> saveList(ShoppingList list) async {
    await _latency();
    return _active = list;
  }

  @override
  Future<void> deleteList(String listId) async {
    await _latency();
    if (_active?.id == listId) _active = null;
  }

  @override
  Future<ShoppingTrip> finishList(ShoppingList list) async {
    await _latency();
    final trip = ShoppingTrip(
      id: 'trip-${DateTime.now().millisecondsSinceEpoch}',
      name: list.name,
      finishedAt: DateTime.now(),
      duration: DateTime.now().difference(list.createdAt),
      store: list.store,
      partners: list.members.where((m) => !m.isOwner).map((m) => m.handle).toList(),
      fruits: [
        for (final i in list.cartItems) TripFruit(fruit: i.fruit, count: i.inCart),
      ],
    );
    _history.insert(0, trip);
    _active = null;
    return trip;
  }

  @override
  Future<List<ShoppingTrip>> fetchHistory() async {
    await _latency();
    return List.unmodifiable(_history);
  }

  @override
  Future<ListMember> inviteMember({required String listId, required String identifier}) async {
    await _latency();
    final handle = identifier.trim();
    return ListMember(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      name: handle.replaceFirst('@', ''),
      handle: handle,
      status: MemberStatus.pending,
    );
  }

  @override
  Future<void> removeMember({required String listId, required String memberId}) => _latency();
}
