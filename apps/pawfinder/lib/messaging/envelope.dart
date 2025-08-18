import 'dart:convert';

import 'package:uuid/uuid.dart';

final Uuid _uuid = const Uuid();

String generateMessageId() => _uuid.v4();

/// Declarative rule for a payload field.
class FieldSpec {
  /// Logical type token (e.g. 'string', 'int', 'double', 'map', 'list').
  final String type;

  /// If true, the field is allowed to be omitted entirely.
  final bool optional;

  /// If true, the field may exist with a null value.
  final bool nullable;

  const FieldSpec(this.type, {this.optional = false, this.nullable = false});
}

enum MessageType {
  /// Special type for parse errors
  parseError({
    'raw': FieldSpec('String'), // the raw input that failed to parse
    'reason': FieldSpec('String'), // description of the error
  }),

  /// Allows for both sides to request data from each other.
  request({
    'message_type': FieldSpec('String'), // the requested action
  }),

  /// Scout data submission
  scoutData({
    'submitted_timestamp': FieldSpec('String'),
    // UTC timestamp of when the data was saved by the scout
    'scout_id': FieldSpec('String'),
    // unique scout identifier
    'data': FieldSpec('Map<String, dynamic>'),
    // the actual scout json
  }),

  /// Device status/heartbeat
  status({
    'battery_level': FieldSpec('int'), // 0-100
  });

  final Map<String, FieldSpec> payloadSchema;

  const MessageType(this.payloadSchema);
}

/// Envelope for all messages passed between devices.
class MessageEnvelope {
  /// Message category (enum).
  final MessageType type;

  /// UTC timestamp the message was created.
  final DateTime timestamp;

  /// Unique message id (UUID v4).
  final String messageId;

  /// Optional: ties a response to a prior request's id.
  final String? respondsTo;

  /// Device ID of the sender/originator.
  final String origin;

  /// Device ID of the intended recipient. Empty string means broadcast.
  final String destination;

  /// Arbitrary business/body data.
  final Map<String, dynamic> payload;

  /// Convenience accessor for request action field.
  String? get requestedType => payload['message_type'] as String?;

  const MessageEnvelope({
    required this.type,
    required this.timestamp,
    required this.messageId,
    this.respondsTo,
    required this.origin,
    required this.destination,
    required this.payload,
  });

  /// Convenience factory for creating request messages
  factory MessageEnvelope.request(
    String messageType,
    String thisDeviceId,
    String destination, {
    DateTime? timestamp,
  }) {
    return MessageEnvelope(
      type: MessageType.request,
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      messageId: generateMessageId(),
      origin: thisDeviceId,
      destination: destination,
      payload: {'message_type': messageType},
    );
  }

  /// Convenience factory for request messages with additional payload fields
  factory MessageEnvelope.requestWithPayload(
    String messageType,
    String thisDeviceId,
    String destination,
    Map<String, dynamic> extra, {
    DateTime? timestamp,
  }) {
    return MessageEnvelope(
      type: MessageType.request,
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      messageId: generateMessageId(),
      origin: thisDeviceId,
      destination: destination,
      payload: {'message_type': messageType, ...extra},
    );
  }

  /// Convenience factory for scout data
  factory MessageEnvelope.scoutData(
    String submittedTimestamp,
    String scoutId,
    String thisDeviceId,
    String destination,
    Map<String, dynamic> data, {
    DateTime? timestamp,
  }) {
    return MessageEnvelope(
      type: MessageType.scoutData,
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      messageId: generateMessageId(),
      origin: thisDeviceId,
      destination: destination,
      payload: {
        'submitted_timestamp': submittedTimestamp,
        'scout_id': scoutId,
        'data': data,
      },
    );
  }

