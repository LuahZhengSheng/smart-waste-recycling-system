/**
 * API 响应接口
 */
export interface ApiResponse {
  success: boolean;
  data?: any;
  error?: string;
  message?: string;
}

/**
 * 成功响应
 */
export function successResponse(data: any): ApiResponse {
  return {
    success: true,
    data,
  };
}

/**
 * 错误响应
 */
export function errorResponse(error: string, message?: string): ApiResponse {
  return {
    success: false,
    error,
    message,
  };
}
