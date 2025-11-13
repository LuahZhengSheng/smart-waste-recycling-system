import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions/v2';

export const sendTestNotification = functions.https.onCall(async (request) => {
  // 检查用户认证
  if (!request.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to send test notifications'
    );
  }

  const userId = request.auth.uid;

  try {
    const db = admin.firestore();

    // 获取用户的 FCM tokens
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();
    const fcmTokens = userData?.fcmTokens || [];

    if (fcmTokens.length === 0) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'No FCM tokens found for user'
      );
    }

    // 使用第一个 token 发送测试通知
    const token = fcmTokens[0];
    const message = {
      notification: {
        title: 'Test Notification',
        body: 'This is a test notification from the event reminder system.',
      },
      data: {
        type: 'test_notification',
        userId: userId,
      },
      token: token
    };

    // 发送测试通知
    const response = await admin.messaging().send(message);

    console.log('Test notification sent successfully:', response);

    return {
      success: true,
      message: 'Test notification sent successfully',
      token: token.substring(0, 20) + '...'
    };

  } catch (error: any) {
    console.error('Error sending test notification:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});