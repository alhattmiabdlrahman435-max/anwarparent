import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/absence_request.dart';
import '../data/mock/mock_absence_requests.dart';

part 'absence_requests_provider.g.dart';

@Riverpod(keepAlive: true)
class AbsenceRequests extends _$AbsenceRequests {
  @override
  List<AbsenceRequest> build() {
    return MockAbsenceRequests.getRequests;
  }

  void addRequest(AbsenceRequest request) {
    state = [request, ...state];
  }
}
