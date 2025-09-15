import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:connectivity_plus_wrapper/connectivity_plus_wrapper.dart';

class MockConnectivity extends Mock implements Connectivity {}
class MockInternetConnectionChecker extends Mock implements InternetConnectionChecker {}

void main() {
  group('ConnectivityWrapper', () {
    late MockConnectivity mockConnectivity;
    late MockInternetConnectionChecker mockChecker;
    late ConnectivityWrapper wrapper;

    setUp(() {
      mockConnectivity = MockConnectivity();
      mockChecker = MockInternetConnectionChecker();
      
      // Provide default responses
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      
      when(() => mockChecker.hasConnection)
          .thenAnswer((_) async => true);
    });

    test('initializes with checking status', () async {
      wrapper = ConnectivityWrapper();
      await Future.delayed(Duration.zero); // Allow initialization to complete
      
      expect(await wrapper.currentStatus, ConnectionStatus.checking);
    });

    test('transitions from disconnected to restored when connection returns', () async {
      // Simulate initial disconnected state
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);
      
      wrapper = ConnectivityWrapper();
      await Future.delayed(Duration.zero);
      
      // Simulate connection restoration
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      
      // Trigger a connectivity change
      // (This would normally be done through the stream listener)
      
      // Verify the transition occurred
      // (Actual implementation would need more detailed mocking)
    });

    // Add more tests for different scenarios
  });
}