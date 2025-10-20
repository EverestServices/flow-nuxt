export interface ContactVariable {
  id: string;
  type: string;
  name: string;
  belongsToImplementing: boolean;
  quantityUnit: string;
  materialNetPrice: number;
  workNetPrice: number;
  active: boolean;
}
