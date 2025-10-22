// Generikus API service osztály (axios nélkül, fetch-csel kompatibilis).
export class ApiService {
  private baseHeaders: HeadersInit = {
    'Content-Type': 'application/json',
  };

  private async request<T>(url: string, init: RequestInit = {}): Promise<T> {
    const res = await fetch(url, {
      ...init,
      headers: {
        ...this.baseHeaders,
        ...(init.headers as HeadersInit | undefined),
      },
    });
    if (!res.ok) {
      const text = await res.text().catch(() => '');
      throw new Error(`Request failed ${res.status}: ${text}`);
    }
    // Try parse JSON, otherwise cast empty as T
    try {
      return (await res.json()) as T;
    } catch {
      return (undefined as unknown) as T;
    }
  }

  // GET kérés általános típustámogatással
  async get<T>(url: string, config?: RequestInit): Promise<T> {
    return this.request<T>(url, { ...config, method: 'GET' });
  }

  // POST kérés általános típustámogatással
  async post<T, U>(url: string, data: U, config?: RequestInit): Promise<T> {
    return this.request<T>(url, {
      ...config,
      method: 'POST',
      body: data != null ? JSON.stringify(data) : undefined,
    });
  }

  // PUT kérés általános típustámogatással
  async put<T, U>(url: string, data: U, config?: RequestInit): Promise<T> {
    return this.request<T>(url, {
      ...config,
      method: 'PUT',
      body: data != null ? JSON.stringify(data) : undefined,
    });
  }

  // DELETE kérés általános típustámogatással
  async delete<T>(url: string, config?: RequestInit): Promise<T> {
    return this.request<T>(url, { ...config, method: 'DELETE' });
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
