<template>
  <v-card 
    class="student-card" 
    elevation="2"
    hover
    @click="$emit('click')"
  >
    <div class="card-header">
      <v-avatar size="60" class="student-avatar">
        <v-img 
          :src="profileImageUrl" 
          :alt="`${student.first_name} ${student.last_name}`"
          cover
        >
          <template v-slot:placeholder>
            <div class="d-flex align-center justify-center fill-height">
              <v-icon size="30" color="grey-lighten-2">mdi-account</v-icon>
            </div>
          </template>
        </v-img>
      </v-avatar>
      
      <div class="student-info">
        <h3 class="text-h6 font-weight-bold">
          {{ student.first_name }} {{ student.last_name }}
        </h3>
        <p class="text-body-2 text-grey-darken-1 mb-1">
          {{ formatAge(student.date_of_birth) }} ans
        </p>
        <v-chip 
          :color="getStatusColor(enrollment?.status)" 
          size="small" 
          variant="tonal"
        >
          {{ enrollment?.status || 'Non inscrit' }}
        </v-chip>
      </div>
    </div>

    <v-card-text class="pt-2">
      <div class="d-flex align-center mb-2">
        <v-icon size="16" color="grey-darken-1" class="mr-2">mdi-school</v-icon>
        <span class="text-body-2">{{ enrollment?.class?.name || 'Aucune classe' }}</span>
      </div>
      
      <div class="d-flex align-center mb-2" v-if="guardian">
        <v-icon size="16" color="grey-darken-1" class="mr-2">mdi-account-tie</v-icon>
        <span class="text-body-2">{{ guardian.name }}</span>
      </div>
      
      <div class="d-flex align-center" v-if="guardian">
        <v-icon size="16" color="grey-darken-1" class="mr-2">mdi-phone</v-icon>
        <span class="text-body-2">{{ guardian.phone }}</span>
      </div>
    </v-card-text>

    <v-card-actions class="pt-0">
      <v-spacer></v-spacer>
      <v-btn 
        icon 
        size="small" 
        @click.stop="$emit('edit')"
        color="primary"
      >
        <v-icon>mdi-pencil</v-icon>
      </v-btn>
      <v-btn 
        icon 
        size="small" 
        @click.stop="$emit('delete')"
        color="error"
      >
        <v-icon>mdi-delete</v-icon>
      </v-btn>
    </v-card-actions>
  </v-card>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { Student, Enrollment, Guardian } from '../types'

interface Props {
  student: Student
  enrollment?: Enrollment
  guardian?: Guardian
}

const props = defineProps<Props>()

defineEmits<{
  click: []
  edit: []
  delete: []
}>()

const profileImageUrl = computed(() => {
  if (props.student.profile_image && props.student.profile_image !== 'default-avatar.png') {
    return props.student.profile_image
  }
  return `https://images.pexels.com/photos/1102341/pexels-photo-1102341.jpeg?auto=compress&cs=tinysrgb&w=400`
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

function getStatusColor(status?: string): string {
  const colors = {
    'pending': 'warning',
    'approved': 'success',
    'rejected': 'error',
    'incomplete': 'orange'
  }
  return colors[status as keyof typeof colors] || 'grey'
}
</script>

<style scoped>
.student-card {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
  border-radius: 12px;
  overflow: hidden;
}

.student-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15) !important;
}

.card-header {
  display: flex;
  align-items: center;
  padding: 16px;
  gap: 16px;
}

.student-avatar {
  border: 3px solid rgba(var(--v-theme-primary), 0.1);
  transition: border-color 0.3s ease;
}

.student-card:hover .student-avatar {
  border-color: rgba(var(--v-theme-primary), 0.3);
}

.student-info {
  flex: 1;
  min-width: 0;
}

.student-info h3 {
  line-height: 1.2;
  margin-bottom: 4px;
}
</style>