import type { AxiosRequestConfig } from 'axios';
import { mockRequest } from '@/mock/index';

export class MockApiService {
  async get<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return mockRequest('GET', url, undefined, config);
  }

  async post<T, U>(url: string, data: U, config?: AxiosRequestConfig): Promise<T> {
    return mockRequest('POST', url, data, config);
  }

  async put<T, U>(url: string, data: U, config?: AxiosRequestConfig): Promise<T> {
    return mockRequest('PUT', url, data, config);
  }

  async delete<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return mockRequest('DELETE', url, undefined, config);
  }
}
