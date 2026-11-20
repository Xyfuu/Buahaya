import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/shopping_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/pill_tabs.dart';
import 'active_list_view.dart';
import 'empty_list_view.dart';
import 'history_view.dart';

/// Tab "Lists": Active list | History (Done).
class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key, this.initialTab});

  /// "history" untuk membuka tab riwayat (mis. dari Profile > View all).
  final String? initialTab;

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  late int _tab = widget.initialTab == 'history' ? 1 : 0;

  @override
  void didUpdateWidget(covariant ListsScreen old) {
    super.didUpdateWidget(old);
    if (widget.initialTab != old.initialTab) {
      setState(() => _tab = widget.initialTab == 'history' ? 1 : 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopping = context.watch<ShoppingController>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: PillTabs(
            tabs: const [PillTab(Icons.checklist_rounded, 'Active list'), PillTab(Icons.history_rounded, 'History (Done)')],
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: shopping.load,
            child: _tab == 0
                ? (shopping.active == null
                    ? const EmptyListView()
                    : ActiveListView(list: shopping.active!, onFinished: () => setState(() => _tab = 1)))
                : const HistoryView(),
          ),
        ),
      ],
    );
  }
}
