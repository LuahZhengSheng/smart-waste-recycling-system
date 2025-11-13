import * as admin from 'firebase-admin';
import { NotificationPayload, SendResult, ReminderData } from '../types/reminderTypes';

// 延迟初始化 messaging
function getMessaging() {
  if (!admin.apps.length) {
    admin.initializeApp();
  }
  return admin.messaging();
}

/**
 * 创建事件提醒消息负载
 */
export function createReminderMessage(reminder: ReminderData): NotificationPayload {
  return {
    notification: {
      title: reminder.eventTitle ? `活动提醒: ${reminder.eventTitle}` : '活动提醒',
      body: `您的活动将于明天在 ${reminder.eventLocation || '活动场地'} 开始。记得参加！`,
    },
    data: {
      type: 'event_reminder',
      eventId: reminder.eventId || '',
      reminderId: reminder.registrationId || '',
      registrationId: reminder.registrationId || '',
      userId: reminder.userId,
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'event_reminders',
        sound: 'default',
        priority: 'high',
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
        },
      },
    },
  };
}

/**
 * 创建测试消息负载
 */
export function createTestMessage(userId: string): NotificationPayload {
  return {
    notification: {
      title: '测试通知',
      body: '这是一个测试活动提醒通知。',
    },
    data: {
      type: 'test_notification',
      userId: userId,
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'event_reminders',
        sound: 'default',
        priority: 'high',
      },
    },
  };
}

/**
 * 发送消息到单个 token
 */
export async function sendToToken(
  message: NotificationPayload,
  token: string
): Promise<SendResult> {
  try {
    const messaging = getMessaging();
    await messaging.send({
      ...message,
      token: token,
    } as admin.messaging.Message);

    console.log(`消息成功发送到 token: ${token.substring(0, 20)}...`);
    return { success: true, token };

  } catch (error: any) {
    console.error(`发送到 token ${token.substring(0, 20)} 失败:`, error.code);
    return { success: false, token, error: error.code };
  }
}

/**
 * 发送消息到多个 tokens
 */
export async function sendToMultipleTokens(
  message: NotificationPayload,
  tokens: string[]
): Promise<SendResult[]> {
  const sendPromises = tokens.map(token => sendToToken(message, token));
  return await Promise.all(sendPromises);
}

/**
 * 检查 token 是否无效
 */
export function isTokenInvalid(errorCode: string): boolean {
  return errorCode === 'messaging/invalid-registration-token' ||
         errorCode === 'messaging/registration-token-not-registered';
}