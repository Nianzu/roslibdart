// Copyright (c) 2025 Nico Zucca.

import 'dart:async';
import 'ros.dart';
import 'request.dart';

/// !TODO
// Receiver function to handle requests when the service is advertising.
typedef ActionHandler = Future<Map<String, dynamic>>? Function(
    Map<String, dynamic> args);

/// Wrapper to interact with ROS services.
class Action {
  Action({
    required this.ros,
    required this.name,
    required this.type,
  });

  /// The ROS connection.
  Ros ros;

  /// Name of the action.
  String name;

  /// Type of the action.
  String type;

  /// !TODO
  /// Advertiser that is listened to for service requests when advertising.
  Stream<Map<String, dynamic>>? _advertiser;

  /// !TODO
  /// Checks whether or not the service is currently advertising.
  bool get isAdvertised => _advertiser != null;

  StreamSubscription? listener;
  StreamSubscription? connection_listener;

  /// Call the service with a request ([req]).
  (String, Future<bool>?) sendGoal(dynamic goal) {
    // The action can't be called if it's currently advertising.
    if (isAdvertised) return ("", null);

    // !TODO
    // Set up the response receiver by filtering data from the ROS node by
    // the ID generated.
    final actionId = ros.requestActionCaller(name);

    // deal with callbacks
    final receiver = ros.stream.where((message) =>
        message['id'] == actionId && message['op'] == 'action_result');

    // Create a completer that gets completed when the action finishes, or the ros
    // connection dies.
    final completer = Completer<bool>();

    connection_listener = ros.statusStream.listen((status) {
      switch (status) {
        case Status.closed:
        case Status.errored:
          print("Connection closed or error");
          if (!completer.isCompleted) {
            completer.complete(false);
          }
          if (connection_listener != null) {
            connection_listener!.cancel();
          }
          if (listener != null) {
            listener!.cancel();
          }
        default:
      }
    });

    listener = receiver.listen((message) {
      if (!completer.isCompleted) {
        completer.complete(true);
        print("Goal completed");
      }
      if (connection_listener != null) {
        connection_listener!.cancel();
      }
      if (listener != null) {
        listener!.cancel();
      }
    });

    // TODO deal with feedback
    // Actually send the request.
    ros.send(Request(
      op: 'send_action_goal',
      id: actionId,
      action: name,
      action_type: type,
      args: goal,
    ));

    return (actionId, completer.future);
  }

  void cancelGoal(String actionId) {
    ros.send(Request(
      op: 'cancel_action_goal',
      id: actionId,
      action: name,
    ));
  }

  // TODO
  // Advertise the service and provide a [handler] to deal with requests.
  Future<void> advertise(ActionHandler handler) async {
    if (isAdvertised) return;
    // Send the advertise request.
    ros.send(Request(
      op: 'advertise_service',
      type: type,
      service: name,
    ));
    // Listen for requests, forward them to the handler and then
    // send the response back to the ROS node.
    _advertiser = ros.stream;
    _advertiser!.listen((Map<String, dynamic> message) async {
      if (message['service'] != name) {
        return;
      }
      Map<String, dynamic>? resp = await handler(message['args']);
      ros.send(Request(
        op: 'service_response',
        id: message['id'],
        service: name,
        values: resp ?? {},
        result: resp != null,
      ));
    });

    /*
    _advertiser = ros.stream
        .where((message) => message['service'] == name)
        .asyncMap((req) => handler(req['args'])!.then((resp) {
              ros.send(Request(
                op: 'service_response',
                id: req['id'],
                service: name,
                values: resp ?? {},
                result: resp != null,
              ));
            }));
            */
  }

  // TODO
  // Stop advertising the service.
  void unadvertise() {
    if (!isAdvertised) return;
    ros.send(Request(
      op: 'unadvertise_service',
      service: name,
    ));
    _advertiser = null;
  }
  // TODO cancel goal, execute action, send feedback, set succeeded/canceled/failed
}
