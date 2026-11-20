import '../models/fruit.dart';
import '../models/shopping.dart';

abstract class ShoppingRepository {
  Future<List<Fruit>> fetchFruitCatalog();

  /// Maksimal satu list aktif per pengguna. Null bila tidak ada.
  Future<ShoppingList?> fetchActiveList();

  /// Upsert list aktif (rencana belanja, keranjang, anggota).
  Future<ShoppingList> saveList(ShoppingList list);

  Future<void> deleteList(String listId);

  /// Selesaikan list -> masuk riwayat.
  Future<ShoppingTrip> finishList(ShoppingList list);

  Future<List<ShoppingTrip>> fetchHistory();

  /// Undang anggota (username/email). Status awal: pending.
  Future<ListMember> inviteMember({required String listId, required String identifier});

  Future<void> removeMember({required String listId, required String memberId});
}
