/// Undangan bergabung ke shopping list milik pengguna lain.
class ListInvite {
  const ListInvite({
    required this.id,
    required this.inviterName,
    required this.listName,
    required this.receivedAt,
  });

  final String id;
  final String inviterName;
  final String listName;
  final DateTime receivedAt;
}
