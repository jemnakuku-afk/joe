<template>
  <v-dialog v-model="dialog" max-width="500" persistent>
    <v-card class="payment-dialog-card">
      <v-card-title class="pa-6 bg-success">
        <span class="text-h5 text-white">
          <v-icon class="mr-2" color="white">mdi-credit-card</v-icon>
          Simulation de Paiement
        </span>
      </v-card-title>

      <v-card-text class="pa-6 text-center">
        <v-icon size="80" color="success" class="mb-4 payment-icon">
          mdi-school
        </v-icon>
        
        <h3 class="text-h5 mb-4">Frais de Scolarité</h3>
        
        <div class="amount-display mb-6">
          <div class="text-h3 font-weight-bold text-success">
            50 000 FC
          </div>
          <div class="text-body-1 text-grey-darken-1">
            Année académique 2024-2025
          </div>
        </div>

        <v-alert type="info" variant="tonal" class="mb-6">
          <div class="text-left">
            <div class="font-weight-bold mb-2">Détails du paiement:</div>
            <div>• Frais d'inscription: 10 000 FC</div>
            <div>• Frais de scolarité: 40 000 FC</div>
            <div class="mt-2 font-weight-bold">Total: 50 000 FC</div>
          </div>
        </v-alert>

        <div class="payment-methods mb-6">
          <h4 class="text-h6 mb-3">Mode de paiement</h4>
          <v-radio-group v-model="paymentMethod" inline>
            <v-radio 
              label="Mobile Money" 
              value="mobile_money"
              color="primary"
            ></v-radio>
            <v-radio 
              label="Espèces" 
              value="cash"
              color="primary"
            ></v-radio>
          </v-radio-group>
        </div>

        <div class="d-flex gap-3 justify-center">
          <v-btn
            color="success"
            size="large"
            @click="processPayment"
            :loading="processing"
            class="px-8 payment-btn"
          >
            <v-icon class="mr-2">mdi-check</v-icon>
            Confirmer le paiement
          </v-btn>
          
          <v-btn
            variant="outlined"
            size="large"
            @click="closeDialog"
            :disabled="processing"
          >
            Annuler
          </v-btn>
        </div>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useStudentsStore } from '../stores/students'
import type { Enrollment } from '../types'

interface Props {
  modelValue: boolean
  enrollment?: Enrollment
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'payment-completed': []
}>()

const store = useStudentsStore()

const dialog = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const processing = ref(false)
const paymentMethod = ref('mobile_money')

async function processPayment() {
  if (!props.enrollment?.id) return
  
  processing.value = true
  
  try {
    // Simulate payment processing delay
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // Generate transaction ID
    const transactionId = `SIM_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    
    // Create payment record
    await store.createPayment({
      enrollment_id: props.enrollment.id,
      amount: 50000,
      payment_method: paymentMethod.value,
      transaction_id: transactionId,
      status: 'completed'
    })
    
    emit('payment-completed')
    closeDialog()
  } catch (error) {
    console.error('Payment error:', error)
  } finally {
    processing.value = false
  }
}

function closeDialog() {
  dialog.value = false
  paymentMethod.value = 'mobile_money'
}
</script>

<style scoped>
.payment-dialog-card {
  border-radius: 16px;
  overflow: hidden;
}

.payment-icon {
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-10px);
  }
  60% {
    transform: translateY(-5px);
  }
}

.amount-display {
  background: linear-gradient(135deg, #e8f5e8 0%, #f0f9ff 100%);
  border-radius: 12px;
  padding: 24px;
  border: 2px solid rgba(var(--v-theme-success), 0.2);
}

.payment-methods {
  background: rgba(var(--v-theme-info), 0.05);
  border-radius: 12px;
  padding: 16px;
}

.payment-btn {
  border-radius: 12px;
  text-transform: none;
  font-weight: 600;
  box-shadow: 0 4px 12px rgba(var(--v-theme-success), 0.3);
  transition: all 0.3s ease;
}

.payment-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(var(--v-theme-success), 0.4);
}
</style>