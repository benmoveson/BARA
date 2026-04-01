import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/auth/activity_model.dart';
import '../../providers/activity_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  ActivityType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadActivitiesStream(
        context.read<ActivityProvider>().activitiesStream,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.history,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Consumer<ActivityProvider>(
              builder: (context, provider, _) {
                final activities = provider.filterByType(_selectedFilter);
                
                if (activities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          AppStrings.noActivity,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _buildActivityTile(activity);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildFilterChip(null, AppStrings.all),
          const SizedBox(width: 8),
          _buildFilterChip(ActivityType.sale, AppStrings.sales),
          const SizedBox(width: 8),
          _buildFilterChip(ActivityType.debt, AppStrings.debts),
          const SizedBox(width: 8),
          _buildFilterChip(ActivityType.stockIn, AppStrings.stockIn),
          const SizedBox(width: 8),
          _buildFilterChip(ActivityType.stockOut, AppStrings.stockOut),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ActivityType? type, String label) {
    final isSelected = _selectedFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? type : null;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildActivityTile(ActivityModel activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: _getActivityColor(activity.type),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.typeDisplayName,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (activity.amount != null)
                Text(
                  Formatters.formatCurrency(activity.amount!),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getActivityColor(activity.type),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                Formatters.formatDay(activity.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.sale:
        return Icons.shopping_cart;
      case ActivityType.debt:
        return Icons.account_balance_wallet;
      case ActivityType.stockIn:
        return Icons.add_box;
      case ActivityType.stockOut:
        return Icons.remove_circle;
      case ActivityType.debtPayment:
        return Icons.payments;
      case ActivityType.productAdded:
        return Icons.add_shopping_cart;
      case ActivityType.productUpdated:
        return Icons.edit;
      case ActivityType.productDeleted:
        return Icons.delete;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.sale:
        return AppColors.success;
      case ActivityType.debt:
        return AppColors.error;
      case ActivityType.stockIn:
        return AppColors.primary;
      case ActivityType.stockOut:
        return AppColors.secondary;
      case ActivityType.debtPayment:
        return AppColors.success;
      case ActivityType.productAdded:
        return AppColors.primary;
      case ActivityType.productUpdated:
        return AppColors.secondary;
      case ActivityType.productDeleted:
        return AppColors.error;
    }
  }
}