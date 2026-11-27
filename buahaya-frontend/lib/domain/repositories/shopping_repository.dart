import '../models/fruit.dart';
import '../models/shopping.dart';

abstract class ShoppingRepository {
  Future<List<Fruit>> fetchFruitCatalog();

    Future<ShoppingList?> fetchActiveList();

    Future<ShoppingList> saveList(ShoppingList list);

  Future<void> deleteList(String listId);

    Future<ShoppingTrip> finishList(ShoppingList list);

  Future<List<ShoppingTrip>> fetchHistory();

    Future<ListMember> inviteMember({required String listId, required String identifier});

  Future<void> removeMember({required String listId, required String memberId});
}
