import 'package:flutter/foundation.dart';
import '../data/models/auth/activity_model.dart';
import '../services/firestore_service.dart';

class ActivityProvider extends ChangeNotifier {
  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  String? _error;

  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<ActivityModel>> get activitiesStream => FirestoreService.getActivities();

  void loadActivitiesStream(Stream<List<ActivityModel>> stream) {
    stream.listen(
      (activities) {
        _activities = activities;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  List<ActivityModel> filterByType(ActivityType? type) {
    if (type == null) return _activities;
    return _activities.where((a) => a.type == type).toList();
  }
}