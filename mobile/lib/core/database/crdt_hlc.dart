// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

import 'dart:math';

/// Hybrid Logical Clock (HLC) implementation for Conflict-Free Replicated Data Types (CRDT).
/// Ensures total causal ordering of offline sync events across intermittent NER village networks.
class HLC implements Comparable<HLC> {
  final int millis;
  final int counter;
  final String nodeId;

  const HLC({
    required this.millis,
    required this.counter,
    required this.nodeId,
  });

  /// Generates a initial HLC instance for a device node
  factory HLC.now(String nodeId, [HLC? previous]) {
    final nowMillis = DateTime.now().toUtc().millisecondsSinceEpoch;
    if (previous == null) {
      return HLC(millis: nowMillis, counter: 0, nodeId: nodeId);
    }

    if (nowMillis > previous.millis) {
      return HLC(millis: nowMillis, counter: 0, nodeId: nodeId);
    } else {
      return HLC(millis: previous.millis, counter: previous.counter + 1, nodeId: nodeId);
    }
  }

  /// Merges a remote HLC timestamp with local clock state
  factory HLC.receive(String nodeId, HLC local, HLC remote) {
    final nowMillis = DateTime.now().toUtc().millisecondsSinceEpoch;
    final maxMillis = [nowMillis, local.millis, remote.millis].reduce(max);

    int newCounter;
    if (maxMillis == local.millis && maxMillis == remote.millis) {
      newCounter = max(local.counter, remote.counter) + 1;
    } else if (maxMillis == local.millis) {
      newCounter = local.counter + 1;
    } else if (maxMillis == remote.millis) {
      newCounter = remote.counter + 1;
    } else {
      newCounter = 0;
    }

    return HLC(millis: maxMillis, counter: newCounter, nodeId: nodeId);
  }

  /// Serializes HLC to canonical string: "1710000000000:0001:nodeId"
  String toCanonicalString() {
    final paddedCounter = counter.toString().padLeft(4, '0');
    return '$millis:$paddedCounter:$nodeId';
  }

  /// Deserializes canonical HLC string
  factory HLC.parse(String canonical) {
    final parts = canonical.split(':');
    if (parts.length < 3) {
      return HLC(
        millis: DateTime.now().toUtc().millisecondsSinceEpoch,
        counter: 0,
        nodeId: 'unknown',
      );
    }
    return HLC(
      millis: int.tryParse(parts[0]) ?? 0,
      counter: int.tryParse(parts[1]) ?? 0,
      nodeId: parts.sublist(2).join(':'),
    );
  }

  @override
  int compareTo(HLC other) {
    if (millis != other.millis) {
      return millis.compareTo(other.millis);
    }
    if (counter != other.counter) {
      return counter.compareTo(other.counter);
    }
    return nodeId.compareTo(other.nodeId);
  }

  bool isAfter(HLC other) => compareTo(other) > 0;
  bool isBefore(HLC other) => compareTo(other) < 0;

  @override
  String toString() => toCanonicalString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HLC &&
          runtimeType == other.runtimeType &&
          millis == other.millis &&
          counter == other.counter &&
          nodeId == other.nodeId;

  @override
  int get hashCode => millis.hashCode ^ counter.hashCode ^ nodeId.hashCode;
}

/// Generic CRDT Envelope for Delta-State Synchronization
class CRDTDeltaMessage {
  final String tableName;
  final String rowId;
  final Map<String, dynamic> fields;
  final String hlcTimestamp;
  final bool isDeleted;

  CRDTDeltaMessage({
    required this.tableName,
    required this.rowId,
    required this.fields,
    required this.hlcTimestamp,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() => {
        'table_name': tableName,
        'row_id': rowId,
        'fields': fields,
        'hlc_timestamp': hlcTimestamp,
        'is_deleted': isDeleted ? 1 : 0,
      };

  factory CRDTDeltaMessage.fromJson(Map<String, dynamic> json) => CRDTDeltaMessage(
        tableName: json['table_name'] as String,
        rowId: json['row_id'] as String,
        fields: Map<String, dynamic>.from(json['fields'] as Map),
        hlcTimestamp: json['hlc_timestamp'] as String,
        isDeleted: (json['is_deleted'] as int? ?? 0) == 1,
      );
}

