import { ApiService as RealApiService } from './ApiService';
import { MockApiService } from './MockApiService';

const useMock = import.meta.env.VITE_USE_MOCK === 'true';

export const api = useMock ? new MockApiService() : new RealApiService();
