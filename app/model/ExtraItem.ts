import type { ContactVariable } from '@/model/ContractVariable';

export interface ExtraItem {
  id?: string;
  contractVariable: string | null | ContactVariable;
  materialNetPrice?: number;
  workNetPrice?: number;
  quantity: number | null;
}
