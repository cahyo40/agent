---
description: Integrasi Supabase sebagai alternative backend dengan flutter_bloc state management: Authentication, PostgreSQL Datab... (Sub-part 2/3)
---
  void _onProductUpdated(
    _ProductUpdated event,
    Emitter<ProductDetailState> emit,
  ) {
    emit(ProductDetailLoaded(
      product: ProductModel.fromJson(event.record),
    ));
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}

// ============================================================
// CHAT BLOC — Contoh realtime untuk messaging
// ============================================================

// features/chat/presentation/bloc/chat_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Events
sealed class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String text;
  const SendMessage({required this.text});
  @override
  List<Object?> get props => [text];
}

class _MessageInserted extends ChatEvent {
  final Map<String, dynamic> record;
  const _MessageInserted(this.record);
  @override
  List<Object?> get props => [record];
}

class _MessageDeleted extends ChatEvent {
  final Map<String, dynamic> oldRecord;
  const _MessageDeleted(this.oldRecord);
  @override
  List<Object?> get props => [oldRecord];
}

// State
class ChatState extends Equatable {
  final List<Map<String, dynamic>> messages;
  final bool isLoading;
  final bool isConnected;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.error,
  });

  ChatState copyWith({
    List<Map<String, dynamic>>? messages,
    bool? isLoading,
    bool? isConnected,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, isConnected, error];
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  ChatBloc(this._supabase) : super(const ChatState()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<_MessageInserted>(_onMessageInserted);
    on<_MessageDeleted>(_onMessageDeleted);

    // Subscribe ke realtime messages
    _channel = _supabase
        .channel('messages_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            add(_MessageInserted(payload.newRecord));
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            add(_MessageDeleted(payload.oldRecord));
          },
        )
        .subscribe((status, error) {
      // Tidak bisa emit langsung dari callback — tapi bisa track connection
      // Gunakan add() jika perlu update state
    });
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _supabase
          .from('messages')
          .select('*, users(name, avatar_url)')
          .order('created_at', ascending: true)
          .limit(50);

      emit(state.copyWith(
        isLoading: false,
        messages: List<Map<String, dynamic>>.from(response),
        isConnected: true,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Gagal memuat pesan: $e',
      ));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _supabase.from('messages').insert({
        'text': event.text,
        'user_id': _supabase.auth.currentUser!.id,
      });
      // Realtime subscription akan otomatis add ke messages
    } catch (e) {
      emit(state.copyWith(error: 'Gagal mengirim pesan: $e'));
    }
  }

  void _onMessageInserted(
    _MessageInserted event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      messages: [...state.messages, event.record],
    ));
  }

  void _onMessageDeleted(
    _MessageDeleted event,
    Emitter<ChatState> emit,
  ) {
    final filtered = state.messages
        .where((m) => m['id'] != event.oldRecord['id'])
        .toList();
    emit(state.copyWith(messages: filtered));
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}

// ============================================================
// PRESENCE TRACKING — Siapa yang online (Cubit)
// ============================================================

// features/presence/presentation/cubit/presence_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceState extends Equatable {
  final List<Map<String, dynamic>> onlineUsers;

  const PresenceState({this.onlineUsers = const []});

  @override
  List<Object?> get props => [onlineUsers];
}

class PresenceCubit extends Cubit<PresenceState> {
  final SupabaseClient _supabase;
  RealtimeChannel? _presenceChannel;

  PresenceCubit(this._supabase) : super(const PresenceState()) {
    _trackPresence();
  }

  void _trackPresence() {
    final userId = _supabase.auth.currentUser?.id ?? 'anonymous';

    _presenceChannel = _supabase.channel('online_users')
      ..onPresenceSync((payload) {
        final presenceState = _presenceChannel!.presenceState();
        final users = <Map<String, dynamic>>[];

        for (final entry in presenceState.entries) {
          for (final presence in entry.value) {
            users.add(presence.payload);
          }
        }
        emit(PresenceState(onlineUsers: users));
      })
      ..onPresenceJoin((payload) {
        // User baru join
      })
      ..onPresenceLeave((payload) {
        // User leave
      })
      ..subscribe((status, error) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await _presenceChannel!.track({
            'user_id': userId,
            'online_at': DateTime.now().toIso8601String(),
          });
        }
      });
  }

  @override
  Future<void> close() {
    _presenceChannel?.unsubscribe();
    return super.close();
  }
}
```

