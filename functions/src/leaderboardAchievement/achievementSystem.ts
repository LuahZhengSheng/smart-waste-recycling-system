// functions/src/leaderboardAchievement/achievementSystem.ts
import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

// 初始化 Firebase Admin（如果尚未初始化）
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// Achievement IDs mapping
const ACHIEVEMENT_IDS = {
  RECYCLING_COUNT: 'gJMMZiiArUFwkJ1zjJS8',
  POINTS_EARNED: 'Z3erDz62sB4ZSlW7gC8n',
  PLASTIC_WEIGHT: 'Z5pSRLu6NL6S5d6etYNB',
  PAPER_WEIGHT: 'W5TABDnkTwXD7wiKBCk0',
  METAL_WEIGHT: 'eQfiyDOmin3sJVA9y7Hi',
  GLASS_WEIGHT: '8Q4CNiDSfU1e4IZHKuSX',
  ELECTRONIC_WASTE_WEIGHT: '8mX8cTkrlpBPxC7o0rVM',
};

// Waste category to achievement mapping
const CATEGORY_TO_ACHIEVEMENT: { [key: string]: string } = {
  'tTHE1VeMmpOXNoIcianz': ACHIEVEMENT_IDS.PLASTIC_WEIGHT,
  '7uTfO9lWifYiqWW8nrpT': ACHIEVEMENT_IDS.PAPER_WEIGHT,
  'ewKPBhQdB9JDwkRfmTgT': ACHIEVEMENT_IDS.METAL_WEIGHT,
  'GBSpF5JLcutP0W5XiHX7': ACHIEVEMENT_IDS.GLASS_WEIGHT,
  'yiaCxMz5VsNuHruQbsK4': ACHIEVEMENT_IDS.ELECTRONIC_WASTE_WEIGHT,
};

interface RecyclingActivity {
  userId: string;
  wasteCategoryId: string;
  weight: number;
  pointsEarned: number;
  status: string;
}

interface UserAchievement {
  userId: string;
  achievementId: string;
  progress: number;
  currentLevel: number;
  updatedAt: admin.firestore.Timestamp;
}

interface AchievementLevel {
  level: number;
  unlockCriteria: number;
  title: string;
  description: string;
  badgeImage: string;
}

interface Achievement {
  achievementId: string;
  title: string;
  category: string;
  maxLevel: number;
  achievementLevels: AchievementLevel[];
}

/**
 * Cloud Function triggered when a new recycling activity is created
 * 使用 Firebase Functions v2 语法
 */
export const onRecyclingActivityCreated = functions.firestore.onDocumentCreated(
  'recyclingActivities/{activityId}',
  async (event) => {
    try {
      if (!event.data) {
        console.log('No event data found');
        return;
      }

      const snapshot = event.data;
      const activityData = snapshot.data();

      if (!activityData) {
        console.log('No activity data found');
        return;
      }

      const activity = activityData as RecyclingActivity;

      // Only process completed activities
      if (activity.status !== 'completed') {
        console.log('Activity not completed, skipping achievement update');
        return;
      }

      console.log('Processing new activity for user:', activity.userId);

      // 使用增量更新而不是重新统计
      await Promise.all([
        incrementRecyclingCountAchievement(activity.userId),
        incrementPointsEarnedAchievement(activity.userId, activity.pointsEarned),
        incrementWasteCategoryAchievement(activity.userId, activity.wasteCategoryId, activity.weight),
      ]);

      console.log('Successfully updated achievements for user:', activity.userId);
      return;
    } catch (error) {
      console.error('Error processing achievement updates:', error);
      throw error;
    }
  }
);

/**
 * 增量更新回收次数成就
 */
