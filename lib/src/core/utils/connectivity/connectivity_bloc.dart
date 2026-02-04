import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityCubit() : super(ConnectivityStatus.online) {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  void _updateStatus(List<ConnectivityResult> result) {
    final hasConnection = result.any((r) => r != ConnectivityResult.none);
    emit(hasConnection ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
