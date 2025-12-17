import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class QueueManagementScreen extends StatefulWidget {
  const QueueManagementScreen({super.key});

  @override
  State<QueueManagementScreen> createState() => _QueueManagementScreenState();
}

class _QueueManagementScreenState extends State<QueueManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedFilter = 'In Process';
  final List<String> _filters = ['In Process', 'Completed', 'Cancelled'];
  int _inProgressCount = 0;
  int _completedCount = 0;
  int _cancelledCount = 0;

  bool _isInProcessStatus(TicketStatus status) {
    return status == TicketStatus.waiting ||
        status == TicketStatus.called ||
        status == TicketStatus.inProgress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: AppColors.cardTeal,
        foregroundColor: AppColors.white,
        title: const Text('Queue Management'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {})),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewTicketDialog,
        backgroundColor: AppColors.cardTeal,
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
      body: StreamBuilder<List<TicketModel>>(
        stream: _firestoreService.getTodayTickets(),
        builder: (context, snapshot) {
          final allTickets = snapshot.data ?? [];

          // Update counts
          _inProgressCount =
              allTickets.where((t) => _isInProcessStatus(t.status)).length;
          _completedCount = allTickets
              .where((t) => t.status == TicketStatus.completed)
              .length;
          _cancelledCount = allTickets
              .where((t) => t.status == TicketStatus.cancelled)
              .length;

          // Filter tickets
          final tickets =
              allTickets.where((t) => _matchesFilter(t.status)).toList();

          return Column(
            children: [
              // Stats Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.white,
                child: Row(
                  children: [
                    _buildQuickStat(
                        'In Process', '$_inProgressCount', AppColors.cardBlue),
                    _buildQuickStat(
                        'Completed', '$_completedCount', AppColors.success),
                    _buildQuickStat(
                        'Cancelled', '$_cancelledCount', AppColors.error),
                  ],
                ),
              ),
              // Filter Chips
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.white,
                child: Row(
                  children: _filters
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(f),
                              selected: _selectedFilter == f,
                              selectedColor:
                                  AppColors.cardTeal.withOpacity(0.2),
                              onSelected: (s) =>
                                  setState(() => _selectedFilter = f),
                            ),
                          ))
                      .toList(),
                ),
              ),
              // Queue List
              Expanded(
                child: tickets.isEmpty
                    ? Center(
                        child: Text('No tickets',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tickets.length,
                        itemBuilder: (context, index) =>
                            _buildQueueCard(tickets[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _matchesFilter(TicketStatus status) {
    switch (_selectedFilter) {
      case 'In Process':
        return _isInProcessStatus(status);
      case 'Completed':
        return status == TicketStatus.completed;
      case 'Cancelled':
        return status == TicketStatus.cancelled;
      default:
        return true;
    }
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 24),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text('$label: ',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildQueueCard(TicketModel ticket) {
    final statusColor = _getTicketStatusColor(ticket.status);
    final isUrgent = ticket.priority == TicketPriority.emergency;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUrgent ? Border.all(color: AppColors.error, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Queue Number
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${ticket.queueNumber}',
                      style: AppTextStyles.h4.copyWith(
                          color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(ticket.patientName,
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.w600)),
                          if (isUrgent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text('URGENT',
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                          '${ticket.chiefComplaint ?? "General"} • ${_formatTime(ticket.createdAt)}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(ticket.statusDisplay,
                      style: AppTextStyles.caption.copyWith(
                          color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                if (_isInProcessStatus(ticket.status)) ...[
                  _buildActionButton('Mark as complete', Icons.check_circle,
                      AppColors.success, () => _completeTicket(ticket)),
                  const SizedBox(width: 8),
                  _buildActionButton('Prioritize', Icons.priority_high,
                      AppColors.cardOrange, () => _prioritizeTicket(ticket)),
                ],
                const Spacer(),
                _buildActionButton('View', Icons.visibility,
                    AppColors.textSecondary, () => _viewTicket(ticket)),
                const SizedBox(width: 8),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.textSecondary),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'cancel', child: Text('Cancel Ticket')),
                  ],
                  onSelected: (value) => _handleMenuAction(value, ticket),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
    );
  }

  Color _getTicketStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.waiting:
        return AppColors.cardOrange;
      case TicketStatus.called:
      case TicketStatus.inProgress:
        return AppColors.cardBlue;
      case TicketStatus.completed:
        return AppColors.success;
      case TicketStatus.cancelled:
      case TicketStatus.noShow:
        return AppColors.error;
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
  }

  void _prioritizeTicket(TicketModel ticket) async {
    await _firestoreService
        .updateTicket(ticket.id, {'priority': TicketPriority.emergency.name});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ticket.patientName} marked as urgent')));
    }
  }

  void _completeTicket(TicketModel ticket) async {
    await _firestoreService.completeTicket(ticket.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${ticket.patientName} consultation completed')));
    }
  }

  void _viewTicket(TicketModel ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(children: [
              CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(ticket.patientName[0],
                      style:
                          AppTextStyles.h4.copyWith(color: AppColors.primary))),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ticket.patientName, style: AppTextStyles.h5),
                Text(
                    'Queue #${ticket.queueNumber} • ${ticket.chiefComplaint ?? "General"}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ]),
            ]),
            const SizedBox(height: 24),
            _buildInfoRow('Status', ticket.statusDisplay),
            _buildInfoRow('Time In', _formatTime(ticket.createdAt)),
            _buildInfoRow('Priority', ticket.priorityDisplay),
            if (ticket.department != null)
              _buildInfoRow('Department', ticket.department!),
            const SizedBox(height: 24),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardTeal),
                  child: const Text('Close'),
                )),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, TicketModel ticket) async {
    switch (action) {
      case 'cancel':
        await _firestoreService.cancelTicket(ticket.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Ticket for ${ticket.patientName} cancelled')));
        break;
    }
  }

  void _showNewTicketDialog() {
    UserModel? selectedPatient;
    DateTime admissionDate = DateTime.now();
    String? selectedTicketColor;
    String frequencyValue = '';
    List<String> scheduleTimes = [];
    int? generatedQueueNumber;

    final caseNoController = TextEditingController();
    final brandNameController = TextEditingController();
    final admissionDateController =
        TextEditingController(text: _formatDate(admissionDate));
    final frequencyController = TextEditingController();

    final ticketColorOptions = <String, Map<String, dynamic>>{
      'Orange': {
        'frequency': 'Every 8 hrs',
        'times': ['6 AM', '2 PM', '10 PM'],
      },
      'Blue': {
        'frequency': 'Every 4 hrs',
        'times': ['2 AM', '6 AM', '10 AM', '2 PM', '6 PM', '10 PM'],
      },
      'Pink': {
        'frequency': '3X a Day/TID',
        'times': ['6 AM', '1 PM', '6 PM'],
      },
      'Yellow': {
        'frequency': 'Every 12 hrs/BID/Hrs of sleep',
        'times': ['6 AM', '6 PM', 'HS-9 PM'],
      },
      'Green': {
        'frequency': '4X a Day/QID',
        'times': ['6 AM', '10 AM', '2 PM', '6 PM'],
      },
      'White': {
        'frequency': 'Once a Day',
        'times': ['6 AM'],
      },
      'Red': {
        'frequency': 'Every 6 hrs/q6 and for STAT dose',
        'times': ['12 AM', '6 AM', '12 NN', '6 PM'],
      },
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Generate New Ticket'),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: StreamBuilder<List<UserModel>>(
                        stream: _firestoreService.getActivePatients(),
                        builder: (context, snapshot) {
                          final patients = snapshot.data ?? [];
                          return DropdownButtonFormField<UserModel>(
                            value: selectedPatient,
                            dropdownColor: AppColors.inputBackground,
                            style: const TextStyle(color: AppColors.inputText),
                            decoration: const InputDecoration(
                              labelText: 'Patient Name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            items: patients
                                .map((p) => DropdownMenuItem<UserModel>(
                                      value: p,
                                      child: Text(p.fullName,
                                          style: const TextStyle(
                                              color: AppColors.inputText)),
                                    ))
                                .toList(),
                            onChanged: generatedQueueNumber != null
                                ? null
                                : (value) {
                                    setDialogState(
                                        () => selectedPatient = value);
                                  },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: admissionDateController,
                        readOnly: true,
                        style: const TextStyle(color: AppColors.inputText),
                        decoration: const InputDecoration(
                          labelText: 'Admission Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: generatedQueueNumber != null
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: admissionDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setDialogState(() {
                                    admissionDate = picked;
                                    admissionDateController.text =
                                        _formatDate(picked);
                                  });
                                }
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: caseNoController,
                  enabled: generatedQueueNumber == null,
                  style: const TextStyle(color: AppColors.inputText),
                  decoration: const InputDecoration(
                    labelText: 'Case No.',
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: brandNameController,
                  enabled: generatedQueueNumber == null,
                  style: const TextStyle(color: AppColors.inputText),
                  decoration: const InputDecoration(
                    labelText: 'Brand Name of Dosage',
                    prefixIcon: Icon(Icons.medication_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: frequencyController,
                  readOnly: true,
                  style: const TextStyle(color: AppColors.inputText),
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    prefixIcon: Icon(Icons.schedule),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTicketColor,
                  dropdownColor: AppColors.inputBackground,
                  style: const TextStyle(color: AppColors.inputText),
                  decoration: const InputDecoration(
                    labelText: 'Ticket Color',
                    prefixIcon: Icon(Icons.color_lens_outlined),
                  ),
                  items: ticketColorOptions.keys
                      .map((c) => DropdownMenuItem<String>(
                            value: c,
                            child: Text(c,
                                style: const TextStyle(
                                    color: AppColors.inputText)),
                          ))
                      .toList(),
                  onChanged: generatedQueueNumber != null
                      ? null
                      : (value) {
                          if (value == null) return;
                          final def = ticketColorOptions[value]!;
                          setDialogState(() {
                            selectedTicketColor = value;
                            frequencyValue = def['frequency'] as String;
                            scheduleTimes =
                                List<String>.from(def['times'] as List);
                            frequencyController.text =
                                '$frequencyValue - ${scheduleTimes.join(' - ')}';
                          });
                        },
                ),
                if (generatedQueueNumber != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ticket #$generatedQueueNumber',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (selectedPatient == null) return;
                            if (selectedTicketColor == null) return;
                            if (generatedQueueNumber == null) return;

                            try {
                              final bytes = await _buildMedicationTicketPdf(
                                queueNumber: generatedQueueNumber!,
                                patientName: selectedPatient!.fullName,
                                admissionDate: admissionDate,
                                caseNo: caseNoController.text.trim(),
                                brandName: brandNameController.text.trim(),
                                ticketColor: selectedTicketColor!,
                                frequency: frequencyValue,
                                scheduleTimes: scheduleTimes,
                              );

                              await Printing.layoutPdf(
                                onLayout: (_) async => bytes,
                              );

                              if (!mounted) return;
                              Navigator.pop(context);
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(content: Text('Print failed: $e')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cardTeal),
                          child: const Text('Print'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: generatedQueueNumber != null
                  ? null
                  : () {
                      if (selectedPatient == null) return;
                      if (selectedTicketColor == null) return;
                      if (brandNameController.text.trim().isEmpty) return;
                      if (caseNoController.text.trim().isEmpty) return;

                      _createNewMedicationTicket(
                        patient: selectedPatient!,
                        admissionDate: admissionDate,
                        caseNo: caseNoController.text.trim(),
                        brandName: brandNameController.text.trim(),
                        ticketColor: selectedTicketColor!,
                        frequency: frequencyValue,
                        scheduleTimes: scheduleTimes,
                      ).then((queueNumber) {
                        if (queueNumber != null) {
                          setDialogState(
                              () => generatedQueueNumber = queueNumber);
                        }
                      });
                    },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.cardTeal),
              child: const Text('Generate Ticket'),
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _createNewMedicationTicket({
    required UserModel patient,
    required DateTime admissionDate,
    required String caseNo,
    required String brandName,
    required String ticketColor,
    required String frequency,
    required List<String> scheduleTimes,
  }) async {
    try {
      final ticket = await _firestoreService.createTicket(
        patientId: patient.id,
        patientName: patient.fullName,
        department: ticketColor,
        chiefComplaint: brandName,
        priority: TicketPriority.normal,
      );

      await _firestoreService.updateTicket(ticket.id, {
        'admissionDate': Timestamp.fromDate(admissionDate),
        'caseNo': caseNo,
        'brandName': brandName,
        'ticketColor': ticketColor,
        'frequency': frequency,
        'scheduleTimes': scheduleTimes,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Ticket #${ticket.queueNumber} generated successfully')));
      }
      return ticket.queueNumber;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
      return null;
    }
  }

  PdfColor _pdfColorForTicket(String ticketColor) {
    switch (ticketColor) {
      case 'Red':
        return PdfColors.red;
      case 'White':
        return PdfColors.white;
      case 'Green':
        return PdfColors.green;
      case 'Yellow':
        return PdfColors.yellow;
      case 'Pink':
        return PdfColors.pink;
      case 'Blue':
        return PdfColors.blue;
      case 'Orange':
        return PdfColors.orange;
      default:
        return PdfColors.grey;
    }
  }

  Future<Uint8List> _buildMedicationTicketPdf({
    required int queueNumber,
    required String patientName,
    required DateTime admissionDate,
    required String caseNo,
    required String brandName,
    required String ticketColor,
    required String frequency,
    required List<String> scheduleTimes,
  }) async {
    final doc = pw.Document();

    final accent = _pdfColorForTicket(ticketColor);
    final schedule = scheduleTimes.join(' - ');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        margin: const pw.EdgeInsets.all(16),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: accent,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MEDICATION TICKET',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: ticketColor == 'White'
                            ? PdfColors.black
                            : PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Ticket #$queueNumber',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: ticketColor == 'White'
                                ? PdfColors.black
                                : PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          ticketColor,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: ticketColor == 'White'
                                ? PdfColors.black
                                : PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Patient Name',
                        style: pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey700)),
                    pw.Text(patientName,
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Admission Date',
                                  style: pw.TextStyle(
                                      fontSize: 10, color: PdfColors.grey700)),
                              pw.Text(_formatDate(admissionDate),
                                  style: const pw.TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Case No.',
                                  style: pw.TextStyle(
                                      fontSize: 10, color: PdfColors.grey700)),
                              pw.Text(caseNo,
                                  style: const pw.TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('Brand Name of Dosage',
                        style: pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey700)),
                    pw.Text(brandName, style: const pw.TextStyle(fontSize: 11)),
                    pw.SizedBox(height: 10),
                    pw.Text('Frequency',
                        style: pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey700)),
                    pw.Text(frequency, style: const pw.TextStyle(fontSize: 11)),
                    pw.SizedBox(height: 6),
                    pw.Text('Schedule',
                        style: pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey700)),
                    pw.Text(schedule, style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Text(
                'Generated: ${_formatTime(DateTime.now())}',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