async function incrementRecyclingCountAchievement(userId: string): Promise<void> {
  try {
    // 获取当前用户成就
    const userAchievement = await getUserAchievement(userId, ACHIEVEMENT_IDS.RECYCLING_COUNT);
    const currentProgress = userAchievement?.progress || 0;
    const currentLevel = userAchievement?.currentLevel || 0;

    // 增量更新：回收次数 +1
    const newProgress = currentProgress + 1;

    console.log(`User ${userId} recycling count: ${currentProgress} -> ${newProgress}`);

    // 更新用户成就并检查等级提升
    await updateUserAchievementWithIncrement(
      userId,
      ACHIEVEMENT_IDS.RECYCLING_COUNT,
      newProgress,
      currentLevel
    );
  } catch (error) {
    console.error('Error incrementing recycling count achievement:', error);
    throw error;
  }
}

/**
 * 增量更新积分成就
 */
async function incrementPointsEarnedAchievement(userId: string, newPoints: number): Promise<void> {
  try {
    // 获取当前用户成就
    const userAchievement = await getUserAchievement(userId, ACHIEVEMENT_IDS.POINTS_EARNED);
    const currentProgress = userAchievement?.progress || 0;
    const currentLevel = userAchievement?.currentLevel || 0;

    // 增量更新：当前积分 + 新积分
    const newProgress = currentProgress + newPoints;

    console.log(`User ${userId} points: ${currentProgress} -> ${newProgress} (+${newPoints})`);

    // 更新用户成就并检查等级提升
    await updateUserAchievementWithIncrement(
      userId,
      ACHIEVEMENT_IDS.POINTS_EARNED,
      newProgress,
      currentLevel
    );
  } catch (error) {
    console.error('Error incrementing points earned achievement:', error);
    throw error;
  }
}

/**
 * 增量更新废物分类重量成就
 */
async function incrementWasteCategoryAchievement(
  userId: string,
  wasteCategoryId: string,
  weight: number
): Promise<void> {
  try {
    // 根据废物分类ID获取对应的成就ID
    const achievementId = CATEGORY_TO_ACHIEVEMENT[wasteCategoryId];

    if (!achievementId) {
      console.log(`No achievement mapping for category: ${wasteCategoryId}`);
      return;
    }

    // 获取当前用户成就
    const userAchievement = await getUserAchievement(userId, achievementId);
    const currentProgress = userAchievement?.progress || 0;
    const currentLevel = userAchievement?.currentLevel || 0;

    // 重量取整数（向下取整）
    const weightIncrement = Math.floor(weight); // 2.6kg -> 2kg
    const newProgress = currentProgress + weightIncrement;

    console.log(`User ${userId} ${achievementId} weight: ${currentProgress}kg -> ${newProgress}kg (+${weightIncrement}kg)`);

    // 更新用户成就并检查等级提升
    await updateUserAchievementWithIncrement(
      userId,
      achievementId,
      newProgress,
      currentLevel
    );
  } catch (error) {
    console.error('Error incrementing waste category achievement:', error);
    throw error;
  }
}

/**
 * 获取用户成就
 */
async function getUserAchievement(
  userId: string,
  achievementId: string
): Promise<UserAchievement | null> {
  try {
    const userAchievementQuery = await db
      .collection('userAchievements')
      .where('userId', '==', userId)
      .where('achievementId', '==', achievementId)
      .limit(1)
      .get();

    if (userAchievementQuery.empty) {
      return null;
    }

    return userAchievementQuery.docs[0].data() as UserAchievement;
  } catch (error) {
    console.error('Error getting user achievement:', error);
    return null;
  }
}

/**
 * 增量更新用户成就并检查等级提升
 */
