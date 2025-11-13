import * as admin from "firebase-admin";

/**
 * 提醒数据接口
 */
export interface ReminderData {
  status: "pending" | "sent" | "failed" | "expired";
  remindAt: admin.firestore.Timestamp;
  userId: string;
  eventId?: string;
  eventTitle?: string;
  eventLocation?: string;
  registrationId?: string;
  isSent?: boolean;
  processedAt?: admin.firestore.Timestamp;
  statusMessage?: string;
}

/**
 * 用户数据接口
 */
export interface UserData {
  fcmTokens?: string[];
}

/**
 * 发送结果接口
 */
export interface SendResult {
  success: boolean;
  token: string;
  error?: string;
}

/**
 * 通知消息负载接口
 */
export interface NotificationPayload {
  notification: {
    title: string;
    body: string;
  };
  data: {
    type: string;
    eventId?: string;
    reminderId?: string;
    registrationId?: string;
    userId?: string;
    click_action?: string;
  };
  android?: {
    priority: "high" | "normal";
    notification: {
      channelId: string;
      sound: string;
      priority: "high" | "normal";
    };
  };
  apns?: {
    payload: {
      aps: {
        sound: string;
        badge: number;
      };
    };
  };
}
