import type { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import axios from 'axios';

// Generikus API service osztály.
export class ApiService {
  private axiosInstance: AxiosInstance;

  constructor() {
    this.axiosInstance = axios.create({
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }

  // GET kérés általános típustámogatással
  async get<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.axiosInstance.get(url, config);
    return response.data;
  }

  // POST kérés általános típustámogatással
  async post<T, U>(url: string, data: U, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.axiosInstance.post(url, data, config);
    return response.data;
  }

  // PUT kérés általános típustámogatással
  async put<T, U>(url: string, data: U, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.axiosInstance.put(url, data, config);
    return response.data;
  }

  // DELETE kérés általános típustámogatással
  async delete<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response: AxiosResponse<T> = await this.axiosInstance.delete(url, config);
    return response.data;
  }
}

// Példa: Egy UserService, amely az ApiService-t használja.
/*
interface User {
  id: number;
  name: string;
  email: string;
}

interface CreateUserDto {
  name: string;
  email: string;
}

export class UserService {
  private apiService: ApiService;

  constructor() {
    this.apiService = new ApiService();
  }

  async getUser(userId: number): Promise<User> {
    return this.apiService.get<User>(`/users/${userId}`);
  }

  async createUser(userData: CreateUserDto): Promise<User> {
    return this.apiService.post<User, CreateUserDto>('/users', userData);
  }
}
*/
