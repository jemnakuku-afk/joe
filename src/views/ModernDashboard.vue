<template>
  <v-container fluid class="modern-dashboard">
    <!-- Header Section -->
    <div class="dashboard-header mb-8">
      <div class="d-flex align-center justify-space-between flex-wrap">
        <div>
          <h1 class="text-h4 font-weight-bold text-primary mb-2">
            <v-icon size="32" class="mr-3">mdi-school</v-icon>
            Tableau de Bord
          </h1>
          <p class="text-h6 text-grey-darken-1">
            Gestion des inscriptions EP MATENDO
          </p>
        </div>
        
        <div class="d-flex gap-3">
          <v-btn 
            color="primary" 
            size="large"
            @click="showStudentForm = true"
            class="add-student-btn"
          >
            <v-icon class="mr-2">mdi-plus</v-icon>
            Nouvel élève
          </v-btn>
          
          <v-btn 
            color="success" 
            variant="outlined"
            @click="exportData"
            :loading="exporting"
          >
            <v-icon class="mr-2">mdi-download</v-icon>
            Exporter
          </v-btn>
        </div>
      </div>
    </div>

    <!-- Statistics Cards -->
    <v-row class="mb-8">
      <v-col cols="12" sm="6" md="3">
        <StatsCard
          title="Total Élèves"
          :value="stats.totalStudents"
          icon="mdi-account-group"
          color="primary"
          :trend="stats.studentsTrend"
        />
      </v-col>
      
      <v-col cols="12" sm="6" md="3">
        <StatsCard
          title="Inscriptions Approuvées"
          :value="stats.approvedEnrollments"
          icon="mdi-check-circle"
          color="success"
          :trend="stats.approvedTrend"
        />
      </v-col>
      
      <v-col cols="12" sm="6" md="3">
        <StatsCard
          title="En Attente"
          :value="stats.pendingEnrollments"
          icon="mdi-clock-outline"
          color="warning"
          :trend="stats.pendingTrend"
        />
      </v-col>
      
      <v-col cols="12" sm="6" md="3">
        <StatsCard
          title="Paiements"
          :value="`${stats.totalPayments.toLocaleString()} FC`"
          icon="mdi-credit-card"
          color="info"
          :trend="stats.paymentsTrend"
        />
      </v-col>
    </v-row>

    <!-- Main Content -->
    <v-row>
      <v-col cols="12">
        <v-card class="main-content-card" elevation="2">
          <v-card-title class="pa-6 bg-grey-lighten-5">
            <div class="d-flex align-center justify-space-between w-100">
              <span class="text-h5 font-weight-bold">
                <v-icon class="mr-2">mdi-account-school</v-icon>
                Gestion des Élèves
              </span>
              
              <div class="d-flex align-center gap-3">
                <v-btn-toggle 
                  v-model="viewMode" 
                  mandatory 
                  variant="outlined"
                  density="compact"
                >
                  <v-btn value="grid" icon>
                    <v-icon>mdi-view-grid</v-icon>
                  </v-btn>
                  <v-btn value="list" icon>
                    <v-icon>mdi-view-list</v-icon>
                  </v-btn>
                </v-btn-toggle>
              </div>
            </div>
          </v-card-title>

          <v-card-text class="pa-6">
            <ClassFilter
              @edit="editStudent"
              @delete="deleteStudent"
              @view="viewStudent"
              @add-student="showStudentForm = true"
            />
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- Student Form Dialog -->
    <StudentForm
      v-model="showStudentForm"
      :student="selectedStudent"
      :guardian="selectedGuardian"
      @saved="handleStudentSaved"
    />

    <!-- Student Details Dialog -->
    <StudentDetailsDialog
      v-model="showStudentDetails"
      :student="selectedStudent"
      :enrollment="selectedEnrollment"
      :guardian="selectedGuardian"
      @payment="handlePayment"
      @status-update="handleStatusUpdate"
    />

    <!-- Payment Dialog -->
    <PaymentDialog
      v-model="showPaymentDialog"
      :enrollment="selectedEnrollment"
      @payment-completed="handlePaymentCompleted"
    />

    <!-- Snackbar for notifications -->
    <v-snackbar 
      v-model="snackbar" 
      :color="snackbarColor" 
      :timeout="4000"
      location="top"
    >
      {{ snackbarMessage }}
      <template v-slot:actions>
        <v-btn variant="text" @click="snackbar = false">
          <v-icon>mdi-close</v-icon>
        </v-btn>
      </template>
    </v-snackbar>
  </v-container>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useStudentsStore } from '../stores/students'
import ClassFilter from '../components/ClassFilter.vue'
import StudentForm from '../components/StudentForm.vue'
import StudentDetailsDialog from '../components/StudentDetailsDialog.vue'
import PaymentDialog from '../components/PaymentDialog.vue'
import StatsCard from '../components/StatsCard.vue'
import type { Student, Guardian, Enrollment } from '../types'

const store = useStudentsStore()

