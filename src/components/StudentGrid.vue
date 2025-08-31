<template>
  <div class="student-grid">
    <v-row v-if="filteredStudents.length > 0">
      <v-col 
        v-for="student in filteredStudents" 
        :key="student.id"
        cols="12" 
        sm="6" 
        md="4" 
        lg="3"
      >
        <StudentCard
          :student="student"
          :enrollment="getEnrollment(student.id)"
          :guardian="getGuardian(student.id)"
          @click="$emit('view', student)"
          @edit="$emit('edit', student)"
          @delete="$emit('delete', student)"
        />
      </v-col>
    </v-row>
    
    <v-empty-state
      v-else
      icon="mdi-account-school"
      title="Aucun élève trouvé"
      text="Il n'y a aucun élève correspondant aux critères de recherche."
    >
      <template v-slot:actions>
        <v-btn color="primary" @click="$emit('add-student')">
          <v-icon class="mr-2">mdi-plus</v-icon>
          Ajouter un élève
        </v-btn>
      </template>
    </v-empty-state>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useStudentsStore } from '../stores/students'
import StudentCard from './StudentCard.vue'
import type { Student } from '../types'

interface Props {
  students: Student[]
  search?: string
}

const props = defineProps<Props>()

defineEmits<{
  view: [student: Student]
  edit: [student: Student]
  delete: [student: Student]
  'add-student': []
}>()

const store = useStudentsStore()

const filteredStudents = computed(() => {
  if (!props.search) return props.students
  
  const searchTerm = props.search.toLowerCase()
  return props.students.filter(student => 
    student.first_name.toLowerCase().includes(searchTerm) ||
    student.last_name.toLowerCase().includes(searchTerm) ||
    getGuardian(student.id)?.name.toLowerCase().includes(searchTerm) ||
    getGuardian(student.id)?.phone.includes(searchTerm)
  )
})

function getEnrollment(studentId?: string) {
  return store.enrollments.find(e => e.student_id === studentId)
}

function getGuardian(studentId?: string) {
  // In a real app, this would come from the student's guardians relationship
  // For now, we'll simulate it
  return {
    name: 'Parent Exemple',
    phone: '+243 123 456 789',
    relationship: 'Parent',
    is_primary: true
  }
}
</script>

<style scoped>
.student-grid {
  min-height: 400px;
}
</style>