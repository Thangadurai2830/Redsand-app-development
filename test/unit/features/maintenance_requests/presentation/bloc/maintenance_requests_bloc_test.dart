import 'package:dartz/dartz.dart';
import 'package:flutter_app/core/error/failures.dart';
import 'package:flutter_app/features/maintenance_requests/domain/entities/maintenance_ticket.dart';
import 'package:flutter_app/features/maintenance_requests/presentation/bloc/maintenance_requests_bloc.dart';
import 'package:flutter_app/features/maintenance_requests/presentation/bloc/maintenance_requests_event.dart';
import 'package:flutter_app/features/maintenance_requests/presentation/bloc/maintenance_requests_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_fakes.dart';

MaintenanceTicket _ticket({String id = 't-1', String status = 'open'}) =>
    MaintenanceTicket(
      id: id,
      issueType: 'plumbing',
      description: 'Leaking pipe under sink',
      status: status,
      createdAt: DateTime(2024, 3, 1),
      updatedAt: DateTime(2024, 3, 1),
    );

MaintenanceRequestsBloc _bloc({
  required FakeGetMaintenanceHistory getHistory,
  required FakeRaiseMaintenanceRequest raise,
}) =>
    MaintenanceRequestsBloc(
      getMaintenanceHistory: getHistory,
      raiseMaintenanceRequest: raise,
    );

