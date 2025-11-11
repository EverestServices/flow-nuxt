<template>
  <div class="bg-base-100 p-4 rounded-2xl bg-white/80 dark:bg-black/80 shadow-inner mt-3 border border-white dark:border-black">
    <div class="">
      <h3 class="text-lg font-semibold mb-2 text-secondary">Extra tételek</h3>
      <div
        v-for="extraItem in extraItemsValue"
        :key="extraItem.id"
        class="mb-3 px-4 py-3 rounded-lg border border-base-300 bg-secondary/10 flex items-center gap-3"
      >
        <!-- Cím és input flex layout -->
        <div class="flex-1">
          <div class="font-semibold text-base text-secondary mb-2">
            {{ getExtraItemContractVariable(extraItem).name }}
          </div>

          <!-- Input + egység -->
          <div class="form-control max-w-[10rem] w-full">
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

        <!-- Törlés gomb jobb oldalon - glass effect -->
        <button
          class="w-10 h-10 rounded-full bg-white/20 dark:bg-black/20 backdrop-blur-md border border-white/40 dark:border-black/10 hover:bg-red-500/30 hover:border-red-500/50 transition-all duration-200 flex items-center justify-center group shrink-0"
          @click="removeItem(extraItem)"
          title="Tétel törlése"
        >
          <Icon name="i-lucide-trash-2" class="w-5 h-5 text-gray-700 dark:text-gray-300 group-hover:text-red-600 dark:group-hover:text-red-400 transition-colors" />
        </button>
      </div>
    </div>

    <div class="flex gap-2 items-end mt-4">
      <div class="flex-1">
        <label class="block text-xs text-gray-500 mb-1">Extra tétel hozzáadása</label>
        <select
          v-model="selectedDropdownItem"
          class="w-full h-9 rounded-md border border-base-300 bg-base-100 text-sm px-2"
        >
          <option :value="null" disabled>Válassz extra tételt...</option>
          <option
            v-for="contractVariable in enabledContractVariables"
            :key="contractVariable.id"
            :value="contractVariable"
          >
            {{ contractVariable.name }}
          </option>
        </select>
      </div>
      <UButton
        @click="addSelectedItem"
        :disabled="!selectedDropdownItem"
        color="primary"
        size="sm"
        class="flex items-center gap-1"
      >
        <Icon name="i-lucide-plus" class="w-4 h-4" />
        Hozzáadás
      </UButton>
    </div>
  </div>
</template>
<script lang="ts" setup>
import type { ContactVariable } from '@/model/ContractVariable';
import type { ExtraItem } from '@/model/ExtraItem';
import { computed, ref } from 'vue';

const contractVariableSource =
  '[{"id":"15cf38e8-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Antenna leszerelés","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":25000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf39e8-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Antenna visszahelyezés","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":25000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3a17-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Klíma/hőszivattyú le-, és felszerelés","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":57150,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3a3a-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Eresz eltávolítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":10000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3ab7-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Parapetes kivezetők hosszabbítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":15000,"workNetPrice":25000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3ad3-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Gázcső, dobozolása/alászigetelése","belongsToImplementing":true,"quantityUnit":"m","materialNetPrice":1000,"workNetPrice":1000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3aee-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Légtechnikai kivezetés hosszabbítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":2000,"workNetPrice":2800,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3b0a-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Kőpárkány vésése/eltávolítása","belongsToImplementing":true,"quantityUnit":"m","materialNetPrice":null,"workNetPrice":5000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3b23-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Növényzet eltávolítása, tereprendezés","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":70000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3b42-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Állványozás","belongsToImplementing":true,"quantityUnit":"m2","materialNetPrice":null,"workNetPrice":3677,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3b5b-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Lábazat előkészítése","belongsToImplementing":true,"quantityUnit":"m2","materialNetPrice":12600,"workNetPrice":15000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3b73-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Homlokzati elemek bontása","belongsToImplementing":true,"quantityUnit":"m2","materialNetPrice":null,"workNetPrice":3050,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3b8a-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Korlát eltávolítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":134850,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3bbc-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Kerítés/kapu eltávolítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":134850,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3bee-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Előtető eltávolítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":7900,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3c1e-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Ablakrács eltávolítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":10000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3c4c-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Redőny eltávolítása","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":5000,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}},{"id":"15cf3c80-1f38-11f0-b371-b42e99c1a106","type":"Insulation facade","name":"Elektromos szerelés","belongsToImplementing":true,"quantityUnit":"db","materialNetPrice":null,"workNetPrice":0,"active":true,"createdAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"},"updatedAt":{"date":"2025-04-22 07:10:19.000000","timezone_type":3,"timezone":"UTC"}}]';
const contractVariables = ref<ContactVariable[]>(JSON.parse(contractVariableSource));
const selectedContractVariables = ref<ContactVariable[]>([]);
const extraItemsValue = ref<ExtraItem[]>([]);
const selectedDropdownItem = ref<ContactVariable | null>(null);
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

const addSelectedItem = () => {
  if (selectedDropdownItem.value) {
    selectContractVariable(selectedDropdownItem.value);
    selectedDropdownItem.value = null; // Reset dropdown after adding
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
