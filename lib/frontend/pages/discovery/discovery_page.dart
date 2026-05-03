import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/core/utils/formatters.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/resources/app_assets.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_text_field.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isBusy = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);
    final state = controller.state;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('탐색'),
        actions: [
          IconButton(
            tooltip: '문의하기',
            onPressed: _isBusy ? null : () => _showInquirySheet(controller),
            icon: const Icon(Icons.support_agent_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _SearchBar(
            controller: _searchController,
            isBusy: _isBusy,
            onSearch: () => _runSearch(controller),
          ),
          const SizedBox(height: 16),
          _SummaryStrip(state: state),
          const SizedBox(height: 20),
          _SectionTitle(
            title: '습득물',
            actionLabel: '등록',
            onTap: _isBusy ? null : () => _showFoundItemSheet(controller),
          ),
          const SizedBox(height: 10),
          _ListingList(
            items: state.searchResults.isNotEmpty
                ? state.searchResults
                : state.recentFoundListings,
            emptyTitle: '표시할 습득물이 없습니다',
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: '추천 매칭'),
          const SizedBox(height: 10),
          _MatchList(matches: state.suggestedMatches),
          const SizedBox(height: 22),
          const _SectionTitle(title: '내 문의'),
          const SizedBox(height: 10),
          _InquiryList(inquiries: state.inquiries),
        ],
      ),
    );
  }

  Future<void> _runSearch(AppController controller) async {
    setState(() => _isBusy = true);
    try {
      await controller.searchListings(query: _searchController.text);
      await controller.refreshMatches();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _showFoundItemSheet(AppController controller) async {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('습득물 등록', style: AppTextStyles.title),
              const SizedBox(height: 12),
              AppTextField(controller: titleController, label: '습득물 이름'),
              const SizedBox(height: 10),
              AppTextField(controller: locationController, label: '습득 위치'),
              const SizedBox(height: 10),
              AppTextField(controller: descriptionController, label: '특징'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  final location = locationController.text.trim();
                  if (title.isEmpty || location.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이름과 위치를 입력해 주세요.')),
                    );
                    return;
                  }
                  await controller.saveFoundItem(
                    title: title,
                    location: location,
                    description: descriptionController.text.trim(),
                    photoAssetPath: AppAssets.icon,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('등록'),
              ),
            ],
          ),
        );
      },
    );
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
  }

  Future<void> _showInquirySheet(AppController controller) async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('문의하기', style: AppTextStyles.title),
              const SizedBox(height: 12),
              AppTextField(controller: titleController, label: '제목'),
              const SizedBox(height: 10),
              AppTextField(controller: bodyController, label: '내용'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty ||
                      bodyController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('제목과 내용을 입력해 주세요.')),
                    );
                    return;
                  }
                  await controller.submitInquiry(
                    category: InquiryCategory.support,
                    title: titleController.text.trim(),
                    body: bodyController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('보내기'),
              ),
            ],
          ),
        );
      },
    );
    titleController.dispose();
    bodyController.dispose();
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.isBusy,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool isBusy;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration: const InputDecoration(
              hintText: '분실물과 습득물 검색',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filled(
          onPressed: isBusy ? null : onSearch,
          icon: isBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.arrow_forward_rounded),
        ),
      ],
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniStat(
          label: '분실',
          value: '${state.dashboardSummary.openLostCount}',
        ),
        const SizedBox(width: 8),
        _MiniStat(
          label: '습득',
          value: '${state.dashboardSummary.openFoundCount}',
        ),
        const SizedBox(width: 8),
        _MiniStat(label: '매칭', value: '${state.dashboardSummary.matchedCount}'),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.subtitle),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.actionLabel, this.onTap});

  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.title)),
        if (actionLabel != null)
          TextButton(onPressed: onTap, child: Text(actionLabel!)),
      ],
    );
  }
}

class _ListingList extends StatelessWidget {
  const _ListingList({required this.items, required this.emptyTitle});

  final List<ListingSummary> items;
  final String emptyTitle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _PlainEmpty(title: emptyTitle);
    }
    return Column(
      children: [
        for (final item in items) ...[
          _ListingTile(item: item),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ListingTile extends StatelessWidget {
  const _ListingTile({required this.item});

  final ListingSummary item;

  @override
  Widget build(BuildContext context) {
    final typeLabel = item.itemType == ListingType.lost ? '분실' : '습득';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              item.imageUrl?.isNotEmpty == true
                  ? item.imageUrl!
                  : AppAssets.icon,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$typeLabel · ${item.happenedAtLabel}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 2),
                Text(item.title, style: AppTextStyles.subtitle),
                const SizedBox(height: 2),
                Text(item.location, style: AppTextStyles.caption),
                if (item.reward != null)
                  Text(
                    '사례금 ${Formatters.money(item.reward!)}',
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchList extends StatelessWidget {
  const _MatchList({required this.matches});

  final List<MatchRecord> matches;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const _PlainEmpty(title: '추천 매칭이 없습니다');
    }
    return Column(
      children: [
        for (final match in matches.take(5)) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${match.lostItem.title} ↔ ${match.foundItem.title}',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 4),
                Text(match.reasonSummary, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _InquiryList extends StatelessWidget {
  const _InquiryList({required this.inquiries});

  final List<InquiryRecord> inquiries;

  @override
  Widget build(BuildContext context) {
    if (inquiries.isEmpty) {
      return const _PlainEmpty(title: '등록된 문의가 없습니다');
    }
    return Column(
      children: [
        for (final inquiry in inquiries.take(5)) ...[
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            title: Text(inquiry.title),
            subtitle: Text(
              '${inquiry.createdAtLabel} · ${inquiry.status.name}',
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _PlainEmpty extends StatelessWidget {
  const _PlainEmpty({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(title, style: AppTextStyles.caption),
    );
  }
}
