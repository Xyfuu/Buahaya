import '../models/invite.dart';
import '../models/shopping.dart';

abstract class NotificationRepository {
  Future<List<ListInvite>> fetchInvites();

  /// Terima/tolak undangan. Bila diterima, kembalikan list yang diikuti.
  Future<ShoppingList?> respond({required String inviteId, required bool accept});
}