  /// Convenience factory for status messages
  factory MessageEnvelope.status(
    int batteryLevel,
    String thisDeviceId,
    String destination, {
    DateTime? timestamp,
  }) {
    return MessageEnvelope(
      type: MessageType.status,
      timestamp: (timestamp ?? DateTime.now()).toUtc(),
      messageId: generateMessageId(),
      origin: thisDeviceId,
      destination: destination,
      payload: {'battery_level': batteryLevel},
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'type': type.name,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'message_id': messageId,
    if (respondsTo != null) 'responds_to': respondsTo,
    'origin': origin,
    'destination': destination,
    'payload': payload,
  };

  String toJson() => jsonEncode(toMap());

  /// Validate payload against the enum's declared schema.
  /// Returns empty list if valid; otherwise list of error messages.
  /// If [strict] is true, extra keys not present in the schema are reported.
  List<String> validatePayload({bool strict = false}) {
    final errors = <String>[];
    final schema = type.payloadSchema;

    // Required + optional fields
    schema.forEach((key, spec) {
      final hasKey = payload.containsKey(key);
      if (!hasKey) {
        if (!spec.optional) errors.add('missing key "$key"');
        return;
      }

      final value = payload[key];
      if (value == null) {
        if (!spec.nullable) errors.add('key "$key" may not be null');
        return;
      }

      if (!_matchesTypeName(value, spec.type)) {
        errors.add('key "$key" expected ${spec.type} got ${value.runtimeType}');
      }
    });

    if (strict) {
      for (final k in payload.keys) {
        if (!schema.containsKey(k)) {
          errors.add('unexpected key "$k"');
        }
      }
    }

    return errors;
  }

  @override
  String toString() =>
      'Envelope(type=${type.name} time=$timestamp id=$messageId'
      '${respondsTo != null ? ' respondsTo=$respondsTo' : ''} payload=$payload)';
}

bool _matchesTypeName(Object? value, String expected) {
  final norm = expected.toLowerCase();
  switch (norm) {
    case 'string':
      return value is String;
    case 'int':
      return value is int;
    case 'double':
      // Note: allow int where a double is expected (e.g., 3 instead of 3.0)
      return value is double || value is int; // allow int for double fields
    case 'bool':
    case 'boolean':
      return value is bool;
    case 'map':
    case 'map<string, dynamic>':
      return value is Map<String, dynamic>;
    case 'list':
    case 'list<dynamic>':
      return value is List;
    default:
      // Unknown specification: treat as pass-through (future extensibility)
      return true;
  }
}

/// Parse raw JSON into a MessageEnvelope.
MessageEnvelope parseEnvelope(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return _errorEnvelope(raw, 'not a JSON object');
    }

    final map = Map<String, dynamic>.from(decoded);

    final typeName = (map['type'] ?? '_unknown').toString();
    final messageType = MessageType.values.firstWhere(
      (m) => m.name == typeName,
      orElse: () => MessageType.parseError,
    );

    // If type is unknown, return a clearer parse error immediately.
    if (messageType == MessageType.parseError && typeName != 'parseError') {
      return _errorEnvelope(raw, 'unknown message type: $typeName');
    }

    final timestamp = _parseTimestamp(map['timestamp']);
    final messageId = (map['message_id'] ?? generateMessageId()).toString();
    final origin = (map['origin'] ?? '').toString();
    final destination = (map['destination'] ?? '').toString();
    final respondsTo = map['responds_to']?.toString();

    // Payload must be explicit and a Map (keys coerced to String).
    Map<String, dynamic> payload = <String, dynamic>{};
    if (map['payload'] is Map) {
      payload = Map<String, dynamic>.from(map['payload'] as Map);
    }

    final envelope = MessageEnvelope(
      type: messageType,
      timestamp: timestamp,
      messageId: messageId,
      respondsTo: respondsTo,
      origin: origin,
      destination: destination,
      payload: payload,
    );

    // Schema validation
    final validationErrors = envelope.validatePayload();
    if (validationErrors.isNotEmpty) {
      return _errorEnvelope(
        raw,
        'schema validation failed: ${validationErrors.join(', ')}',
      );
    }

    return envelope;
  } on FormatException catch (e) {
    // Commonly thrown for invalid timestamp formats via _parseTimestamp
    return _errorEnvelope(raw, e.message);
  } catch (e) {
    return _errorEnvelope(raw, 'parse error: $e');
  }
}

DateTime _parseTimestamp(Object? value) {
  if (value == null) return DateTime.now().toUtc();
  try {
    return DateTime.parse(value.toString()).toUtc();
  } catch (_) {
    // Escalate invalid timestamp to a parse error for visibility.
    throw const FormatException('invalid timestamp');
  }
}

MessageEnvelope _errorEnvelope(String raw, String reason) => MessageEnvelope(
  type: MessageType.parseError,
  timestamp: DateTime.now().toUtc(),
  messageId: generateMessageId(),
  respondsTo: null,
  origin: 'parser',
  destination: '',
  payload: {'raw': raw, 'reason': reason},
);
