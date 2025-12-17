import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ticket_model.dart';
import '../models/appointment_model.dart';
import '../models/consultation_model.dart';
import '../models/notification_model.dart';
import '../models/audit_log_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<({String userId, String userName, String userRole})?>
      _getCurrentAuditUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _usersCollection.doc(firebaseUser.uid).get();
      if (!doc.exists) {
        return (
          userId: firebaseUser.uid,
          userName: firebaseUser.email ?? 'User',
          userRole: 'unknown'
        );
      }

      final user = UserModel.fromFirestore(doc);
      return (userId: user.id, userName: user.fullName, userRole: user.role);
    } catch (_) {
      return (
        userId: firebaseUser.uid,
        userName: firebaseUser.email ?? 'User',
        userRole: 'unknown'
      );
    }
  }

  Future<void> _safeCreateAuditLog({
    required AuditAction action,
    required String description,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? details,
  }) async {
    try {
      final auditUser = await _getCurrentAuditUser();
      if (auditUser == null) return;

      await createAuditLog(
        userId: auditUser.userId,
        userName: auditUser.userName,
        userRole: auditUser.userRole,
        action: action,
        description: description,
        targetId: targetId,
        targetType: targetType,
        details: details,
      );
    } catch (_) {
      // ignore audit log failures
    }
  }

  // ==================== TICKETS ====================

  CollectionReference get _ticketsCollection =>
      _firestore.collection('tickets');

  // Get today's tickets
  Stream<List<TicketModel>> getTodayTickets() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _ticketsCollection
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketModel.fromFirestore(doc))
            .toList());
  }

  // Get tickets by status
  Stream<List<TicketModel>> getTicketsByStatus(TicketStatus status) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return _ticketsCollection
        .where('status', isEqualTo: status.name)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketModel.fromFirestore(doc))
            .toList());
  }

  // Get patient's tickets
  Stream<List<TicketModel>> getPatientTickets(String patientId) {
    return _ticketsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketModel.fromFirestore(doc))
            .toList());
  }

  Stream<Map<String, dynamic>?> getLatestTicketDataForPatient(
      String patientId) {
    return _ticketsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.data() as Map<String, dynamic>;
    });
  }

  // Get patient's active ticket for today
  Future<TicketModel?> getPatientActiveTicket(String patientId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final snapshot = await _ticketsCollection
        .where('patientId', isEqualTo: patientId)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('status', whereIn: ['waiting', 'called', 'inProgress'])
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return TicketModel.fromFirestore(snapshot.docs.first);
  }

  // Create ticket
  Future<TicketModel> createTicket({
    required String patientId,
    required String patientName,
    String? department,
    String? chiefComplaint,
    TicketPriority priority = TicketPriority.normal,
  }) async {
    // Get next queue number for today
    final queueNumber = await _getNextQueueNumber();

    final docRef = _ticketsCollection.doc();
    final ticket = TicketModel(
      id: docRef.id,
      patientId: patientId,
      patientName: patientName,
      queueNumber: queueNumber,
      status: TicketStatus.inProgress,
      priority: priority,
      department: department,
      chiefComplaint: chiefComplaint,
      createdAt: DateTime.now(),
    );

    await docRef.set(ticket.toFirestore());

    await _safeCreateAuditLog(
      action: AuditAction.ticketCreated,
      description: 'Ticket #${ticket.queueNumber} created for $patientName',
      targetId: ticket.id,
      targetType: 'ticket',
      details: {
        'patientId': patientId,
        'patientName': patientName,
        'queueNumber': ticket.queueNumber,
        'department': department,
      },
    );

    return ticket;
  }

  Future<int> _getNextQueueNumber() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final snapshot = await _ticketsCollection
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return 1;
    final lastTicket = TicketModel.fromFirestore(snapshot.docs.first);
    return lastTicket.queueNumber + 1;
  }

  // Update ticket
  Future<void> updateTicket(String ticketId, Map<String, dynamic> data) async {
    await _ticketsCollection.doc(ticketId).update(data);
  }

  // Call patient (update status to called)
  Future<void> callPatient(String ticketId) async {
    await _ticketsCollection.doc(ticketId).update({
      'status': TicketStatus.called.name,
      'calledAt': Timestamp.now(),
    });
  }

  // Start consultation (update status to inProgress)
  Future<void> startConsultation(
      String ticketId, String doctorId, String doctorName) async {
    await _ticketsCollection.doc(ticketId).update({
      'status': TicketStatus.inProgress.name,
      'assignedDoctorId': doctorId,
      'assignedDoctorName': doctorName,
    });
  }

  // Complete ticket
  Future<void> completeTicket(String ticketId) async {
    await _ticketsCollection.doc(ticketId).update({
      'status': TicketStatus.completed.name,
      'completedAt': Timestamp.now(),
    });

    await _safeCreateAuditLog(
      action: AuditAction.ticketCompleted,
      description: 'Ticket completed',
      targetId: ticketId,
      targetType: 'ticket',
    );
  }

  // Cancel ticket
  Future<void> cancelTicket(String ticketId) async {
    await _ticketsCollection.doc(ticketId).update({
      'status': TicketStatus.cancelled.name,
    });

    await _safeCreateAuditLog(
      action: AuditAction.ticketCancelled,
      description: 'Ticket cancelled',
      targetId: ticketId,
      targetType: 'ticket',
    );
  }

  // Get tickets assigned to a doctor
  Stream<List<TicketModel>> getDoctorTickets(String doctorId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return _ticketsCollection
        .where('assignedDoctorId', isEqualTo: doctorId)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketModel.fromFirestore(doc))
            .toList());
  }

  // Get queue stats for today
  Future<Map<String, int>> getQueueStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final snapshot = await _ticketsCollection
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    int waiting = 0, inProgress = 0, completed = 0;
    for (var doc in snapshot.docs) {
      final ticket = TicketModel.fromFirestore(doc);
      switch (ticket.status) {
        case TicketStatus.waiting:
        case TicketStatus.called:
          waiting++;
          break;
        case TicketStatus.inProgress:
          inProgress++;
          break;
        case TicketStatus.completed:
          completed++;
          break;
        default:
          break;
      }
    }

    return {
      'total': snapshot.docs.length,
      'waiting': waiting,
      'inProgress': inProgress,
      'completed': completed,
    };
  }

  // ==================== APPOINTMENTS ====================

  CollectionReference get _appointmentsCollection =>
      _firestore.collection('appointments');

  // Get patient's appointments
  Stream<List<AppointmentModel>> getPatientAppointments(String patientId) {
    return _appointmentsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  // Get doctor's appointments
  Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId) {
    return _appointmentsCollection
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('appointmentDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  // Get appointments for a specific date
  Stream<List<AppointmentModel>> getAppointmentsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _appointmentsCollection
        .where('appointmentDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('appointmentDate', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('appointmentDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  // Create appointment
  Future<AppointmentModel> createAppointment({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    String? department,
    required DateTime appointmentDate,
    required String timeSlot,
    String? reason,
  }) async {
    final docRef = _appointmentsCollection.doc();
    final appointment = AppointmentModel(
      id: docRef.id,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      department: department,
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      status: AppointmentStatus.scheduled,
      reason: reason,
      createdAt: DateTime.now(),
    );

    await docRef.set(appointment.toFirestore());

    await _safeCreateAuditLog(
      action: AuditAction.appointmentCreated,
      description: 'Appointment booked for $patientName',
      targetId: appointment.id,
      targetType: 'appointment',
      details: {
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'department': department,
        'appointmentDate': Timestamp.fromDate(appointmentDate),
        'timeSlot': timeSlot,
      },
    );

    return appointment;
  }

  // Update appointment
  Future<void> updateAppointment(
      String appointmentId, Map<String, dynamic> data) async {
    await _appointmentsCollection.doc(appointmentId).update(data);
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    await _appointmentsCollection.doc(appointmentId).update({
      'status': AppointmentStatus.cancelled.name,
    });

    await _safeCreateAuditLog(
      action: AuditAction.appointmentCancelled,
      description: 'Appointment cancelled',
      targetId: appointmentId,
      targetType: 'appointment',
    );
  }

  // ==================== CONSULTATIONS ====================

  CollectionReference get _consultationsCollection =>
      _firestore.collection('consultations');

  // Get patient's consultations (medical records)
  Stream<List<ConsultationModel>> getPatientConsultations(String patientId) {
    return _consultationsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('consultationDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConsultationModel.fromFirestore(doc))
            .toList());
  }

  // Get doctor's consultations
  Stream<List<ConsultationModel>> getDoctorConsultations(String doctorId) {
    return _consultationsCollection
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('consultationDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConsultationModel.fromFirestore(doc))
            .toList());
  }

  // Create consultation
  Future<ConsultationModel> createConsultation({
    required String ticketId,
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    String? department,
    String? chiefComplaint,
    String? diagnosis,
    String? treatment,
    List<String>? prescriptions,
    List<String>? labOrders,
    String? notes,
    String? followUpDate,
    String? vitalSigns,
  }) async {
    final docRef = _consultationsCollection.doc();
    final consultation = ConsultationModel(
      id: docRef.id,
      ticketId: ticketId,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      department: department,
      chiefComplaint: chiefComplaint,
      diagnosis: diagnosis,
      treatment: treatment,
      prescriptions: prescriptions,
      labOrders: labOrders,
      notes: notes,
      followUpDate: followUpDate,
      vitalSigns: vitalSigns,
      consultationDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await docRef.set(consultation.toFirestore());
    return consultation;
  }

  // Update consultation
  Future<void> updateConsultation(
      String consultationId, Map<String, dynamic> data) async {
    await _consultationsCollection.doc(consultationId).update(data);
  }

  // ==================== NOTIFICATIONS ====================

  CollectionReference get _notificationsCollection =>
      _firestore.collection('notifications');

  // Get user's notifications
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // Get unread notifications count
  Stream<int> getUnreadNotificationsCount(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Create notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    String? relatedId,
  }) async {
    final docRef = _notificationsCollection.doc();
    final notification = NotificationModel(
      id: docRef.id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
      relatedId: relatedId,
    );

    await docRef.set(notification.toFirestore());
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({'isRead': true});
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    final snapshot = await _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ==================== USERS ====================

  CollectionReference get _usersCollection => _firestore.collection('users');

  // Get all users
  Stream<List<UserModel>> getAllUsers() {
    return _usersCollection.snapshots().map((snapshot) {
      final users =
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    });
  }

  // Get users by role
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _usersCollection.where('role', isEqualTo: role).snapshots().map(
      (snapshot) {
        final users =
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
        users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return users;
      },
    );
  }

  Stream<List<UserModel>> getActivePatients() {
    return _usersCollection
        .where('role', isEqualTo: 'patient')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
      (snapshot) {
        final users =
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
        users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return users;
      },
    );
  }

  // Get active doctors
  Stream<List<UserModel>> getActiveDoctors() {
    return _usersCollection
        .where('role', isEqualTo: 'doctor')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _usersCollection.doc(userId).update(data);
  }

  // Delete user (soft delete - set isActive to false)
  Future<void> deleteUser(String userId) async {
    await _usersCollection.doc(userId).update({'isActive': false});
  }

  // Get user stats
  Future<Map<String, int>> getUserStats() async {
    final snapshot = await _usersCollection.get();

    int patients = 0, nurses = 0, doctors = 0, admins = 0;
    for (var doc in snapshot.docs) {
      final user = UserModel.fromFirestore(doc);
      switch (user.role) {
        case 'patient':
          patients++;
          break;
        case 'nurse':
          nurses++;
          break;
        case 'doctor':
          doctors++;
          break;
        case 'admin':
          admins++;
          break;
      }
    }

    return {
      'total': snapshot.docs.length,
      'patients': patients,
      'nurses': nurses,
      'doctors': doctors,
      'admins': admins,
    };
  }

  // ==================== AUDIT LOGS ====================

  CollectionReference get _auditLogsCollection =>
      _firestore.collection('audit_logs');

  // Get audit logs
  Stream<List<AuditLogModel>> getAuditLogs({int limit = 100}) {
    return _auditLogsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuditLogModel.fromFirestore(doc))
            .toList());
  }

  // Get audit logs by action
  Stream<List<AuditLogModel>> getAuditLogsByAction(AuditAction action) {
    return _auditLogsCollection
        .where('action', isEqualTo: action.name)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuditLogModel.fromFirestore(doc))
            .toList());
  }

  // Create audit log
  Future<void> createAuditLog({
    required String userId,
    required String userName,
    required String userRole,
    required AuditAction action,
    required String description,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? details,
  }) async {
    final docRef = _auditLogsCollection.doc();
    final auditLog = AuditLogModel(
      id: docRef.id,
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: action,
      description: description,
      targetId: targetId,
      targetType: targetType,
      details: details,
      createdAt: DateTime.now(),
    );

    await docRef.set(auditLog.toFirestore());
  }

  // ==================== DASHBOARD STATS ====================

  Future<Map<String, dynamic>> getDashboardStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final startOfMonth = DateTime(today.year, today.month, 1);

    // Today's tickets
    final todayTicketsSnapshot = await _ticketsCollection
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    final todayAppointmentsSnapshot = await _appointmentsCollection
        .where('appointmentDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('appointmentDate',
            isLessThan:
                Timestamp.fromDate(startOfDay.add(const Duration(days: 1))))
        .get();

    // Monthly consultations
    final monthlyConsultationsSnapshot = await _consultationsCollection
        .where('consultationDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .get();

    // User counts
    final userStats = await getUserStats();

    return {
      'todayTickets': todayTicketsSnapshot.docs.length,
      'todayAppointments': todayAppointmentsSnapshot.docs.length,
      'monthlyConsultations': monthlyConsultationsSnapshot.docs.length,
      ...userStats,
    };
  }

  // Admin dashboard stats
  Future<Map<String, int>> getAdminDashboardStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    // Get user counts by role
    final usersSnapshot = await _usersCollection.get();
    int totalUsers = usersSnapshot.docs.length;
    int totalDoctors = 0;
    int totalNurses = 0;
    int totalPatients = 0;

    for (var doc in usersSnapshot.docs) {
      final role = doc.data() as Map<String, dynamic>;
      switch (role['role']) {
        case 'doctor':
          totalDoctors++;
          break;
        case 'nurse':
          totalNurses++;
          break;
        case 'patient':
          totalPatients++;
          break;
      }
    }

    // Today's tickets
    final todayTicketsSnapshot = await _ticketsCollection
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    final todayAppointmentsSnapshot = await _appointmentsCollection
        .where('appointmentDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('appointmentDate',
            isLessThan:
                Timestamp.fromDate(startOfDay.add(const Duration(days: 1))))
        .get();

    return {
      'totalUsers': totalUsers,
      'totalDoctors': totalDoctors,
      'totalNurses': totalNurses,
      'totalPatients': totalPatients,
      'todayTickets': todayTicketsSnapshot.docs.length,
      'todayAppointments': todayAppointmentsSnapshot.docs.length,
    };
  }
}
