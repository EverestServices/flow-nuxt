// Generikus API service osztály (axios nélkül, fetch-csel kompatibilis).
export class ApiService {
  private baseHeaders: HeadersInit = {
  };

  private async request<T>(url: string, init: RequestInit = {}): Promise<T> {
    const mergedHeaders: HeadersInit = {
      ...this.baseHeaders,
      ...(init.headers as HeadersInit | undefined),
    };
    const hasContentType =
      typeof mergedHeaders === 'object' &&
      mergedHeaders != null &&
      Object.keys(mergedHeaders as Record<string, string>).some(
        (k) => k.toLowerCase() === 'content-type',
      );
    const bodyIsFormData = typeof FormData !== 'undefined' && init.body instanceof FormData;
    const headersToSend =
      !hasContentType && init.body != null && !bodyIsFormData
        ? { ...mergedHeaders, 'Content-Type': 'application/json' }
        : mergedHeaders;
    const res = await fetch(url, {
      ...init,
      headers: headersToSend,
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
    const body =
      typeof FormData !== 'undefined' && (data as unknown) instanceof FormData
        ? (data as unknown as BodyInit)
        : data != null
        ? JSON.stringify(data)
        : undefined;
    return this.request<T>(url, {
      ...config,
      method: 'POST',
      body,
    });
  }

  // PUT kérés általános típustámogatással
  async put<T, U>(url: string, data: U, config?: RequestInit): Promise<T> {
    const body =
      typeof FormData !== 'undefined' && (data as unknown) instanceof FormData
        ? (data as unknown as BodyInit)
        : data != null
        ? JSON.stringify(data)
        : undefined;
    return this.request<T>(url, {
      ...config,
      method: 'PUT',
      body,
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
