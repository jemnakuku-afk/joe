<template>
  <v-dialog v-model="dialog" max-width="900" scrollable>
    <v-card v-if="student" class="student-details-card">
      <v-card-title class="pa-6 bg-primary">
        <div class="d-flex align-center w-100">
          <v-avatar size="50" class="mr-4">
            <v-img 
              :src="profileImageUrl" 
              :alt="`${student.first_name} ${student.last_name}`"
              cover
            >
              <template v-slot:placeholder>
                <v-icon color="white">mdi-account</v-icon>
              </template>
            </v-img>
          </v-avatar>
          
          <div class="flex-grow-1">
            <span class="text-h5 text-white font-weight-bold">
              {{ student.first_name }} {{ student.last_name }}
            </span>
            <div class="text-body-2 text-blue-lighten-3 mt-1">
              {{ formatAge(student.date_of_birth) }} ans • {{ student.gender === 'M' ? 'Masculin' : 'Féminin' }}
            </div>
          </div>
          
          <v-btn icon variant="text" @click="closeDialog">
            <v-icon color="white">mdi-close</v-icon>
          </v-btn>
        </div>
      </v-card-title>

      <v-card-text class="pa-0">
        <v-tabs v-model="activeTab" color="primary" align-tabs="center">
          <v-tab value="info">
            <v-icon class="mr-2">mdi-information</v-icon>
            Informations
          </v-tab>
          <v-tab value="enrollment">
            <v-icon class="mr-2">mdi-school</v-icon>
            Inscription
          </v-tab>
          <v-tab value="payment">
            <v-icon class="mr-2">mdi-credit-card</v-icon>
            Paiement
          </v-tab>
        </v-tabs>

        <v-window v-model="activeTab" class="pa-6">
          <!-- Student Information Tab -->
          <v-window-item value="info">
            <v-row>
              <v-col cols="12" md="6">
                <InfoField 
                  label="Date de naissance" 
                  :value="formatDate(student.date_of_birth)"
                  icon="mdi-calendar"
                />
              </v-col>
              
              <v-col cols="12" md="6">
                <InfoField 
                  label="Genre" 
                  :value="student.gender === 'M' ? 'Masculin' : 'Féminin'"
                  icon="mdi-human-male-female"
                />
              </v-col>
              
              <v-col cols="12" v-if="student.address">
                <InfoField 
                  label="Adresse" 
                  :value="student.address"
                  icon="mdi-map-marker"
                />
              </v-col>
              
              <v-col cols="12" v-if="student.medical_notes">
                <InfoField 
                  label="Notes médicales" 
                  :value="student.medical_notes"
                  icon="mdi-medical-bag"
                />
              </v-col>
              
              <v-col cols="12" v-if="guardian">
                <v-divider class="my-4"></v-divider>
                <h4 class="text-h6 mb-4 text-primary">
                  <v-icon class="mr-2">mdi-account-tie</v-icon>
                  Contact Parent/Tuteur
                </h4>
                
                <InfoField 
                  label="Nom" 
                  :value="guardian.name"
                  icon="mdi-account"
                />
                
                <InfoField 
                  label="Relation" 
                  :value="guardian.relationship"
                  icon="mdi-family-tree"
                  class="mt-3"
                />
                
                <InfoField 
                  label="Téléphone" 
                  :value="guardian.phone"
                  icon="mdi-phone"
                  class="mt-3"
                />
                
                <InfoField 
                  v-if="guardian.email"
                  label="Email" 
                  :value="guardian.email"
                  icon="mdi-email"
                  class="mt-3"
                />
              </v-col>
            </v-row>
          </v-window-item>

          <!-- Enrollment Tab -->
          <v-window-item value="enrollment">
            <div v-if="enrollment">
              <v-row>
                <v-col cols="12" md="6">
                  <InfoField 
                    label="Classe" 
                    :value="enrollment.class?.name || 'Non assignée'"
                    icon="mdi-school"
                  />
                </v-col>
                
                <v-col cols="12" md="6">
                  <InfoField 
                    label="Année académique" 
                    :value="enrollment.academic_year"
                    icon="mdi-calendar-range"
                  />
                </v-col>
                
                <v-col cols="12" md="6">
                  <InfoField 
                    label="Date d'inscription" 
                    :value="formatDate(enrollment.enrollment_date)"
                    icon="mdi-calendar-check"
                  />
                </v-col>
                
                <v-col cols="12" md="6">
                  <div class="d-flex align-center">
                    <v-icon class="mr-3" color="grey-darken-1">mdi-flag</v-icon>
                    <div>
                      <div class="text-caption text-grey-darken-1">Statut</div>
                      <v-chip 
                        :color="getStatusColor(enrollment.status)" 
                        variant="tonal"
                        size="small"
                      >
                        {{ getStatusText(enrollment.status) }}
                      </v-chip>
                    </div>
                  </div>
                </v-col>
                
                <v-col cols="12" v-if="enrollment.notes">
                  <InfoField 
                    label="Notes" 
                    :value="enrollment.notes"
                    icon="mdi-note-text"
                  />
                </v-col>
              </v-row>
              
              <!-- Status Update Actions -->
              <v-divider class="my-6"></v-divider>
              <div class="text-center">
                <h4 class="text-h6 mb-4">Actions sur l'inscription</h4>
                <div class="d-flex justify-center gap-3 flex-wrap">
                  <v-btn 
                    color="success" 
                    variant="outlined"
                    @click="updateStatus('approved')"
                    :disabled="enrollment.status === 'approved'"
                  >
                    <v-icon class="mr-2">mdi-check</v-icon>
                    Approuver
                  </v-btn>
                  
                  <v-btn 
                    color="warning" 
                    variant="outlined"
                    @click="updateStatus('incomplete')"
                    :disabled="enrollment.status === 'incomplete'"
                  >
                    <v-icon class="mr-2">mdi-alert</v-icon>
                    Marquer incomplet
                  </v-btn>
                  
                  <v-btn 
                    color="error" 
                    variant="outlined"
                    @click="updateStatus('rejected')"
                    :disabled="enrollment.status === 'rejected'"
                  >
                    <v-icon class="mr-2">mdi-close</v-icon>
                    Rejeter
                  </v-btn>
                </div>
              </div>
            </div>
            
            <v-empty-state
              v-else
              icon="mdi-school-outline"
              title="Aucune inscription"
              text="Cet élève n'est pas encore inscrit dans une classe."
            />
          </v-window-item>

          <!-- Payment Tab -->
          <v-window-item value="payment">
            <div v-if="enrollment">
              <div class="text-center mb-6">
                <v-icon size="64" :color="paymentStatusColor" class="mb-3">
                  {{ paymentStatusIcon }}
                </v-icon>
                <h4 class="text-h6 mb-2">Frais de Scolarité</h4>
                <div class="text-h4 font-weight-bold text-primary">50 000 FC</div>
              </div>
              
              <v-alert 
                :type="paymentStatusColor" 
                variant="tonal" 
                class="mb-4"
              >
                {{ paymentStatusMessage }}
              </v-alert>
              
              <div class="text-center" v-if="!hasPayment">
                <v-btn 
                  color="success" 
                  size="large"
                  @click="$emit('payment', enrollment)"
                  class="px-8"
                >
                  <v-icon class="mr-2">mdi-credit-card</v-icon>
                  Simuler le paiement
                </v-btn>
              </div>
              
              <!-- Payment History -->
              <div v-if="hasPayment" class="mt-6">
                <h4 class="text-h6 mb-3">Historique des paiements</h4>
                <v-card variant="outlined">
                  <v-card-text>
                    <div class="d-flex align-center justify-space-between">
                      <div>
                        <div class="font-weight-bold">Paiement des frais</div>
                        <div class="text-body-2 text-grey-darken-1">
                          Transaction: SIM_{{ enrollment.id?.slice(0, 8) }}
                        </div>
                      </div>
                      <div class="text-right">
                        <div class="text-h6 font-weight-bold text-success">50 000 FC</div>
                        <div class="text-body-2 text-grey-darken-1">
                          {{ formatDate(enrollment.updated_at) }}
                        </div>
                      </div>
                    </div>
                  </v-card-text>
                </v-card>
              </div>
            </div>
            
            <v-empty-state
              v-else
              icon="mdi-credit-card-off"
              title="Aucune inscription"
              text="L'élève doit d'abord être inscrit pour effectuer un paiement."
            />
          </v-window-item>
        </v-window>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import type { Student, Guardian, Enrollment } from '../types'
