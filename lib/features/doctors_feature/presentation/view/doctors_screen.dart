import 'package:campus_ai/features/doctors_feature/data/cubit/doctor_cubit.dart';
import 'package:campus_ai/features/doctors_feature/data/cubit/doctor_state.dart';
import 'package:campus_ai/features/doctors_feature/data/models/doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campus_ai/core/theme/app_colors.dart';

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorsCubit()..load(),
      child: const _DoctorsView(),
    );
  }
}

// ── Root view ─────────────────────────────────────────────────────────────────

class _DoctorsView extends StatefulWidget {
  const _DoctorsView();

  @override
  State<_DoctorsView> createState() => _DoctorsViewState();
}

class _DoctorsViewState extends State<_DoctorsView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: BlocBuilder<DoctorsCubit, DoctorsState>(
        builder: (context, state) => switch (state) {
          DoctorsInitial() || DoctorsLoading() => const _LoadingView(),
          DoctorsError(:final message)        => _ErrorView(message: message),
          DoctorsLoaded()                     => _LoadedView(
              state: state,
              searchController: _searchController,
            ),
        },
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.redLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.error_outline_rounded,
                      color: AppColors.red, size: 32),
                ),
                const SizedBox(height: 16),
                Text(message,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () => context.read<DoctorsCubit>().load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Loaded ────────────────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  final DoctorsLoaded state;
  final TextEditingController searchController;

  const _LoadedView({required this.state, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context, searchController: searchController),
        _DepartmentBar(
          departments: state.departments,
          selected: state.selectedDept,
        ),
        Expanded(
          child: state.filtered.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: state.filtered.length,
                  itemBuilder: (_, i) =>
                      _DoctorCard(doctor: state.filtered[i]),
                ),
        ),
      ],
    );
  }
}

// ── Shared header builder ─────────────────────────────────────────────────────

Widget _buildHeader(
  BuildContext context, {
  TextEditingController? searchController,
}) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primaryDeep, AppColors.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 12,
      left: 20,
      right: 20,
      bottom: 24,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Doctors',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (searchController != null) ...[
          const SizedBox(height: 20),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (v) => context.read<DoctorsCubit>().search(v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search doctors, specialties...',
                hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.white.withOpacity(0.7)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

// ── Department bar ────────────────────────────────────────────────────────────

class _DepartmentBar extends StatelessWidget {
  final List<String> departments;
  final String selected;

  const _DepartmentBar({required this.departments, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: departments.map((dept) {
            final isSelected = selected == dept;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () =>
                    context.read<DoctorsCubit>().selectDepartment(dept),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    dept,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Doctor card ───────────────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  const _DoctorCard({required this.doctor});

  Color get _avatarColor {
    const colors = [
      AppColors.primary,
      AppColors.green,
      AppColors.purple,
      AppColors.amber,
    ];
    return colors[doctor.id.hashCode % colors.length];
  }

  String get _initials {
    final parts = doctor.name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return parts[1][0].toUpperCase();
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) =>
                _DoctorSheet(doctor: doctor, avatarColor: _avatarColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _avatarColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: TextStyle(
                        color: _avatarColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        doctor.specialty,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Chip(
                            icon: Icons.meeting_room_outlined,
                            label: doctor.room,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          _Chip(
                            icon: Icons.schedule_rounded,
                            label: doctor.officeHours,
                            color: AppColors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small chip ────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class _DoctorSheet extends StatelessWidget {
  final Doctor doctor;
  final Color avatarColor;

  const _DoctorSheet({required this.doctor, required this.avatarColor});

  String get _initials {
    final parts = doctor.name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return parts[1][0].toUpperCase();
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: avatarColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                _initials,
                style: TextStyle(
                    color: avatarColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            doctor.name,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            doctor.specialty,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _SheetRow(
            icon: Icons.account_balance_outlined,
            label: 'Department',
            value: doctor.department,
            color: AppColors.purple,
          ),
          _SheetRow(
            icon: Icons.meeting_room_outlined,
            label: 'Room',
            value: doctor.room,
            color: AppColors.primary,
          ),
          _SheetRow(
            icon: Icons.schedule_rounded,
            label: 'Office hours',
            value: doctor.officeHours,
            color: AppColors.green,
          ),
          _SheetRow(
            icon: Icons.calendar_today_outlined,
            label: 'Available days',
            value: doctor.availableDays.join('  ·  '),
            color: AppColors.amber,
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SheetRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person_search_rounded,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No doctors found',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Try a different name or department',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}