void main() {
  group('MaintenanceRequestsBloc – MaintenanceHistoryRequested', () {
    test('emits loading then loaded with tickets on success', () async {
      final ticket = _ticket();
      final bloc = _bloc(
        getHistory: FakeGetMaintenanceHistory(Right([ticket])),
        raise: FakeRaiseMaintenanceRequest(Right(ticket)),
      );

      bloc.add(const MaintenanceHistoryRequested());
      final states = await bloc.stream.take(2).toList();

      expect(states[0].status, MaintenanceRequestsStatus.loading);
      expect(states[1].status, MaintenanceRequestsStatus.loaded);
      expect(states[1].tickets, [ticket]);
      await bloc.close();
    });

    test('emits failure on network error', () async {
      final bloc = _bloc(
        getHistory: FakeGetMaintenanceHistory(Left(NetworkFailure())),
        raise: FakeRaiseMaintenanceRequest(Left(NetworkFailure())),
      );

      bloc.add(const MaintenanceHistoryRequested());
      final state = await bloc.stream.firstWhere(
        (s) => s.status == MaintenanceRequestsStatus.failure,
      );
      expect(state.message, contains('Unable to reach maintenance service'));
      await bloc.close();
    });

    test('emits generic failure message for non-network errors', () async {
      final bloc = _bloc(
        getHistory: FakeGetMaintenanceHistory(Left(CacheFailure())),
        raise: FakeRaiseMaintenanceRequest(Left(NetworkFailure())),
      );

      bloc.add(const MaintenanceHistoryRequested());
      final state = await bloc.stream.firstWhere(
        (s) => s.status == MaintenanceRequestsStatus.failure,
      );
      expect(state.message, 'Something went wrong. Please try again.');
      await bloc.close();
    });

    test('clears message when a new history load starts', () async {
      final bloc = _bloc(
        getHistory: FakeGetMaintenanceHistory(const Right([])),
        raise: FakeRaiseMaintenanceRequest(Left(NetworkFailure())),
      );

      bloc.add(const MaintenanceHistoryRequested());
      final loadingState = await bloc.stream.firstWhere(
        (s) => s.status == MaintenanceRequestsStatus.loading,
      );
      expect(loadingState.message, isNull);
      await bloc.close();
    });
  });

  group('MaintenanceRequestsBloc – MaintenanceRequestSubmitted', () {
    test('emits isSubmitting then loaded with new ticket prepended', () async {
      final ticket = _ticket(id: 'new-1');
      final bloc = _bloc(
        getHistory: FakeGetMaintenanceHistory(const Right([])),
        raise: FakeRaiseMaintenanceRequest(Right(ticket)),
      );

      bloc.add(const MaintenanceRequestSubmitted(
        issueType: 'plumbing',
        description: 'Leaking pipe under sink',
      ));

      final states = await bloc.stream.take(2).toList();
      expect(states[0].isSubmitting, isTrue);
      expect(states[1].status, MaintenanceRequestsStatus.loaded);
      expect(states[1].isSubmitting, isFalse);
      expect(states[1].tickets.first.id, 'new-1');
      expect(states[1].message, 'Maintenance ticket raised successfully');
      await bloc.close();
    });

    test('new ticket is prepended before existing tickets', () async {
      final existing = _ticket(id: 'old-1');
      final newTicket = _ticket(id: 'new-2');

      final bloc = _bloc(
        getHistory: FakeGetMaintenanceHistory(Right([existing])),
        raise: FakeRaiseMaintenanceRequest(Right(newTicket)),
      );

      bloc.add(const MaintenanceHistoryRequested());
      await bloc.stream.firstWhere(
        (s) => s.status == MaintenanceRequestsStatus.loaded,
      );

      bloc.add(const MaintenanceRequestSubmitted(
        issueType: 'electrical',
        description: 'Power socket not working',
      ));

      final state = await bloc.stream.firstWhere(
        (s) => s.message == 'Maintenance ticket raised successfully',
      );
      expect(state.tickets.first.id, 'new-2');
      expect(state.tickets.length, 2);
      await bloc.close();
    });

    test('emits failure on raise error', () async {
      final bloc = _bloc(
        getHistory: FakeGetMaintenanceHistory(const Right([])),
        raise: FakeRaiseMaintenanceRequest(Left(NetworkFailure())),
      );

      bloc.add(const MaintenanceRequestSubmitted(
        issueType: 'other',
        description: 'Some issue description text',
      ));

      final state = await bloc.stream.firstWhere(
        (s) => s.status == MaintenanceRequestsStatus.failure,
      );
      expect(state.isSubmitting, isFalse);
      expect(state.message, isNotNull);
      await bloc.close();
    });

    test('accepts optional photoPath', () async {
      final ticket = _ticket(id: 'photo-1');
      final bloc = _bloc(
        getHistory: FakeGetMaintenanceHistory(const Right([])),
        raise: FakeRaiseMaintenanceRequest(Right(ticket)),
      );

      bloc.add(const MaintenanceRequestSubmitted(
        issueType: 'structural',
        description: 'Wall crack visible',
        photoPath: '/path/to/photo.jpg',
      ));

      final state = await bloc.stream.firstWhere(
        (s) => s.status == MaintenanceRequestsStatus.loaded,
      );
      expect(state.tickets.first.id, 'photo-1');
      await bloc.close();
    });
  });

  group('MaintenanceRequestsBloc – MaintenanceMessageCleared', () {
    test('clears message from state', () async {
      final bloc = _bloc(
        getHistory: FakeGetMaintenanceHistory(Left(NetworkFailure())),
        raise: FakeRaiseMaintenanceRequest(Left(NetworkFailure())),
      );

      bloc.add(const MaintenanceHistoryRequested());
      await bloc.stream.firstWhere((s) => s.message != null);

      bloc.add(const MaintenanceMessageCleared());
      final state = await bloc.stream.first;
      expect(state.message, isNull);
      await bloc.close();
    });
  });

  group('MaintenanceRequestsState helpers', () {
    test('hasTickets returns false when tickets empty', () {
      const state = MaintenanceRequestsState.initial();
      expect(state.hasTickets, isFalse);
    });

    test('hasTickets returns true when tickets non-empty', () {
      final state = MaintenanceRequestsState(
        status: MaintenanceRequestsStatus.loaded,
        tickets: [_ticket()],
        isSubmitting: false,
        message: null,
      );
      expect(state.hasTickets, isTrue);
    });
  });
}
