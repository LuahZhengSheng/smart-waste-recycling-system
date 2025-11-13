import * as admin from 'firebase-admin';
import { UserData } from '../types/reminderTypes';

// 延迟初始化，只在需要时创建 db 实例
function getDb() {
  if (!admin.apps.length) {
    admin.initializeApp();
  }
  return admin.firestore();
}

/**
 * 更新提醒状态
 */
export async function updateReminderStatus(
  reminderId: string,
  status: string,
  message: string = ''
): Promise<void> {
  try {
    const db = getDb();
    await db.collection('scheduledReminders').doc(reminderId).update({
      status: status,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
      statusMessage: message,
    });
    console.log(`提醒 ${reminderId} 状态更新为: ${status}`);
  } catch (error: any) {
    console.error(`更新提醒 ${reminderId} 状态时出错:`, error);
    throw error;
  }
}

/**
 * 从用户文档中移除无效的 FCM token
 */
export async function removeInvalidToken(userId: string, token: string): Promise<void> {
  try {
    const db = getDb();
    await db.collection('users').doc(userId).update({
      fcmTokens: admin.firestore.FieldValue.arrayRemove(token),
    });
    console.log(`已从用户 ${userId} 移除无效 token`);
  } catch (error: any) {
    console.error(`移除无效 token 时出错:`, error);
    throw error;
  }
}

/**
 * 获取用户的 FCM tokens
 */
export async function getUserFcmTokens(userId: string): Promise<string[]> {
  try {
    const db = getDb();
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw new Error(`用户 ${userId} 不存在`);
    }

    const userData = userDoc.data() as UserData;
    return userData.fcmTokens || [];
  } catch (error: any) {
    console.error(`获取用户 ${userId} 的 FCM tokens 时出错:`, error);
    throw error;
  }
}

/**
 * 获取待处理的提醒
 */
export async function getPendingReminders(limit: number = 100) {
  const db = getDb();
  const now = admin.firestore.Timestamp.now();

  return await db
    .collection('scheduledReminders')
    .where('status', '==', 'pending')
    .where('remindAt', '<=', now)
    .limit(limit)
    .get();
}

/**
 * 清理旧的已处理提醒
 */
export async function cleanupOldReminders(daysOld: number = 7, limit: number = 500) {
  const db = getDb();
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - daysOld);
  const cutoffTimestamp = admin.firestore.Timestamp.fromDate(cutoffDate);

  const oldRemindersSnapshot = await db
    .collection('scheduledReminders')
    .where('status', 'in', ['sent', 'failed'])
    .where('processedAt', '<=', cutoffTimestamp)
    .limit(limit)
    .get();

  const batch = db.batch();
  oldRemindersSnapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  await batch.commit();
  return oldRemindersSnapshot.size;
}