async function updateUserAchievementWithIncrement(
  userId: string,
  achievementId: string,
  newProgress: number,
  currentLevel: number
): Promise<void> {
  try {
    // 获取成就详情和等级信息
    const { achievement, levels } = await getAchievementWithLevels(achievementId);

    if (!achievement) {
      console.error(`Achievement ${achievementId} not found`);
      return;
    }

    // 检查是否是最大等级
    if (currentLevel >= achievement.maxLevel) {
      console.log(`User ${userId} already at max level (${currentLevel}) for ${achievementId}, only updating progress`);

      // 只更新进度，不检查等级提升
      await updateUserAchievementProgress(userId, achievementId, newProgress);
      return;
    }

    // 计算新等级
    const newLevel = calculateLevel(newProgress, levels, currentLevel, achievement.maxLevel);

    if (newLevel > currentLevel) {
      console.log(`Level up! User ${userId} progressed from level ${currentLevel} to ${newLevel} in ${achievementId}`);

      // 更新进度和等级
      await updateUserAchievementWithLevel(
        userId,
        achievementId,
        newProgress,
        newLevel
      );

      // 发送等级提升通知
      await sendLevelUpNotification(userId, achievement, newLevel, levels);
    } else {
      // 只更新进度
      await updateUserAchievementProgress(userId, achievementId, newProgress);
    }
  } catch (error) {
    console.error('Error updating user achievement with increment:', error);
    throw error;
  }
}

/**
 * 获取成就详情和等级列表
 */
async function getAchievementWithLevels(
  achievementId: string
): Promise<{ achievement: Achievement | null; levels: AchievementLevel[] }> {
  try {
    // 获取成就详情
    const achievementDoc = await db.collection('achievements').doc(achievementId).get();

    if (!achievementDoc.exists) {
      return { achievement: null, levels: [] };
    }

    const achievementData = achievementDoc.data();
    if (!achievementData) {
      return { achievement: null, levels: [] };
    }

    const achievement: Achievement = {
      achievementId: achievementDoc.id,
      title: achievementData.title || '',
      category: achievementData.category || '',
      maxLevel: achievementData.maxLevel || 0,
      achievementLevels: []
    };

    // 获取成就等级
    const levelsSnapshot = await db
      .collection('achievements')
      .doc(achievementId)
      .collection('achievementLevels')
      .orderBy('level')
      .get();

    const levels: AchievementLevel[] = [];
    levelsSnapshot.forEach(doc => {
      const levelData = doc.data();
      levels.push({
        level: levelData.level || 0,
        unlockCriteria: levelData.unlockCriteria || 0,
        title: levelData.title || '',
        description: levelData.description || '',
        badgeImage: levelData.badgeImage || ''
      });
    });

    return { achievement, levels };
  } catch (error) {
    console.error('Error getting achievement with levels:', error);
    return { achievement: null, levels: [] };
  }
}

/**
 * 只更新用户成就进度（不改变等级）
 */
