// functions/src/event-reminders.ts
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {onSchedule} from "firebase-functions/v2/scheduler";

/**
 * Send event reminder notification
 * 通过 registrationId 获取 userId 和 eventId
 */
export const sendEventReminder = async (
  registrationId: string,
  reminderId: string,
  title: string,
  message: string
): Promise<void> => {
  try {
    // 1. 通过 registrationId 获取 EventRegistration
    const registrationDoc = await admin.firestore()
      .collection("eventRegistrations")
      .doc(registrationId)
      .get();

    if (!registrationDoc.exists) {
      functions.logger.error(`EventRegistration ${registrationId} does not exist`);
      return;
    }

    const registrationData = registrationDoc.data();
    const userId = registrationData?.userId;
    const eventId = registrationData?.eventId;

    if (!userId || !eventId) {
      functions.logger.error(`EventRegistration ${registrationId} missing userId or eventId`);
      return;
    }

    // 2. 获取用户的 FCM tokens
    const userDoc = await admin.firestore().collection("users").doc(userId).get();
    if (!userDoc.exists) {
      functions.logger.error(`User ${userId} does not exist`);
      return;
    }

    const userData = userDoc.data();
    const fcmTokens = userData?.fcmTokens || [];

    if (fcmTokens.length === 0) {
      functions.logger.warn(`User ${userId} has no registered FCM tokens`);
      return;
    }

    // 3. 构建通知消息
    const notificationMessage: admin.messaging.MulticastMessage = {
      tokens: fcmTokens,
      notification: {
        title: title,
        body: message,
      },
      data: {
        type: "event_reminder",
        eventId: eventId,
        reminderId: reminderId,
        registrationId: registrationId,
        userId: userId, // 包含 userId 用于客户端验证
        title: title,
        message: message,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
      android: {
        priority: "high",
        notification: {
          sound: "default",
          channelId: "event_reminders",
        },
      },
    };

    // 4. 发送通知
    const response = await admin.messaging().sendEachForMulticast(notificationMessage);
    functions.logger.info(`Successfully sent ${response.successCount} event reminders`);

    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          functions.logger.error(`Failed to send to token ${fcmTokens[idx]}:`, resp.error);
        }
      });
    }

    // 5. 更新提醒状态为已发送
    await admin.firestore()
      .collection("reminders")
      .doc(reminderId)
      .update({
        isSent: true,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    functions.logger.info(`Event reminder sent for registration: ${registrationId}`);

  } catch (error) {
    functions.logger.error("Error sending event reminder notification:", error);
    throw error;
  }
};

/**
 * Schedule event reminders - check every 5 minutes
 * 定时检查需要发送的提醒
 */
export const scheduleEventReminders = onSchedule({
  schedule: "every 5 minutes",
  timeZone: "Asia/Kuala_Lumpur",
  retryCount: 3,
}, async (event) => {
  try {
    const now = new Date();
    const oneHourLater = new Date(now.getTime() + 60 * 60 * 1000); // 1小时内

    // 查找需要发送的提醒（未发送且在1小时内）
    const pendingReminders = await admin.firestore()
      .collection("reminders")
      .where("isSent", "==", false)
      .where("remindAt", ">=", now)
      .where("remindAt", "<=", oneHourLater)
      .get();

    functions.logger.info(`Found ${pendingReminders.size} pending event reminders`);

    // 处理每个提醒
    for (const reminderDoc of pendingReminders.docs) {
      const reminder = reminderDoc.data();
      const reminderId = reminderDoc.id;
      const registrationId = reminder.registrationId;

      if (!registrationId) {
        functions.logger.error(`Reminder ${reminderId} missing registrationId`);
        continue;
      }

      // 发送提醒通知
      await sendEventReminder(
        registrationId,
        reminderId,
        reminder.title,
        reminder.message
      );

      functions.logger.info(`Processed reminder for registration: ${registrationId}`);
    }

    functions.logger.info("Event reminder processing completed");
  } catch (error) {
    functions.logger.error("Error processing event reminders:", error);
    throw error;
  }
});

/**
 * HTTP endpoint to manually send event reminder (for testing)
 */
export const sendEventReminderHttp = functions.https.onCall(async (data, context) => {
  // 检查认证
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const { registrationId, reminderId, title, message } = data;

  if (!registrationId || !reminderId || !title || !message) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required fields"
    );
  }

  try {
    await sendEventReminder(registrationId, reminderId, title, message);
    return {
      success: true,
      message: "Event reminder sent successfully"
    };
  } catch (error) {
    throw new functions.https.HttpsError(
      "internal",
      "Failed to send event reminder"
    );
  }
});

/**
 * 清理过期的提醒（可选）
 */
export const cleanupExpiredReminders = onSchedule({
  schedule: "every 24 hours",
  timeZone: "Asia/Kuala_Lumpur",
}, async (event) => {
  try {
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    // 删除一周前已发送的提醒
    const expiredReminders = await admin.firestore()
      .collection("reminders")
      .where("isSent", "==", true)
      .where("sentAt", "<", oneWeekAgo)
      .get();

    const batch = admin.firestore().batch();
    expiredReminders.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    functions.logger.info(`Cleaned up ${expiredReminders.size} expired reminders`);
  } catch (error) {
    functions.logger.error("Error cleaning up expired reminders:", error);
  }
});