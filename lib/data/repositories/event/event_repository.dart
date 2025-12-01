import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../../../features/event/models/event_model.dart';
import '../../../features/event/models/location_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';

class EventRepository extends GetxController {
  static EventRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Storage paths
  static const String _eventPosterPath = 'event_posters';

  /// Create new event - 使用 Firestore 自动生成 ID
  Future<String> createEvent(Event event) async {
    try {
      final eventData = {
        ...event.toJson(),
        'isPublish': event.isPublish,
      };

      final docRef = await _db.collection('events').add(eventData);
      print('✅ Event created with ID: ${docRef.id}');
      return docRef.id;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to create event: $e';
    }
  }

  /// Update existing event - 包含 eventId 和 isPublish
  Future<void> updateEvent(Event event) async {
    try {
      if (event.eventId.isEmpty) {
        throw 'Event ID cannot be empty for update';
      }

      final eventData = {
        ...event.toJson(),
        'isPublish': event.isPublish,
      };

      await _db.collection('events').doc(event.eventId).update(eventData);
      print('✅ Event updated: ${event.eventId}');
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to update event: $e';
    }
  }

  /// Upload event poster to Firebase Storage
  Future<String> uploadEventPoster(Uint8List imageBytes, String fileName) async {
    try {
      print('Storage - Starting upload: $_eventPosterPath/$fileName');
      print('Storage - File size: ${imageBytes.length} bytes');

      final ref = _storage.ref().child('$_eventPosterPath/$fileName');
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/webp',
        ),
      );

      uploadTask.snapshotEvents.listen((taskSnapshot) {
        print('Storage - Upload progress: ${taskSnapshot.bytesTransferred}/${taskSnapshot.totalBytes}');
      });

      final taskSnapshot = await uploadTask;
      print('Storage - Upload completed: ${taskSnapshot.totalBytes} bytes');

