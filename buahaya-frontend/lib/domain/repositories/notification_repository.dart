import '../models/invite.dart';
import '../models/shopping.dart';

abstract class NotificationRepository {
  Future<List<ListInvite>> fetchInvites();

    Future<ShoppingList?> respond({required String inviteId, required bool accept});
}
