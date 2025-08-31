<template>
  <div class="class-filter">
    <v-tabs 
      v-model="activeTab" 
      color="primary" 
      align-tabs="center"
      class="mb-4"
      show-arrows
    >
      <v-tab value="all" class="filter-tab">
        <v-icon class="mr-2">mdi-view-grid</v-icon>
        Tous ({{ totalCount }})
      </v-tab>
      
      <v-tab 
        v-for="level in levels" 
        :key="level.value"
        :value="level.value"
        class="filter-tab"
      >
        <v-icon class="mr-2">{{ level.icon }}</v-icon>
        {{ level.title }} ({{ level.count }})
      </v-tab>
    </v-tabs>

    <v-window v-model="activeTab" class="mt-4">
      <v-window-item value="all">
        <div class="d-flex align-center mb-4">
          <v-text-field
            v-model="search"
            label="Rechercher un élève..."
            prepend-inner-icon="mdi-magnify"
            variant="outlined"
            density="compact"
            clearable
            class="mr-4"
            style="max-width: 300px"
          ></v-text-field>
          
          <v-select
            v-model="statusFilter"
            label="Statut"
            :items="statusOptions"
            variant="outlined"
            density="compact"
            clearable
            style="max-width: 200px"
          ></v-select>
        </div>
        
        <StudentGrid 
          :students="filteredStudents" 
          :search="search"
          @edit="$emit('edit', $event)"
          @delete="$emit('delete', $event)"
          @view="$emit('view', $event)"
        />
      </v-window-item>
      
      <v-window-item 
        v-for="level in levels" 
        :key="level.value"
        :value="level.value"
      >
        <div class="d-flex align-center mb-4">
          <v-text-field
            v-model="search"
            label="Rechercher un élève..."
            prepend-inner-icon="mdi-magnify"
            variant="outlined"
            density="compact"
            clearable
            class="mr-4"
            style="max-width: 300px"
          ></v-text-field>
          
          <v-select
            v-model="classFilter"
            :label="`Classes ${level.title}`"
            :items="getClassesByLevel(level.value)"
            variant="outlined"
            density="compact"
            clearable
            style="max-width: 250px"
          ></v-select>
        </div>
        
        <StudentGrid 
          :students="getStudentsByLevel(level.value)" 
          :search="search"
          @edit="$emit('edit', $event)"
          @delete="$emit('delete', $event)"
          @view="$emit('view', $event)"
        />
      </v-window-item>
    </v-window>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useStudentsStore } from '../stores/students'
import StudentGrid from './StudentGrid.vue'
import type { Student } from '../types'

defineEmits<{
  edit: [student: Student]
  delete: [student: Student]
  view: [student: Student]
}>()

const store = useStudentsStore()

const activeTab = ref('all')
const search = ref('')
const statusFilter = ref('')
const classFilter = ref('')

const levels = computed(() => [
  {
    title: 'Primaire',
    value: 'Primaire',
    icon: 'mdi-school-outline',
    count: getStudentsByLevel('Primaire').length
  },
  {
    title: 'Secondaire', 
    value: 'Secondaire',
    icon: 'mdi-school',
    count: getStudentsByLevel('Secondaire').length
  }
])

const totalCount = computed(() => store.students.length)

const statusOptions = [
  { title: 'En attente', value: 'pending' },
  { title: 'Approuvé', value: 'approved' },
  { title: 'Rejeté', value: 'rejected' },
  { title: 'Incomplet', value: 'incomplete' }
]

const filteredStudents = computed(() => {
  let students = store.students
  
  if (statusFilter.value) {
    students = students.filter(student => {
      const enrollment = store.enrollments.find(e => e.student_id === student.id)
      return enrollment?.status === statusFilter.value
    })
  }
  
  return students
})

function getStudentsByLevel(level: string) {
  return store.students.filter(student => {
    const enrollment = store.enrollments.find(e => e.student_id === student.id)
    const studentClass = store.classes.find(c => c.id === enrollment?.class_id)
    return studentClass?.level === level
  })
}

function getClassesByLevel(level: string) {
  return store.classes
    .filter(cls => cls.level === level)
    .map(cls => ({
      title: cls.name,
      value: cls.id
    }))
}
</script>

<style scoped>
.class-filter {
  width: 100%;
}

.filter-tab {
  transition: all 0.3s ease;
}

.filter-tab:hover {
  background-color: rgba(var(--v-theme-primary), 0.1);
}
</style>