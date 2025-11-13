import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {initializeApp} from "firebase-admin/app";
import {onRequest} from "firebase-functions/v2/https";

initializeApp();
const db = getFirestore();

export enum Role {
  USER = "user",
  COMMUNITY_MANAGER = "community_manager",
  EVENT_MANAGER = "event_manager",
  REWARD_MANAGER = "reward_manager",
  ADMIN = "admin",
  RECYCLING_CENTER_STAFF = "recycling_center_staff",
}

// Alternative approach using HTTP function
export const createUserProfile = onRequest(async (req, res) => {
  try {
    const {uid, displayName, email, phoneNumber, photoURL} = req.body;

    if (!uid) {
      res.status(400).json({error: "User ID is required"});
      return;
    }

    const assignedRole = Role.USER;

    const userProfile = {
      userId: uid,
      username: displayName || "",
      email: email || "",
      phoneNo: phoneNumber || "",
      profileImage: photoURL || "",
      role: assignedRole,
      isActive: true,
      isVerified: false,
      joinDate: FieldValue.serverTimestamp(),
      loginAttemptCount: 0,
      notifications: [],
      userAchievements: [],
      rewardPoint: 0,
    };

    await db.collection("Users").doc(uid).set(userProfile);

    console.log(
      `✅ Created profile for user: ${uid} with role: ${assignedRole}`,
    );

    res.status(200).json({
      success: true,
      message: "User profile created successfully",
    });
  } catch (error) {
    console.error("❌ Error creating user profile:", error);
    res.status(500).json({error: "Internal server error"});
  }
});


