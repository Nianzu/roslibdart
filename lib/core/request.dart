// Copyright (c) 2019 Conrad Heidebrecht.

import 'dart:convert';

/// Container for all possible ROS request parameters.
class Request {
  Request({
    required this.op,
    this.id,
    this.type,
    this.topic,
    this.msg,
    this.action,
    this.action_type,
    this.latch,
    this.compression,
    this.throttleRate,
    this.queueLength,
    this.queueSize,
    this.service,
    this.args,
    this.values,
    this.result,
  });

  /// Requested operation.
  String op;

  /// ID to distinguish request or object operating on.
  String? id;

  /// Message or service type.
  String? type;

  /// Topic name operating on.
  String? topic;

  /// Message object (generally JSON).
  dynamic msg;

  String? action;

  String? action_type;

  /// Latch the topic when publishing.
  bool? latch;

  /// The type of compression to use, like 'png' or 'cbor'.
  String? compression;

  /// The rate (in ms between messages) at which to throttle the topic.
  int? throttleRate;

  /// The queue length at the bridge side used when subscribing.
  int? queueLength;

  /// The queue created at the bridge side for republishing topics.
  int? queueSize;

  /// Service name operating on.
  String? service;

  /// Arguments of the request (JSON).
  Map<String, dynamic>? args;

  /// Values returned from a request.
  dynamic values;

  /// Boolean value indicating the success of the operation.
  bool? result;

  factory Request.fromJson(dynamic jsonData) {
    return Request(
      op: jsonData['op'],
      id: jsonData['id'],
      type: jsonData['type'],
      topic: jsonData['topic'],
      msg: jsonData['msg'],
      action: jsonData['action'],
      action_type: jsonData['action_type'],
      latch: jsonData['latch'],
      compression: jsonData['compression'],
      throttleRate: jsonData['throttle_rate'],
      queueLength: jsonData['queue_length'],
      queueSize: jsonData['queue_size'],
      service: jsonData['service'],
      args: jsonData['args'],
      values: jsonData['values'],
      result: jsonData['result'],
    );
  }

  factory Request.decode(String raw) {
    return Request.fromJson(json.decode(raw));
  }

  Map<String, dynamic> toJson() {
    return {
      'op': op,
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (topic != null) 'topic': topic,
      if (msg != null) 'msg': msg,
      if (action != null) 'action': action,
      if (action_type != null) 'action_type': action_type,
      if (latch != null) 'latch': latch,
      if (compression != null) 'compression': compression,
      if (throttleRate != null) 'throttle_rate': throttleRate,
      if (queueLength != null) 'queue_length': queueLength,
      if (queueSize != null) 'queue_size': queueSize,
      if (service != null) 'service': service,
      if (args != null) 'args': args,
      if (values != null) 'values': values,
      if (result != null) 'result': result,
    };
  }

  String encode() {
    return json.encode(toJson());
  }
}