async function updateUserAchievementProgress(
  userId: string,
  achievementId: string,
  progress: number
): Promise<void> {
  try {
    const userAchievementQuery = await db
      .collection('userAchievements')
      .where('userId', '==', userId)
      .where('achievementId', '==', achievementId)
      .limit(1)
      .get();

    if (userAchievementQuery.empty) {
      // 创建新的用户成就
      const userAchievementRef = db.collection('userAchievements').doc();
      await userAchievementRef.set({
        userId,
        achievementId,
        progress,
        currentLevel: 0,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      // 更新现有用户成就
      const userAchievementRef = userAchievementQuery.docs[0].ref;
      await userAchievementRef.update({
        progress,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  } catch (error) {
    console.error('Error updating user achievement progress:', error);
    throw error;
  }
}

/**
 * 更新用户成就进度和等级
 */
async function updateUserAchievementWithLevel(
  userId: string,
  achievementId: string,
  progress: number,
  level: number
): Promise<void> {
  try {
    const userAchievementQuery = await db
      .collection('userAchievements')
      .where('userId', '==', userId)
      .where('achievementId', '==', achievementId)
      .limit(1)
      .get();

    if (userAchievementQuery.empty) {
      // 创建新的用户成就
      const userAchievementRef = db.collection('userAchievements').doc();
      await userAchievementRef.set({
        userId,
        achievementId,
        progress,
        currentLevel: level,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      // 更新现有用户成就
      const userAchievementRef = userAchievementQuery.docs[0].ref;
      await userAchievementRef.update({
        progress,
        currentLevel: level,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  } catch (error) {
    console.error('Error updating user achievement with level:', error);
    throw error;
  }
}

/**
 * 计算新等级基于进度
 */
function calculateLevel(
  progress: number,
  levels: AchievementLevel[],
  currentLevel: number,
  maxLevel: number
): number {
  let newLevel = currentLevel;

  // 检查每个等级是否达到解锁条件
  for (let i = currentLevel; i < levels.length; i++) {
    const level = levels[i];

    if (progress >= level.unlockCriteria) {
      newLevel = level.level;
    } else {
      break;
    }
  }

  // 不超过最大等级
  return Math.min(newLevel, maxLevel);
}

/**
 * 发送等级提升通知
 */
async function sendLevelUpNotification(
  userId: string,
  achievement: Achievement,
  newLevel: number,
  levels: AchievementLevel[]
): Promise<void> {
  try {
    const level = levels.find(l => l.level === newLevel);

    if (!level) {
      console.error(`Level ${newLevel} not found in achievement levels`);
      return;
    }

    // 获取用户 FCM token
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();

    if (!userData || !userData.fcmToken) {
      console.log(`No FCM token for user ${userId}`);
      return;
    }

    // 发送通知
    const message = {
      notification: {
        title: '🎉 Achievement Level Up!',
        body: `You've reached ${level.title} in ${achievement.title}!`,
      },
      data: {
        type: 'achievement_level_up',
        achievementId: achievement.achievementId,
        level: newLevel.toString(),
      },
      token: userData.fcmToken,
    };

    await admin.messaging().send(message);
    console.log(`Sent level up notification to user ${userId}`);
  } catch (error) {
    console.error('Error sending notification:', error);
    // 通知失败不应中断整个流程
  }
}

/**
 * 批量更新所有用户成就（用于数据迁移或修复）
 */
export const batchUpdateUserAchievements = functions.https.onCall(
  {
    timeoutSeconds: 300,
    memory: '1GiB',
  },
  async (request) => {
    // 确保用户已认证
    if (!request.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const userId = request.data.userId;

    if (!userId) {
      throw new functions.https.HttpsError('invalid-argument', 'userId is required');
    }

    try {
      // 重新计算所有成就（用于修复数据）
      const activitiesSnapshot = await db
        .collection('recyclingActivities')
        .where('userId', '==', userId)
        .where('status', '==', 'completed')
        .get();

      let totalActivities = 0;
      let totalPoints = 0;
      const categoryWeights: { [key: string]: number } = {};

      // 一次性统计所有数据
      activitiesSnapshot.forEach(doc => {
        const activityData = doc.data();
        const activity = activityData as RecyclingActivity;

        totalActivities += 1;
        totalPoints += activity.pointsEarned;

        const categoryId = activity.wasteCategoryId;
        if (!categoryWeights[categoryId]) {
          categoryWeights[categoryId] = 0;
        }
        categoryWeights[categoryId] += Math.floor(activity.weight); // 重量取整
      });

      // 批量更新所有成就
      await Promise.all([
        updateUserAchievementWithIncrement(userId, ACHIEVEMENT_IDS.RECYCLING_COUNT, totalActivities, 0),
        updateUserAchievementWithIncrement(userId, ACHIEVEMENT_IDS.POINTS_EARNED, totalPoints, 0),
        ...Object.entries(categoryWeights).map(([categoryId, weight]) =>
          updateUserAchievementWithIncrement(
            userId,
            CATEGORY_TO_ACHIEVEMENT[categoryId],
            weight,
            0
          )
        ),
      ]);

      return { success: true, message: 'Achievements updated successfully' };
    } catch (error) {
      console.error('Error in batch update:', error);
      throw new functions.https.HttpsError('internal', 'Failed to update achievements');
    }
  }
);