const viewMode = ref('grid')
const showStudentForm = ref(false)
const showStudentDetails = ref(false)
const showPaymentDialog = ref(false)
const selectedStudent = ref<Student | undefined>()
const selectedGuardian = ref<Guardian | undefined>()
const selectedEnrollment = ref<Enrollment | undefined>()
const exporting = ref(false)
const snackbar = ref(false)
const snackbarMessage = ref('')
const snackbarColor = ref('success')

const stats = computed(() => {
  const totalStudents = store.students.length
  const approvedEnrollments = store.enrollments.filter(e => e.status === 'approved').length
  const pendingEnrollments = store.enrollments.filter(e => e.status === 'pending').length
  const paymentStats = store.getPaymentStats
  
  return {
    totalStudents,
    approvedEnrollments,
    pendingEnrollments,
    totalPayments: paymentStats.totalAmount,
    studentsTrend: '+12%',
    approvedTrend: '+8%',
    pendingTrend: '-5%',
    paymentsTrend: '+15%'
  }
})

function editStudent(student: Student) {
  selectedStudent.value = student
  // In a real app, fetch the guardian data
  selectedGuardian.value = {
    name: 'Parent Exemple',
    relationship: 'Parent',
    phone: '+243 123 456 789',
    email: 'parent@example.com',
    is_primary: true
  }
  showStudentForm.value = true
}

function viewStudent(student: Student) {
  selectedStudent.value = student
  selectedEnrollment.value = store.enrollments.find(e => e.student_id === student.id)
  selectedGuardian.value = {
    name: 'Parent Exemple',
    relationship: 'Parent',
    phone: '+243 123 456 789',
    email: 'parent@example.com',
    is_primary: true
  }
  showStudentDetails.value = true
}

async function deleteStudent(student: Student) {
  if (confirm(`Êtes-vous sûr de vouloir supprimer ${student.first_name} ${student.last_name} ?`)) {
    try {
      await store.deleteStudent(student.id!)
      showSnackbar('Élève supprimé avec succès', 'success')
    } catch (error) {
      showSnackbar('Erreur lors de la suppression', 'error')
    }
  }
}

function handleStudentSaved() {
  selectedStudent.value = undefined
  selectedGuardian.value = undefined
  showSnackbar('Élève enregistré avec succès', 'success')
}

function handlePayment(enrollment: Enrollment) {
  selectedEnrollment.value = enrollment
  showPaymentDialog.value = true
}

async function handleStatusUpdate(enrollmentId: string, status: string, notes?: string) {
  try {
    await store.updateEnrollmentStatus(enrollmentId, status, notes)
    showSnackbar('Statut mis à jour avec succès', 'success')
  } catch (error) {
    showSnackbar('Erreur lors de la mise à jour', 'error')
  }
}

async function handlePaymentCompleted() {
  showPaymentDialog.value = false
  showSnackbar('Paiement traité avec succès', 'success')
  await store.fetchEnrollments()
}

function showSnackbar(message: string, color: string = 'success') {
  snackbarMessage.value = message
  snackbarColor.value = color
  snackbar.value = true
}

async function exportData() {
  exporting.value = true
  try {
    // Simulate export process
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    const csvData = store.students.map(student => {
      const enrollment = store.enrollments.find(e => e.student_id === student.id)
      const studentClass = store.classes.find(c => c.id === enrollment?.class_id)
      
      return [
        student.last_name,
        student.first_name,
        student.date_of_birth,
        student.gender,
        studentClass?.name || 'Aucune classe',
        enrollment?.status || 'Non inscrit',
        student.created_at?.split('T')[0] || ''
      ].join(',')
    })
    
    const csv = [
      'Nom,Prénom,Date de naissance,Genre,Classe,Statut,Date d\'inscription',
      ...csvData
    ].join('\n')
    
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const link = document.createElement('a')
    link.href = URL.createObjectURL(blob)
    link.download = `etudiants_${new Date().toISOString().split('T')[0]}.csv`
    link.click()
    
    showSnackbar('Export réalisé avec succès', 'success')
  } catch (error) {
    showSnackbar('Erreur lors de l\'export', 'error')
  } finally {
    exporting.value = false
  }
}

onMounted(async () => {
  await Promise.all([
    store.fetchStudents(),
    store.fetchClasses(),
    store.fetchEnrollments()
  ])
})
</script>

<style scoped>
.modern-dashboard {
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: 100vh;
  padding-top: 24px;
}

.dashboard-header {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.add-student-btn {
  border-radius: 12px;
  text-transform: none;
  font-weight: 600;
  box-shadow: 0 4px 12px rgba(var(--v-theme-primary), 0.3);
  transition: all 0.3s ease;
}

.add-student-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(var(--v-theme-primary), 0.4);
}

.main-content-card {
  border-radius: 16px;
  overflow: hidden;
  backdrop-filter: blur(10px);
  background: rgba(255, 255, 255, 0.95);
}

.student-grid {
  animation: fadeInUp 0.6s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>