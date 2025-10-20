<template>
  <div class="bg-base-100 p-4 rounded-xl shadow-inner mt-3 border border-base-300">
    <div class="">
      <h3 class="text-lg font-semibold mb-2 text-secondary">Extra tételek</h3>
      <div
        v-for="extraItem in extraItemsValue"
        :key="extraItem.id"
        class="relative mb-3 px-3 py-2 rounded-lg border border-base-300 bg-secondary/10"
      >
        <!-- Törlés gomb jobb felső sarokban, belül maradva -->
        <button
          class="absolute -top-2 -right-2 btn btn-sm btn-error btn-circle"
          @click="removeItem(extraItem)"
        >
          <X class="w-3.5 h-3.5" />
        </button>

        <!-- Cím külön sorban -->
        <div class="mb-1">
          <div class="font-semibold text-base text-secondary">
            {{ getExtraItemContractVariable(extraItem).name }}
          </div>
        </div>

        <!-- Input + egység -->
        <div class="form-control max-w-[7rem] w-full">
          <label class="input input-sm input-bordered flex items-center justify-between gap-2">
            <input
              type="number"
              v-model="extraItem.quantity"
              min="0"
              placeholder="0"
              required
              class="w-full"
            />
            <span
              class="text-sm border-l-1 pl-1.5 font-bold text-base-content/60 border-base-content/20"
            >
              {{ getExtraItemContractVariable(extraItem).quantityUnit }}
            </span>
          </label>
        </div>
      </div>
    </div>

    <div class="flex gap-2 flex-wrap mt-4">
      <button
        @click="selectContractVariable(contractVariable)"
        class="btn btn-secondary btn-sm"
        v-for="contractVariable in enabledContractVariables"
        :key="contractVariable.id"
      >
        {{ contractVariable.name }}
      </button>
    </div>
  </div>
</template>
<script lang="ts" setup>
import type { ContactVariable } from '@/model/ContractVariable';
import type { ExtraItem } from '@/model/ExtraItem';
import { computed, ref } from 'vue';
import { X } from 'lucide-vue-next';

const contractVariableSource =
  '[{"id":"15cf38e8-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Antenna leszerelés","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":25000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf39e8-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Antenna visszahelyezés","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":25000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3a17-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Klíma/hőszivattyú le-, és felszerelés","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":57150,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3a3a-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Eresz eltávolítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":10000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3ab7-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Parapetes kivezetők hosszabbítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":15000,"workNetPrice":25000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3ad3-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Gázcső, dobozolása/alászigetelése","belongsToImplementing":true,"quantityUnit":"m","materialNetPrice":1000,"workNetPrice":1000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3aee-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Légtechnikai kivezetés hosszabbítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":2000,"workNetPrice":2800,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3b0a-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Kőpárkány vésése/eltávolítása","belongsToImplementing":true,"quantityUnit":"m","materialNetPrice":null,"workNetPrice":5000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3b23-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Növényzet eltávolítása, tereprendezés","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":70000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3b42-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Állványozás","belongsToImplementing":true,"quantityUnit":"m2","materialNetPrice":null,"workNetPrice":3677,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3b5b-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Lábazat előkészítése","belongsToImplementing":true,"quantityUnit":"m2","materialNetPrice":12600,"workNetPrice":15000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3b73-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Homlokzati elemek bontása","belongsToImplementing":true,"quantityUnit":"m2","materialNetPrice":null,"workNetPrice":3050,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3b8a-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Korlát eltávolítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":134850,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3bbc-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Kerítés/kapu eltávolítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":134850,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3bee-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Előtető eltávolítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":7900,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3c1e-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Ablakrács eltávolítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":10000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3c4c-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Redőny eltávolítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":5000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3c80-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Elektromos szerelés","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":0,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}}]';
const contractVariables = ref<ContactVariable[]>(JSON.parse(contractVariableSource));
const selectedContractVariables = ref<ContactVariable[]>([]);
const extraItemsValue = ref<ExtraItem[]>([]);
const enabledContractVariables = computed(() => {
  return contractVariables.value.filter((cv) => !selectedContractVariables.value.includes(cv));
});
const selectContractVariable = (cv: ContactVariable) => {
  if (!selectedContractVariables.value.includes(cv)) {
    selectedContractVariables.value.push(cv);
    const newItem: ExtraItem = {
      contractVariable: cv,
      materialNetPrice: 0,
      workNetPrice: 0,
      quantity: null,
    };
    extraItemsValue.value.push(newItem);
  }
};
const removeItem = (extraItem: ExtraItem) => {
  const cv = getExtraItemContractVariable(extraItem);
  extraItemsValue.value = extraItemsValue.value.filter(
    (item) => getExtraItemContractVariable(item).id != cv.id,
  );
  selectedContractVariables.value = selectedContractVariables.value.filter(
    (item) => item.id != cv.id,
  );
};
const getExtraItemContractVariable = (item: ExtraItem): ContactVariable => {
  if (
    item.contractVariable &&
    typeof item.contractVariable === 'object' &&
    'id' in item.contractVariable
  ) {
    return item.contractVariable;
  }
  throw new Error('contractVariable must be a ContactVariable');
};
</script>
