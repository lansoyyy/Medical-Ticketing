import 'package:flutter/material.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  List<UserModel> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
    // Load doctors
    _firestoreService.getActiveDoctors().listen((doctors) {
      if (mounted) {
        setState(() => _doctors = doctors);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Appointments',
            style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showBookAppointmentDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Book Appointment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _currentUser == null
              ? const Center(child: Text('Please log in to view appointments'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentListStream([
                      AppointmentStatus.scheduled,
                      AppointmentStatus.confirmed
                    ]),
                    _buildAppointmentListStream([AppointmentStatus.completed]),
                    _buildAppointmentListStream([
                      AppointmentStatus.cancelled,
                      AppointmentStatus.noShow
                    ]),
                  ],
                ),
    );
  }

  Widget _buildAppointmentListStream(List<AppointmentStatus> statuses) {
    return StreamBuilder<List<AppointmentModel>>(
      stream: _firestoreService.getPatientAppointments(_currentUser!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        final allAppointments = snapshot.data ?? [];
        final appointments =
            allAppointments.where((a) => statuses.contains(a.status)).toList();

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 64, color: AppColors.grey400),
                const SizedBox(height: 16),
                Text('No appointments found',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            return _buildAppointmentCard(appointments[index]);
          },
        );
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final statusColor = _getStatusColorFromEnum(appointment.status);
    final isUpcoming = appointment.status == AppointmentStatus.scheduled ||
        appointment.status == AppointmentStatus.confirmed;

    final initials = appointment.doctorName
        .split(' ')
        .map((n) => n.isNotEmpty ? n[0] : '')
        .take(2)
        .join();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(Icons.calendar_month, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatDate(appointment.appointmentDate),
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                      Text(appointment.timeSlot,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    appointment.statusDisplay,
                    style: AppTextStyles.caption.copyWith(
                        color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        initials.toUpperCase(),
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appointment.doctorName,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                          Text(appointment.department ?? 'General',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (appointment.reason != null &&
                    appointment.reason!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notes_outlined,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            appointment.reason!,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isUpcoming) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelAppointment(appointment.id),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel Appointment'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content:
            const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.cancelAppointment(appointmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Appointment cancelled'),
              backgroundColor: AppColors.success),
        );
      }
    }
  }

  Color _getStatusColorFromEnum(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return AppColors.success;
      case AppointmentStatus.scheduled:
        return AppColors.cardOrange;
      case AppointmentStatus.completed:
        return AppColors.cardBlue;
      case AppointmentStatus.cancelled:
      case AppointmentStatus.noShow:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showBookAppointmentDialog() {
    UserModel? selectedDoctor;
    DateTime? selectedDate;
    String? selectedTime;
    final reasonController = TextEditingController();
    bool isBooking = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Book Appointment', style: AppTextStyles.h5),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Doctor',
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<UserModel>(
                    value: selectedDoctor,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    hint: const Text('Select Doctor'),
                    items: _doctors
                        .map((doctor) => DropdownMenuItem(
                              value: doctor,
                              child: Text(
                                  'Dr. ${doctor.fullName}${doctor.specialization != null ? ' - ${doctor.specialization}' : ''}'),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedDoctor = value),
                  ),
                  const SizedBox(height: 16),
                  Text('Date',
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (date != null)
                        setDialogState(() => selectedDate = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 20, color: AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate != null
                                ? '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}'
                                : 'Select Date',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: selectedDate != null
                                  ? AppColors.textPrimary
                                  : AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Time',
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '9:00 AM',
                      '10:00 AM',
                      '11:00 AM',
                      '2:00 PM',
                      '3:00 PM',
                      '4:00 PM'
                    ]
                        .map((time) => ChoiceChip(
                              label: Text(time),
                              selected: selectedTime == time,
                              selectedColor: AppColors.primary.withOpacity(0.2),
                              onSelected: (selected) => setDialogState(
                                  () => selectedTime = selected ? time : null),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Reason for Visit',
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Describe your symptoms or reason...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  if (_doctors.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'No doctors available. Please try again later.',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.error),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: (selectedDoctor == null ||
                      selectedDate == null ||
                      selectedTime == null ||
                      isBooking)
                  ? null
                  : () async {
                      setDialogState(() => isBooking = true);
                      try {
                        await _firestoreService.createAppointment(
                          patientId: _currentUser!.id,
                          patientName: _currentUser!.fullName,
                          doctorId: selectedDoctor!.id,
                          doctorName: 'Dr. ${selectedDoctor!.fullName}',
                          department: selectedDoctor!.department,
                          appointmentDate: selectedDate!,
                          timeSlot: selectedTime!,
                          reason: reasonController.text.trim(),
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Appointment booked successfully!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isBooking = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: AppColors.error),
                          );
                        }
                      }
                    },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: isBooking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Book'),
            ),
          ],
        ),
      ),
    );
  }
}
