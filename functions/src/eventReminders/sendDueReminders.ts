import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions/v2';

// 在 sendDueReminders.ts 中确保使用 UTC 时间比较
export const sendDueReminders = functions.scheduler.onSchedule('every 5 minutes', async (event) => {
  try {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now(); // 使用 UTC 时间

    console.log('Checking for due reminders at UTC time:', now.toDate().toISOString());

    const dueReminders = await db.collection('reminders')
      .where('isSent', '==', false)
      .where('remindAt', '<=', now)  // 使用 UTC 时间比较
      .get();

    console.log(`Found ${dueReminders.size} due reminders`);

    for (const reminderDoc of dueReminders.docs) {
      await processReminder(reminderDoc, db);
    }

    console.log('Due reminders processing completed');
  } catch (error: any) {
    console.error('Error in sendDueReminders:', error);
  }
});

async function processReminder(reminderDoc: admin.firestore.QueryDocumentSnapshot, db: admin.firestore.Firestore) {
  const reminder = reminderDoc.data();
  const reminderId = reminderDoc.id;

  try {
    console.log(`Processing reminder: ${reminderId}`);

    // 1. 通过 registrationId 获取注册信息
    const registrationDoc = await db.collection('eventRegistrations').doc(reminder.registrationId).get();
    if (!registrationDoc.exists) {
      console.log(`Registration not found for reminder ${reminderId}`);
      await reminderDoc.ref.update({ isSent: true });
      return;
    }

    const registration = registrationDoc.data();
    const userId = registration!.userId;
    const eventId = registration!.eventId;

    // 2. 获取事件信息
    const eventDoc = await db.collection('events').doc(eventId).get();
    if (!eventDoc.exists) {
      console.log(`Event not found for reminder ${reminderId}`);
      await reminderDoc.ref.update({ isSent: true });
      return;
    }

    const event = eventDoc.data();

    // 3. 获取用户的 FCM tokens
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();
    const fcmTokens = userData?.fcmTokens || [];

    if (fcmTokens.length === 0) {
      console.log(`No FCM tokens found for user ${userId}`);
      await reminderDoc.ref.update({ isSent: true });
      return;
    }

    // 4. 为每个 token 创建单独的消息并发送
    const sendPromises = fcmTokens.map(async (token: string) => {
      try {
        const message = createNotificationMessage(reminder, event!, userId, eventId, reminderId, token);
        const response = await admin.messaging().send(message);
        return { success: true, token, response };
      } catch (error: any) {
        return { success: false, token, error: error.message };
      }
    });

    // 5. 等待所有发送完成
    const results = await Promise.all(sendPromises);

    // 6. 处理发送结果
    await handleSendResult(results, userId, db, reminderDoc);

  } catch (error: any) {
    console.error(`Error processing reminder ${reminderId}:`, error);
  }
}

function createNotificationMessage(
  reminder: any,
  event: any,
  userId: string,
  eventId: string,
  reminderId: string,
  token: string
): admin.messaging.Message {

  const title = reminder.title || `Event Reminder: ${event.title}`;
  const body = reminder.message || `Your event "${event.title}" starts tomorrow! Don't forget to attend.`;

  // 生成 deep link
  const deepLink = generateEventDeepLink(eventId);

  return {
    notification: {
      title: title,
      body: body,
    },
    data: {
      type: 'event_reminder',
      eventId: eventId,
      reminderId: reminderId,
      userId: userId,
      registrationId: reminder.registrationId,
      deep_link: deepLink,
      click_action: 'FLUTTER_NOTIFICATION_CLICK'
    },
    token: token
  };
}

/**
 * 生成事件的 Deep Link URL
 * 格式: saveearth://event/{eventId}
 */
function generateEventDeepLink(eventId: string): string {
  const appScheme = 'saveearth'; // 与 Flutter 代码中的 _appScheme 保持一致
  const deepLinkHost = 'event'; // 与 Flutter 代码中的 _deepLinkHost 保持一致
  return `${appScheme}://${deepLinkHost}/${eventId}`;
}

async function handleSendResult(
  results: Array<{ success: boolean; token: string; response?: any; error?: string }>,
  userId: string,
  db: admin.firestore.Firestore,
  reminderDoc: admin.firestore.QueryDocumentSnapshot
) {
  const failedTokens: string[] = [];
  let successCount = 0;

  results.forEach((result) => {
    if (!result.success) {
      failedTokens.push(result.token);
      console.log(`Failed to send to token: ${result.token.substring(0, 20)}..., error: ${result.error}`);
    } else {
      successCount++;
    }
  });

  // 移除失败的 tokens
  if (failedTokens.length > 0) {
    try {
      await db.collection('users').doc(userId).update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...failedTokens)
      });
      console.log(`Removed ${failedTokens.length} invalid tokens for user ${userId}`);
    } catch (error: any) {
      console.error('Error removing invalid tokens:', error);
    }
  }

  // 更新提醒状态
  if (successCount > 0) {
    await reminderDoc.ref.update({
      isSent: true,
      sentAt: admin.firestore.FieldValue.serverTimestamp() // 可选：记录发送时间
    });
    console.log(`Reminder sent successfully to ${successCount} devices`);
  } else {
    console.log('Reminder failed to send to any device');
    await reminderDoc.ref.update({
      isSent: true,
      sendFailed: true // 可选：标记发送失败
    });
  }
}