// import {onCall, HttpsError} from "firebase-functions/v2/https";
// import {onDocumentCreated} from "firebase-functions/v2/firestore";
// import {getAuth} from "firebase-admin/auth";
// import {getFirestore, FieldValue} from "firebase-admin/firestore";
// import {initializeApp} from "firebase-admin/app";
//
// // Initialize Firebase Admin
// initializeApp();
//
// // 定义所有角色
// export enum Role {
//   USER = "user",
//   COMMUNITY_MANAGER = "community_manager",
//   EVENT_MANAGER = "event_manager",
//   REWARD_MANAGER = "reward_manager",
//   ADMIN = "admin",
//   RECYCLING_CENTER_STAFF = "recycling_center_staff"
// }
//
// // 定义所有页面/屏幕
// export enum Page {
//   // Mobile App User Pages
//   USER_HOME = "user_home",
//   USER_PROFILE = "user_profile",
//   USER_REWARDS = "user_rewards",
//   USER_EVENTS = "user_events",
//   USER_COMMUNITY = "user_community",
//   USER_RECYCLING_HISTORY = "user_recycling_history",
//
//   // Admin Web Pages
//   ADMIN_DASHBOARD = "admin_dashboard",
//   COMMUNITY_MANAGEMENT = "community_management",
//   EVENT_MANAGEMENT = "event_management",
//   REWARD_MANAGEMENT = "reward_management",
//   ACHIEVEMENT_MANAGEMENT = "achievement_management",
//   USER_MANAGEMENT = "user_management",
//   MANAGER_MANAGEMENT = "manager_management",
//   ANALYTICS_DASHBOARD = "analytics_dashboard",
//   SYSTEM_SETTINGS = "system_settings",
//
//   // Recycling Center Pages
//   RECYCLING_DASHBOARD = "recycling_dashboard",
//   RECYCLING_VERIFICATION = "recycling_verification",
//   RECYCLING_REPORTS = "recycling_reports",
//   RECYCLING_INVENTORY = "recycling_inventory"
// }
//
// // 角色页面访问权限映射
// const ROLE_PAGE_ACCESS: Record<Role, Page[]> = {
//   [Role.USER]: [
//     Page.USER_HOME,
//     Page.USER_PROFILE,
//     Page.USER_REWARDS,
//     Page.USER_EVENTS,
//     Page.USER_COMMUNITY,
//     Page.USER_RECYCLING_HISTORY,
//   ],
//   [Role.COMMUNITY_MANAGER]: [
//     Page.ADMIN_DASHBOARD,
//     Page.COMMUNITY_MANAGEMENT,
//     Page.ANALYTICS_DASHBOARD,
//   ],
//   [Role.EVENT_MANAGER]: [
//     Page.ADMIN_DASHBOARD,
//     Page.EVENT_MANAGEMENT,
//     Page.ANALYTICS_DASHBOARD,
//   ],
//   [Role.REWARD_MANAGER]: [
//     Page.ADMIN_DASHBOARD,
//     Page.REWARD_MANAGEMENT,
//     Page.ANALYTICS_DASHBOARD,
//   ],
//   [Role.ADMIN]: [
//     Page.ADMIN_DASHBOARD,
//     Page.COMMUNITY_MANAGEMENT,
//     Page.EVENT_MANAGEMENT,
//     Page.REWARD_MANAGEMENT,
//     Page.ACHIEVEMENT_MANAGEMENT,
//     Page.USER_MANAGEMENT,
//     Page.MANAGER_MANAGEMENT,
//     Page.ANALYTICS_DASHBOARD,
//     Page.SYSTEM_SETTINGS,
//   ],
//   [Role.RECYCLING_CENTER_STAFF]: [
//     Page.RECYCLING_DASHBOARD,
//     Page.RECYCLING_VERIFICATION,
//     Page.RECYCLING_REPORTS,
//     Page.RECYCLING_INVENTORY,
//   ],
// };
//
// // 用户接口定义
// interface UserProfile {
//   uid: string;
//   email: string;
//   role: Role;
//   accessiblePages: Page[];
//   createdAt: Date;
//   updatedAt: Date;
//   isActive: boolean;
//   recyclingCenterId?: string; // 只有回收中心员工需要
// }
//
// // 页面访问统计接口
// interface PageAccessStats {
//   totalUsers: number;
//   roleBreakdown: Record<string, number>;
// }
//
// /**
//  * 分配用户角色的云函数
//  * @param {object} request - 包含调用者和目标用户信息的请求对象
//  * @return {Promise<object>} 分配结果
//  */
// export const assignRole = onCall(async (request) => {
//   const {uid, targetUserId, newRole, recyclingCenterId} = request.data;
//
//   try {
//     // 验证调用者身份
//     const callerProfile = await getUserProfile(uid);
//     if (!callerProfile) {
//       throw new HttpsError("not-found", "调用者不存在");
//     }
//
//     // 检查调用者是否有权限分配角色
//     if (!canAccessPage(callerProfile, Page.MANAGER_MANAGEMENT) &&
//         !canAccessPage(callerProfile, Page.USER_MANAGEMENT)) {
//       throw new HttpsError("permission-denied", "没有权限分配角色");
//     }
//
//     // 验证新角色是否有效
//     if (!Object.values(Role).includes(newRole)) {
//       throw new HttpsError("invalid-argument", "无效的角色");
//     }
//
//     // 如果是回收中心员工，必须提供回收中心ID
//     if (newRole === Role.RECYCLING_CENTER_STAFF && !recyclingCenterId) {
//       throw new HttpsError(
//         "invalid-argument",
//         "回收中心员工必须指定回收中心ID"
//       );
//     }
//
//     // 获取目标用户
//     const targetUser = await getAuth().getUser(targetUserId);
//     if (!targetUser) {
//       throw new HttpsError("not-found", "目标用户不存在");
//     }
//
//     // 更新用户角色
//     const db = getFirestore();
//     const userRef = db.collection("users").doc(targetUserId);
//
//     const accessiblePages = ROLE_PAGE_ACCESS[newRole as Role];
//
//     const updateData: {
//       uid: string;
//       email: string | undefined;
//       role: Role;
//       accessiblePages: Page[];
//       updatedAt: FirebaseFirestore.FieldValue;
//       isActive: boolean;
//       recyclingCenterId?: string;
//     } = {
//       uid: targetUserId,
//       email: targetUser.email,
//       role: newRole as Role,
//       accessiblePages,
//       updatedAt: FieldValue.serverTimestamp(),
//       isActive: true,
//     };
//
//     // 如果是回收中心员工，添加回收中心ID
//     if (newRole === Role.RECYCLING_CENTER_STAFF && recyclingCenterId) {
//       updateData.recyclingCenterId = recyclingCenterId;
//     }
//
//     await userRef.set(updateData, {merge: true});
//
//     // 更新 Firebase Auth 自定义声明
//     const customClaims: {
//       role: Role;
//       accessiblePages: Page[];
//       recyclingCenterId?: string;
//     } = {
//       role: newRole as Role,
//       accessiblePages,
//     };
//
//     if (newRole === Role.RECYCLING_CENTER_STAFF && recyclingCenterId) {
//       customClaims.recyclingCenterId = recyclingCenterId;
//     }
//
//     await getAuth().setCustomUserClaims(targetUserId, customClaims);
//
//     // 记录操作日志
//     await logRoleAssignment(uid, targetUserId, newRole, callerProfile.role);
//
//     return {
//       success: true,
//       message: `成功将角色分配给用户 ${targetUser.email}`,
//       user: {
//         uid: targetUserId,
//         email: targetUser.email,
//         role: newRole,
//         accessiblePages,
//         recyclingCenterId: newRole === Role.RECYCLING_CENTER_STAFF ?
//           recyclingCenterId : undefined,
//       },
//     };
//   } catch (error) {
//     console.error("分配角色时出错:", error);
//     if (error instanceof HttpsError) {
//       throw error;
//     }
//     throw new HttpsError("internal", "分配角色时发生内部错误");
//   }
// });
//
// /**
//  * 获取用户可访问页面的云函数
//  * @param {object} request - 包含用户ID的请求对象
//  * @return {Promise<object>} 用户可访问的页面列表
//  */
// export const getUserAccessiblePages = onCall(async (request) => {
//   const {uid} = request.data;
//
//   try {
//     const userProfile = await getUserProfile(uid);
//     if (!userProfile) {
//       throw new HttpsError("not-found", "用户不存在");
//     }
//
//     if (!userProfile.isActive) {
//       throw new HttpsError("permission-denied", "用户账户已被停用");
//     }
//
//     return {
//       uid: userProfile.uid,
//       role: userProfile.role,
//       accessiblePages: userProfile.accessiblePages,
//       recyclingCenterId: userProfile.recyclingCenterId,
//       isActive: userProfile.isActive,
//     };
//   } catch (error) {
//     console.error("获取用户可访问页面时出错:", error);
//     if (error instanceof HttpsError) {
//       throw error;
//     }
//     throw new HttpsError("internal", "获取用户可访问页面时发生内部错误");
//   }
// });
//
// /**
//  * 验证页面访问权限的云函数
//  * @param {object} request - 包含用户ID和页面名称的请求对象
//  * @return {Promise<object>} 访问权限验证结果
//  */
// export const verifyPageAccess = onCall(async (request) => {
//   const {uid, pageName} = request.data;
//
//   try {
//     const userProfile = await getUserProfile(uid);
//     if (!userProfile) {
//       throw new HttpsError("not-found", "用户不存在");
//     }
//
//     if (!userProfile.isActive) {
//       throw new HttpsError("permission-denied", "用户账户已被停用");
//     }
//
//     const hasAccess = canAccessPage(userProfile, pageName);
//
//     return {
//       hasAccess,
//       userRole: userProfile.role,
//       accessiblePages: userProfile.accessiblePages,
//       deniedReason: hasAccess ? null : "用户没有访问此页面的权限",
//     };
//   } catch (error) {
//     console.error("验证页面访问权限时出错:", error);
//     if (error instanceof HttpsError) {
//       throw error;
//     }
//     throw new HttpsError("internal", "验证页面访问权限时发生内部错误");
//   }
// });
//
// /**
//  * 获取特定角色的所有用户的云函数
//  * @param {object} request - 包含调用者ID和目标角色的请求对象
//  * @return {Promise<object>} 用户列表
//  */
// export const getUsersByRole = onCall(async (request) => {
//   const {uid, targetRole} = request.data;
//
//   try {
//     const callerProfile = await getUserProfile(uid);
//     if (!callerProfile) {
//       throw new HttpsError("not-found", "调用者不存在");
//     }
//
//     // 检查调用者是否有权限查看用户列表
//     if (!canAccessPage(callerProfile, Page.USER_MANAGEMENT) &&
//         !canAccessPage(callerProfile, Page.MANAGER_MANAGEMENT)) {
//       throw new HttpsError("permission-denied", "没有权限查看用户列表");
//     }
//
//     const db = getFirestore();
//     let query = db.collection("users").where("isActive", "==", true);
//
//     // 如果指定了角色，则按角色筛选
//     if (targetRole) {
//       query = query.where("role", "==", targetRole);
//     }
//
//     const usersSnapshot = await query.get();
//
//     const users = usersSnapshot.docs.map((doc) => {
//       const userData = doc.data();
//       return {
//         uid: doc.id,
//         email: userData.email,
//         role: userData.role,
//         accessiblePages: userData.accessiblePages,
//         recyclingCenterId: userData.recyclingCenterId,
//         createdAt: userData.createdAt,
//         updatedAt: userData.updatedAt,
//         isActive: userData.isActive,
//       };
//     });
//
//     return {users, count: users.length};
//   } catch (error) {
//     console.error("获取用户列表时出错:", error);
//     if (error instanceof HttpsError) {
//       throw error;
//     }
//     throw new HttpsError("internal", "获取用户列表时发生内部错误");
//   }
// });
//
// /**
//  * 获取所有管理员角色用户的云函数
//  * @param {object} request - 包含调用者ID的请求对象
//  * @return {Promise<object>} 管理员列表
//  */
// export const getAdminUsers = onCall(async (request) => {
//   const {uid} = request.data;
//
//   try {
//     const callerProfile = await getUserProfile(uid);
//     if (!callerProfile) {
//       throw new HttpsError("not-found", "调用者不存在");
//     }
//
//     // 只有 admin 可以查看所有管理员
//     if (!canAccessPage(callerProfile, Page.MANAGER_MANAGEMENT)) {
//       throw new HttpsError("permission-denied", "没有权限查看管理员列表");
//     }
//
//     const db = getFirestore();
//     const managersSnapshot = await db.collection("users")
//       .where("role", "in", [
//         Role.COMMUNITY_MANAGER,
//         Role.EVENT_MANAGER,
//         Role.REWARD_MANAGER,
//         Role.ADMIN,
//       ])
//       .where("isActive", "==", true)
//       .get();
//
//     const managers = managersSnapshot.docs.map((doc) => {
//       const userData = doc.data();
//       return {
//         uid: doc.id,
//         email: userData.email,
//         role: userData.role,
//         accessiblePages: userData.accessiblePages,
//         createdAt: userData.createdAt,
//         updatedAt: userData.updatedAt,
//       };
//     });
//
//     return {managers, count: managers.length};
//   } catch (error) {
//     console.error("获取管理员列表时出错:", error);
//     if (error instanceof HttpsError) {
//       throw error;
//     }
//     throw new HttpsError("internal", "获取管理员列表时发生内部错误");
//   }
// });
//
// /**
//  * 停用/启用用户的云函数
//  * @param {object} request - 包含调用者ID、目标用户ID和状态的请求对象
//  * @return {Promise<object>} 操作结果
//  */
// export const toggleUserStatus = onCall(async (request) => {
//   const {uid, targetUserId, isActive} = request.data;
//
//   try {
//     const callerProfile = await getUserProfile(uid);
//     if (!callerProfile) {
//       throw new HttpsError("not-found", "调用者不存在");
//     }
//
//     if (!canAccessPage(callerProfile, Page.USER_MANAGEMENT) &&
//         !canAccessPage(callerProfile, Page.MANAGER_MANAGEMENT)) {
//       throw new HttpsError("permission-denied", "没有权限修改用户状态");
//     }
//
//     const db = getFirestore();
//     await db.collection("users").doc(targetUserId).update({
//       isActive,
//       updatedAt: FieldValue.serverTimestamp(),
//     });
//
//     // 如果停用用户，清除其 Firebase Auth 自定义声明
//     if (!isActive) {
//       await getAuth().setCustomUserClaims(targetUserId, {});
//     } else {
//       // 如果启用用户，恢复其自定义声明
//       const userProfile = await getUserProfile(targetUserId);
//       if (userProfile) {
//         const customClaims: {
//           role: Role;
//           accessiblePages: Page[];
//           recyclingCenterId?: string;
//         } = {
//           role: userProfile.role,
//           accessiblePages: userProfile.accessiblePages,
//         };
//         if (userProfile.recyclingCenterId) {
//           customClaims.recyclingCenterId = userProfile.recyclingCenterId;
//         }
//         await getAuth().setCustomUserClaims(targetUserId, customClaims);
//       }
//     }
//
//     return {
//       success: true,
//       message: `用户已${isActive ? "启用" : "停用"}`,
//     };
//   } catch (error) {
//     console.error("修改用户状态时出错:", error);
//     if (error instanceof HttpsError) {
//       throw error;
//     }
//     throw new HttpsError("internal", "修改用户状态时发生内部错误");
//   }
// });
//
// /**
//  * 获取页面访问统计的云函数
//  * @param {object} request - 包含调用者ID的请求对象
//  * @return {Promise<object>} 页面访问统计数据
//  */
// export const getPageAccessStats = onCall(async (request) => {
//   const {uid} = request.data;
//
//   try {
//     const callerProfile = await getUserProfile(uid);
//     if (!callerProfile) {
//       throw new HttpsError("not-found", "调用者不存在");
//     }
//
//     // 只有 admin 可以查看访问统计
//     if (callerProfile.role !== Role.ADMIN) {
//       throw new HttpsError("permission-denied", "只有管理员可以查看访问统计");
//     }
//
//     const db = getFirestore();
//     const usersSnapshot = await db.collection("users")
//       .where("isActive", "==", true)
//       .get();
//
//     const stats: Record<string, PageAccessStats> = {};
//
//     // 统计每个页面的访问用户数
//     Object.values(Page).forEach((page) => {
//       stats[page] = {
//         totalUsers: 0,
//         roleBreakdown: {},
//       };
//     });
//
//     // 统计每个角色的用户数
//     const roleStats: Record<Role, number> = {
//       [Role.USER]: 0,
//       [Role.COMMUNITY_MANAGER]: 0,
//       [Role.EVENT_MANAGER]: 0,
//       [Role.REWARD_MANAGER]: 0,
//       [Role.ADMIN]: 0,
//       [Role.RECYCLING_CENTER_STAFF]: 0,
//     };
//
//     usersSnapshot.docs.forEach((doc) => {
//       const userData = doc.data();
//       const userRole = userData.role as Role;
//       const accessiblePages = userData.accessiblePages as Page[];
//
//       // 统计角色
//       roleStats[userRole]++;
//
//       // 统计页面访问
//       accessiblePages.forEach((page) => {
//         stats[page].totalUsers++;
//         if (!stats[page].roleBreakdown[userRole]) {
//           stats[page].roleBreakdown[userRole] = 0;
//         }
//         stats[page].roleBreakdown[userRole]++;
//       });
//     });
//
//     return {
//       pageStats: stats,
//       roleStats,
//       totalActiveUsers: usersSnapshot.docs.length,
//     };
//   } catch (error) {
//     console.error("获取页面访问统计时出错:", error);
//     if (error instanceof HttpsError) {
//       throw error;
//     }
//     throw new HttpsError("internal", "获取页面访问统计时发生内部错误");
//   }
// });
//
// /**
//  * 新用户创建时自动分配默认角色的触发器
//  */
// export const assignDefaultRoleOnUserCreate = onDocumentCreated(
//   "users/{userId}",
//   async (event) => {
//     const userId = event.params.userId;
//     const userData = event.data?.data();
//
//     try {
//       // 如果用户还没有角色，分配默认角色
//       if (!userData?.role) {
//         const db = getFirestore();
//         const accessiblePages = ROLE_PAGE_ACCESS[Role.USER];
//
//         await db.collection("users").doc(userId).update({
//           role: Role.USER,
//           accessiblePages,
//           updatedAt: FieldValue.serverTimestamp(),
//           isActive: true,
//         });
//
//         // 设置 Firebase Auth 自定义声明
//         await getAuth().setCustomUserClaims(userId, {
//           role: Role.USER,
//           accessiblePages,
//         });
//
//         console.log(`为用户 ${userId} 分配了默认角色: ${Role.USER}`);
//       }
//     } catch (error) {
//       console.error(`为用户 ${userId} 分配默认角色时出错:`, error);
//     }
//   }
// );
//
// /**
//  * 辅助函数：获取用户配置文件
//  * @param {string} uid - 用户ID
//  * @return {Promise<UserProfile | null>} 用户配置文件或null
//  */
// async function getUserProfile(uid: string): Promise<UserProfile | null> {
//   const db = getFirestore();
//   const userDoc = await db.collection("users").doc(uid).get();
//
//   if (!userDoc.exists) {
//     return null;
//   }
//
//   return userDoc.data() as UserProfile;
// }
//
// /**
//  * 辅助函数：检查用户是否可以访问特定页面
//  * @param {UserProfile} userProfile - 用户配置文件
//  * @param {Page} page - 页面
//  * @return {boolean} 是否有访问权限
//  */
// function canAccessPage(userProfile: UserProfile, page: Page): boolean {
//   return userProfile.accessiblePages.includes(page);
// }
//
// /**
//  * 辅助函数：记录角色分配日志
//  * @param {string} assignerId - 分配者ID
//  * @param {string} targetUserId - 目标用户ID
//  * @param {Role} newRole - 新角色
//  * @param {Role} assignerRole - 分配者角色
//  * @return {Promise<void>} Promise对象
//  */
// async function logRoleAssignment(
//   assignerId: string,
//   targetUserId: string,
//   newRole: Role,
//   assignerRole: Role
// ): Promise<void> {
//   const db = getFirestore();
//   await db.collection("role_assignment_logs").add({
//     assignerId,
//     targetUserId,
//     newRole,
//     assignerRole,
//     timestamp: FieldValue.serverTimestamp(),
//     action: "role_assigned",
//   });
// }
//
// // 导出角色和页面枚举供客户端使用
// export {Role as UserRole, Page as AppPage};