      return fileName;
    } on FirebaseException catch (e) {
      print('Storage - FirebaseException: ${e.code} - ${e.message}');
      throw 'Firebase Storage error (${e.code}): ${e.message}';
    } catch (e) {
      print('Storage - Unexpected error: $e');
      throw 'Failed to upload event poster: $e';
    }
  }

  /// Delete event poster from Firebase Storage
  Future<void> deleteEventPoster(String fileName) async {
    try {
      if (fileName.isEmpty) return;

      final ref = _storage.ref().child('$_eventPosterPath/$fileName');
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        throw FFirebaseException(e.code).message;
      }
    } catch (e) {
      print('Failed to delete event poster: $e');
    }
  }

  /// Get event poster URL from Firebase Storage
  Future<String?> getEventPosterUrl(String fileName) async {
    try {
      if (fileName.isEmpty) return null;

      String storagePath = fileName;
      if (!storagePath.startsWith('$_eventPosterPath/')) {
        storagePath = '$_eventPosterPath/$storagePath';
      }

      final ref = _storage.ref().child(storagePath);
      final url = await ref.getDownloadURL();

      return url;
    } on FirebaseException catch (e) {
      print('📁 ❌ FirebaseException for event poster: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('📁 ❌ Error getting event poster URL: $e');
      return null;
    }
  }

  // ==================== 🆕 Public Methods for EventRegistrationRepository ====================

  /// 【新增】批量获取 Events by IDs（已转换 poster URL）
  Future<List<Event>> getEventsByIds(List<String> eventIds) async {
    try {
      if (eventIds.isEmpty) return [];

      // Split into chunks of 10 (Firestore 'in' query limit)
      final chunks = <List<String>>[];
      for (var i = 0; i < eventIds.length; i += 10) {
        chunks.add(
          eventIds.sublist(
            i,
            i + 10 > eventIds.length ? eventIds.length : i + 10,
          ),
        );
      }

      print('📦 批量获取 ${eventIds.length} 个 Events，分成 ${chunks.length} 批查询');

      final allEvents = <Event>[];
      for (var i = 0; i < chunks.length; i++) {
        final chunk = chunks[i];
        print('🔍 正在查询第 ${i + 1} 批，包含 ${chunk.length} 个活动');

        // 🆕 只使用 FieldPath.documentId 查询，移除 status 过滤
        final eventsQuery = await _db
            .collection('events')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final doc in eventsQuery.docs) {
          final event = await _buildEventWithLocation(doc);

          // 🆕 在客户端过滤掉 deleted 状态
          if (event.status != 'deleted') {
            final eventWithPoster = await _convertPosterToDownloadUrl(event);
            allEvents.add(eventWithPoster);
            print('  ✅ 添加活动: ${event.eventId} (${event.title}, status: ${event.status})');
          } else {
            print('  ⏩ 跳过已删除活动: ${event.eventId}');
          }
        }
      }

      print('✅ 成功获取 ${allEvents.length} 个 Events (排除 deleted)');
      return allEvents;
    } on FirebaseException catch (e) {
      print('🔥 Firebase错误: ${e.code} - ${e.message}');
      throw FFirebaseException(e.code).message;
    } catch (e) {
      print('💥 错误: $e');
      throw 'Failed to get events by IDs: $e';
    }
  }

  /// Listen to multiple events by their IDs (realtime)
  Stream<List<Event>> listenEventsByIds(List<String> eventIds) {
    if (eventIds.isEmpty) {
      return Stream.value(<Event>[]);
    }

    // 分批：Firestore whereIn 最多 10 个 ID
    final chunks = <List<String>>[];
    for (var i = 0; i < eventIds.length; i += 10) {
      chunks.add(
        eventIds.sublist(
          i,
          i + 10 > eventIds.length ? eventIds.length : i + 10,
        ),
      );
    }

    // 创建一个 StreamController 来合并所有 chunks 的结果
    final controller = StreamController<List<Event>>.broadcast();

    // 每个 chunk 对应一个 stream subscription
    final List<StreamSubscription<List<Event>>> subscriptions = [];

    for (var chunk in chunks) {
      final chunkStream = _db
          .collection('events')
          .where(FieldPath.documentId, whereIn: chunk)
          .snapshots()
          .asyncMap((snapshot) async {
        final events = await Future.wait(
          snapshot.docs.map((doc) async {
            final event = await _buildEventWithLocation(doc);
            if (event.status != 'deleted') {
              return await _convertPosterToDownloadUrl(event);
            }
            return null;
          }),
        );
        return events.whereType<Event>().toList();
      });

      final subscription = chunkStream.listen(
            (chunkEvents) {
          // 每次任一 chunk 有变化，都重新收集所有 chunk 的最新数据
          _collectAllEventsFromChunks(chunks, controller);
        },
        onError: (error) {
          controller.addError(error);
        },
      );

      subscriptions.add(subscription);
    }

    // 首次触发：收集所有 chunk 的初始数据
    _collectAllEventsFromChunks(chunks, controller);

    // 返回 controller 的 stream
    return controller.stream;

    // 清理方法（如果需要手动关闭）
    controller.onCancel = () {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    };
  }

  /// 辅助方法：从所有 chunks 收集最新的 Event 数据
  Future<void> _collectAllEventsFromChunks(
      List<List<String>> chunks, StreamController<List<Event>> controller) async {
    try {
      final allEvents = <Event>[];

      // 并行获取每个 chunk 的最新数据
      final futures = chunks.map((chunk) async {
        final chunkStream = _db
            .collection('events')
            .where(FieldPath.documentId, whereIn: chunk)
            .snapshots()
            .asyncMap((snapshot) async {
          final events = await Future.wait(
            snapshot.docs.map((doc) async {
              final event = await _buildEventWithLocation(doc);
              if (event.status != 'deleted') {
                return await _convertPosterToDownloadUrl(event);
              }
              return null;
            }),
          );
          return events.whereType<Event>().toList();
        });

        // 取最新的值（用 first）
        return await chunkStream.first;
      });

      final chunkResults = await Future.wait(futures);
      for (final chunkEvents in chunkResults) {
        allEvents.addAll(chunkEvents);
      }

      // 按 startDateTime 排序（可选）
      allEvents.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

      controller.add(allEvents);
    } catch (e) {
      controller.addError(e);
    }
  }

  /// 【新增】验证 Event 是否可注册（供 EventRegistrationRepository 使用）
  Future<void> validateEventForRegistration(String eventId) async {
    try {
      final event = await getEventByIdFuture(eventId);

      if (event.isFullyBooked) {
        throw 'Event is fully booked';
      }

      if (!event.isRegistrationOpen) {
        throw 'Registration is closed for this event';
      }

      if (event.isCancelledByOrganizer) {
        throw 'Event has been cancelled by organizer';
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== End of Public Methods ====================

  /// Get all events as stream
  Stream<List<Event>> getAllEvents() {
    try {
      return _db
          .collection('events')
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .asyncMap((snapshot) async {
        final events = await Future.wait(
          snapshot.docs.map((doc) async {
            return await _buildEventWithLocation(doc);
          }),
        );
        return await _convertPostersToDownloadUrls(events);
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get all published events as stream
  Stream<List<Event>> getAllPublishedEvents() {
    try {
      return _db
          .collection('events')
          .where('status', isEqualTo: 'active')
          .where('isPublish', isEqualTo: true)
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .asyncMap((snapshot) async {
        final events = await Future.wait(
          snapshot.docs.map((doc) async {
            return await _buildEventWithLocation(doc);
          }),
        );
        return await _convertPostersToDownloadUrls(events);
      });
    } on FirebaseException catch (e) {
      print('$e');
      throw FFirebaseException(e.code).message;
    } catch (e) {
      print('$e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Build Event object with contained Location objects
  Future<Event> _buildEventWithLocation(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data();
    if (data == null) return Event.empty();

    try {
      Location location = Location.empty();

      if (data.containsKey('location') && data['location'] != null) {
        final locationData = data['location'] as Map<String, dynamic>;
        location = Location.fromJson(locationData);
      }

      return Event(
        eventId: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        contactEmail: data['contactEmail'] ?? '',
        contactPhoneNo: data['contactPhoneNo'] ?? '',
        location: location,
        poster: data['poster'] ?? '',
        startDateTime:
        (data['startDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        endDateTime:
        (data['endDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        registrationDeadline:
        (data['registrationDeadline'] as Timestamp?)?.toDate() ??
            DateTime.now(),
        maxParticipants: (data['maxParticipants'] as num?)?.toInt() ?? 0,
        registeredCount: (data['registeredCount'] as num?)?.toInt() ?? 0,
        createdAt:
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isPublish: data['isPublish'] ?? false,
        status: data['status'] ?? 'active',
        eventRegistrations: [],
      );
    } catch (e) {
      print('Error building event ${doc.id}: $e');
      return Event.empty();
    }
  }

  /// Get event by ID as stream
  Stream<Event> getEventById(String eventId) {
    try {
      return _db
          .collection('events')
          .doc(eventId)
          .snapshots()
          .asyncMap((snapshot) async {
        final event = await _buildEventWithLocation(snapshot);
        return await _convertPosterToDownloadUrl(event);
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get event by ID (future)
  Future<Event> getEventByIdFuture(String eventId) async {
    try {
      final doc = await _db.collection('events').doc(eventId).get();
      final event = await _buildEventWithLocation(doc);
      return await _convertPosterToDownloadUrl(event);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update event status
  Future<void> updateEventStatus(String eventId, String status) async {
    try {
      await _db.collection('events').doc(eventId).update({'status': status});
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to update event status: $e';
    }
  }

  /// Toggle event publish status
  Future<void> togglePublishStatus(String eventId, bool isPublish) async {
    try {
      await _db.collection('events').doc(eventId).update({'isPublish': isPublish});
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to toggle publish status: $e';
    }
  }

  /// Update event registered count
  Future<void> updateEventRegisteredCount(String eventId, int increment) async {
    try {
      print('🔄 开始更新 registeredCount: eventId=$eventId, increment=$increment');

      await _db.collection('events').doc(eventId).update({
        'registeredCount': FieldValue.increment(increment),
      });

      print('✅ registeredCount 更新成功');

      // 🆕 验证更新是否成功
      final doc = await _db.collection('events').doc(eventId).get();
      final data = doc.data();
      if (data != null) {
        final count = (data['registeredCount'] as num?)?.toInt() ?? 0;
        print('✅ 当前 registeredCount = $count');
      }
    } on FirebaseException catch (e) {
      print('🔥 Firebase 错误更新 registeredCount: ${e.code} - ${e.message}');
      throw FFirebaseException(e.code).message;
    } catch (e) {
      print('💥 未知错误更新 registeredCount: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get events by status
  Stream<List<Event>> getEventsByStatus(String status) {
    try {
      return _db
          .collection('events')
          .where('status', isEqualTo: 'active')
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .asyncMap((snapshot) async {
        final events = await Future.wait(
          snapshot.docs.map((doc) async {
            return await _buildEventWithLocation(doc);
          }),
        );

        List<Event> filtered;
        switch (status) {
          case 'Open':
            filtered = events.where((event) {
              return event.isRegistrationOpen &&
                  !event.isFullyBooked &&
                  !event.hasEnded;
            }).toList();
            break;

          case 'Full':
            filtered = events.where((event) {
              return event.isFullyBooked &&
                  !event.isRegistrationClosed &&
                  !event.hasEnded;
            }).toList();
            break;

          case 'Closed':
            filtered = events.where((event) {
              return event.isRegistrationClosed && !event.hasEnded;
            }).toList();
            break;

          default:
            filtered = events.where((event) => !event.hasEnded).toList();
            break;
        }

        return await _convertPostersToDownloadUrls(filtered);
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Filter events by date range
  Stream<List<Event>> getEventsByDateRange(
      DateTime startDate, DateTime endDate) {
    try {
      return _db
          .collection('events')
          .where('startDateTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startDateTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .asyncMap((snapshot) async {
        final events = await Future.wait(
          snapshot.docs.map((doc) async {
            return await _buildEventWithLocation(doc);
          }),
        );
        final upcoming = events.where((event) => !event.hasEnded).toList();
        return await _convertPostersToDownloadUrls(upcoming);
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Check if event poster exists
  Future<bool> eventPosterExists(String posterFileName) async {
    try {
      if (posterFileName.isEmpty) return false;

      final path = '$_eventPosterPath/$posterFileName';
      final ref = _storage.ref().child(path);

      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Helper method to get location for a specific event
  Future<Location> getEventLocation(String eventId) async {
    try {
      final doc = await _db.collection('events').doc(eventId).get();
      final data = doc.data();

      if (data == null || !data.containsKey('location')) {
        return Location.empty();
      }

      final locationData = data['location'] as Map<String, dynamic>;
      return Location.fromJson(locationData);
    } catch (e) {
      print('Error getting event location: $e');
      return Location.empty();
    }
  }

  /// 将单个 Event 的 poster 文件名转换为下载 URL
  Future<Event> _convertPosterToDownloadUrl(Event event) async {
    try {
      if (event.poster.isEmpty || event.poster.startsWith('http')) {
        return event;
      }

      final downloadUrl = await getEventPosterUrl(event.poster);
      if (downloadUrl == null || downloadUrl.isEmpty) {
        return event;
      }

      return event.copyWith(poster: downloadUrl);
    } catch (e) {
      print('❌ Failed to convert poster to download URL for event ${event.eventId}: $e');
      return event;
    }
  }

  /// 批量转换 Event 列表的 poster 为下载 URL
  Future<List<Event>> _convertPostersToDownloadUrls(List<Event> events) async {
    final List<Event> result = [];
    for (final event in events) {
      try {
        final updatedEvent = await _convertPosterToDownloadUrl(event);
        result.add(updatedEvent);
      } catch (e) {
        print('❌ Failed to convert poster for event ${event.eventId}: $e');
        result.add(event);
      }
    }
    return result;
  }
}