import InfoField from './InfoField.vue'

interface Props {
  modelValue: boolean
  student?: Student
  guardian?: Guardian
  enrollment?: Enrollment
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'payment': [enrollment: Enrollment]
  'status-update': [enrollmentId: string, status: string, notes?: string]
}>()

const dialog = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const activeTab = ref('info')

const profileImageUrl = computed(() => {
  if (props.student?.profile_image && props.student.profile_image !== 'default-avatar.png') {
    return props.student.profile_image
  }
  return 'https://images.pexels.com/photos/1102341/pexels-photo-1102341.jpeg?auto=compress&cs=tinysrgb&w=400'
})

const hasPayment = computed(() => {
  return props.enrollment?.status === 'approved'
})

const paymentStatusColor = computed(() => {
  return hasPayment.value ? 'success' : 'warning'
})

const paymentStatusIcon = computed(() => {
  return hasPayment.value ? 'mdi-check-circle' : 'mdi-clock-outline'
})

const paymentStatusMessage = computed(() => {
  return hasPayment.value 
    ? 'Paiement effectué avec succès' 
    : 'Paiement en attente'
})

function formatAge(dateOfBirth: string): number {
  const today = new Date()
  const birthDate = new Date(dateOfBirth)
  let age = today.getFullYear() - birthDate.getFullYear()
  const monthDiff = today.getMonth() - birthDate.getMonth()
  
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--
  }
  
  return age
}

function formatDate(dateString?: string): string {
  if (!dateString) return 'Non défini'
  return new Date(dateString).toLocaleDateString('fr-FR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

function getStatusColor(status: string): string {
  const colors = {
    'pending': 'warning',
    'approved': 'success',
    'rejected': 'error',
    'incomplete': 'orange'
  }
  return colors[status as keyof typeof colors] || 'grey'
}

function getStatusText(status: string): string {
  const texts = {
    'pending': 'En attente',
    'approved': 'Approuvé',
    'rejected': 'Rejeté',
    'incomplete': 'Incomplet'
  }
  return texts[status as keyof typeof texts] || status
}

function updateStatus(newStatus: string) {
  if (props.enrollment?.id) {
    emit('status-update', props.enrollment.id, newStatus)
  }
}

function closeDialog() {
  dialog.value = false
  activeTab.value = 'info'
}
</script>

<style scoped>
.student-details-card {
  border-radius: 16px;
  overflow: hidden;
}
</style>