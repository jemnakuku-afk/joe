<template>
  <v-dialog v-model="dialog" max-width="800" persistent>
    <v-card class="student-form-card">
      <v-card-title class="pa-6 bg-primary">
        <span class="text-h5 text-white">
          <v-icon class="mr-2" color="white">
            {{ isEditing ? 'mdi-pencil' : 'mdi-account-plus' }}
          </v-icon>
          {{ isEditing ? 'Modifier l\'élève' : 'Nouvel élève' }}
        </span>
        <v-spacer></v-spacer>
        <v-btn icon variant="text" @click="closeDialog">
          <v-icon color="white">mdi-close</v-icon>
        </v-btn>
      </v-card-title>

      <v-card-text class="pa-6">
        <v-form ref="form" v-model="valid">
          <!-- Profile Image Upload -->
          <div class="text-center mb-6">
            <v-avatar size="120" class="profile-upload-avatar">
              <v-img 
                :src="previewImage || defaultImage" 
                cover
                @click="triggerFileInput"
                style="cursor: pointer"
              >
                <template v-slot:placeholder>
                  <div class="d-flex align-center justify-center fill-height">
                    <v-icon size="40" color="grey-lighten-2">mdi-camera</v-icon>
                  </div>
                </template>
              </v-img>
            </v-avatar>
            
            <input
              ref="fileInput"
              type="file"
              accept="image/*"
              @change="handleImageUpload"
              style="display: none"
            />
            
            <div class="mt-2">
              <v-btn 
                size="small" 
                variant="outlined" 
                @click="triggerFileInput"
                :loading="imageUploading"
              >
                <v-icon class="mr-1">mdi-camera</v-icon>
                Changer la photo
              </v-btn>
            </div>
          </div>

          <v-row>
            <!-- Student Information -->
            <v-col cols="12">
              <h3 class="text-h6 mb-4 text-primary">
                <v-icon class="mr-2">mdi-account</v-icon>
                Informations de l'élève
              </h3>
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="studentForm.first_name"
                label="Prénom *"
                :rules="nameRules"
                variant="outlined"
                prepend-inner-icon="mdi-account"
                required
              ></v-text-field>
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="studentForm.last_name"
                label="Nom de famille *"
                :rules="nameRules"
                variant="outlined"
                prepend-inner-icon="mdi-account"
                required
              ></v-text-field>
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="studentForm.date_of_birth"
                label="Date de naissance *"
                type="date"
                :rules="dateRules"
                variant="outlined"
                prepend-inner-icon="mdi-calendar"
                required
              ></v-text-field>
            </v-col>

            <v-col cols="12" md="6">
              <v-select
                v-model="studentForm.gender"
                label="Genre *"
                :items="genderOptions"
                :rules="requiredRules"
                variant="outlined"
                prepend-inner-icon="mdi-human-male-female"
                required
              ></v-select>
            </v-col>

            <v-col cols="12">
              <v-textarea
                v-model="studentForm.address"
                label="Adresse"
                variant="outlined"
                prepend-inner-icon="mdi-map-marker"
                rows="2"
              ></v-textarea>
            </v-col>

            <v-col cols="12">
              <v-textarea
                v-model="studentForm.medical_notes"
                label="Notes médicales"
                variant="outlined"
                prepend-inner-icon="mdi-medical-bag"
                rows="2"
                hint="Allergies, conditions médicales, etc."
              ></v-textarea>
            </v-col>

            <!-- Guardian Information -->
            <v-col cols="12">
              <v-divider class="my-4"></v-divider>
              <h3 class="text-h6 mb-4 text-primary">
                <v-icon class="mr-2">mdi-account-tie</v-icon>
                Informations du parent/tuteur
              </h3>
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="guardianForm.name"
                label="Nom complet *"
                :rules="nameRules"
                variant="outlined"
                prepend-inner-icon="mdi-account-tie"
                required
              ></v-text-field>
            </v-col>

            <v-col cols="12" md="6">
              <v-select
                v-model="guardianForm.relationship"
                label="Relation *"
                :items="relationshipOptions"
                :rules="requiredRules"
                variant="outlined"
                prepend-inner-icon="mdi-family-tree"
                required
              ></v-select>
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="guardianForm.phone"
                label="Téléphone *"
                :rules="phoneRules"
                variant="outlined"
                prepend-inner-icon="mdi-phone"
                required
              ></v-text-field>
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="guardianForm.email"
                label="Email"
                :rules="emailRules"
                variant="outlined"
                prepend-inner-icon="mdi-email"
              ></v-text-field>
            </v-col>

            <!-- Class Selection -->
            <v-col cols="12">
              <v-divider class="my-4"></v-divider>
              <h3 class="text-h6 mb-4 text-primary">
                <v-icon class="mr-2">mdi-school</v-icon>
                Inscription en classe
              </h3>
            </v-col>

            <v-col cols="12" md="6">
              <v-select
                v-model="selectedClassId"
                label="Classe *"
                :items="classOptions"
                :rules="requiredRules"
                variant="outlined"
                prepend-inner-icon="mdi-school"
                required
              ></v-select>
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model="academicYear"
                label="Année académique"
                variant="outlined"
                prepend-inner-icon="mdi-calendar-range"
                readonly
              ></v-text-field>
            </v-col>
          </v-row>
        </v-form>
      </v-card-text>

      <v-card-actions class="pa-6 pt-0">
        <v-spacer></v-spacer>
        <v-btn 
          variant="outlined" 
          @click="closeDialog"
          :disabled="loading"
        >
          Annuler
        </v-btn>
        <v-btn 
          color="primary" 
          @click="submitForm"
          :loading="loading"
          :disabled="!valid"
        >
          <v-icon class="mr-2">mdi-content-save</v-icon>
          {{ isEditing ? 'Mettre à jour' : 'Enregistrer' }}
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch } from 'vue'
import { useStudentsStore } from '../stores/students'
import { uploadProfileImage } from '../lib/supabase'
import type { Student, Guardian } from '../types'

interface Props {
  modelValue: boolean
  student?: Student
  guardian?: Guardian
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'saved': []
}>()

const store = useStudentsStore()

const dialog = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const form = ref()
const fileInput = ref<HTMLInputElement>()
const valid = ref(false)
const loading = ref(false)
const imageUploading = ref(false)
const previewImage = ref('')

const isEditing = computed(() => !!props.student?.id)

const studentForm = reactive<Omit<Student, 'id'>>({
  first_name: '',
  last_name: '',
  date_of_birth: '',
  gender: 'M',
  profile_image: 'default-avatar.png',
  address: '',
  medical_notes: ''
})

const guardianForm = reactive<Omit<Guardian, 'id' | 'student_id'>>({
  name: '',
  relationship: 'Parent',
  phone: '',
  email: '',
  address: '',
  is_primary: true
})

const selectedClassId = ref('')
const academicYear = ref('2024-2025')

const defaultImage = 'https://images.pexels.com/photos/1102341/pexels-photo-1102341.jpeg?auto=compress&cs=tinysrgb&w=400'

const genderOptions = [
  { title: 'Masculin', value: 'M' },
  { title: 'Féminin', value: 'F' }
]

const relationshipOptions = [
  'Parent', 'Père', 'Mère', 'Tuteur', 'Grand-parent', 'Oncle', 'Tante', 'Autre'
]

const classOptions = computed(() => 
  store.classes.map(cls => ({
    title: `${cls.name} (${cls.teacher_name || 'Pas d\'enseignant'})`,
    value: cls.id
  }))
)

const nameRules = [
  (v: string) => !!v || 'Ce champ est requis',
  (v: string) => v.length >= 2 || 'Au moins 2 caractères requis',
]

const dateRules = [
  (v: string) => !!v || 'Date de naissance requise',
  (v: string) => {
    const date = new Date(v)
    const today = new Date()
    const age = today.getFullYear() - date.getFullYear()
    return age >= 3 && age <= 25 || 'Âge doit être entre 3 et 25 ans'
  }
]

const phoneRules = [
  (v: string) => !!v || 'Numéro de téléphone requis',
  (v: string) => /^[+]?[\d\s\-()]+$/.test(v) || 'Format de téléphone invalide',
]

const emailRules = [
  (v: string) => !v || /.+@.+\..+/.test(v) || 'Format email invalide',
]

const requiredRules = [
  (v: string) => !!v || 'Ce champ est requis',
]

// Watch for prop changes to populate form
watch(() => props.student, (student) => {
  if (student) {
    Object.assign(studentForm, student)
    previewImage.value = student.profile_image !== 'default-avatar.png' ? student.profile_image || '' : ''
  }
}, { immediate: true })

watch(() => props.guardian, (guardian) => {
  if (guardian) {
    Object.assign(guardianForm, guardian)
  }
}, { immediate: true })

function triggerFileInput() {
  fileInput.value?.click()
}

async function handleImageUpload(event: Event) {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return

  // Validate file type
  if (!file.type.startsWith('image/')) {
    alert('Veuillez sélectionner une image valide')
    return
  }

  // Validate file size (max 5MB)
  if (file.size > 5 * 1024 * 1024) {
    alert('La taille de l\'image ne doit pas dépasser 5MB')
    return
  }

  // Create preview
  const reader = new FileReader()
  reader.onload = (e) => {
    previewImage.value = e.target?.result as string
  }
  reader.readAsDataURL(file)

  // Store file for later upload
  studentForm.profile_image = file.name
}

async function submitForm() {
  if (!form.value?.validate()) return

  loading.value = true
  
  try {
    let profileImageUrl = studentForm.profile_image

    // Handle image upload if there's a new image
    if (previewImage.value && previewImage.value.startsWith('data:')) {
      imageUploading.value = true
      // In a real implementation, you would upload to Supabase Storage
      // For now, we'll use a placeholder
      profileImageUrl = previewImage.value
    }

    const studentData = {
      ...studentForm,
      profile_image: profileImageUrl
    }

    if (isEditing.value && props.student?.id) {
      await store.updateStudent(props.student.id, studentData)
    } else {
      const newStudent = await store.createStudent(studentData, guardianForm)
      
      // Create enrollment if class is selected
      if (selectedClassId.value && newStudent.id) {
        await store.createEnrollment({
          student_id: newStudent.id,
          class_id: selectedClassId.value,
          status: 'pending',
          academic_year: academicYear.value
        })
      }
    }

    emit('saved')
    closeDialog()
  } catch (error) {
    console.error('Error saving student:', error)
  } finally {
    loading.value = false
    imageUploading.value = false
  }
}

function closeDialog() {
  dialog.value = false
  resetForm()
}

function resetForm() {
  Object.assign(studentForm, {
    first_name: '',
    last_name: '',
    date_of_birth: '',
    gender: 'M',
    profile_image: 'default-avatar.png',
    address: '',
    medical_notes: ''
  })
  
  Object.assign(guardianForm, {
    name: '',
    relationship: 'Parent',
    phone: '',
    email: '',
    address: '',
    is_primary: true
  })
  
  selectedClassId.value = ''
  previewImage.value = ''
  form.value?.resetValidation()
}
</script>

<style scoped>
.student-form-card {
  border-radius: 16px;
  overflow: hidden;
}

.profile-upload-avatar {
  border: 4px dashed rgba(var(--v-theme-primary), 0.3);
  transition: all 0.3s ease;
}

.profile-upload-avatar:hover {
  border-color: rgba(var(--v-theme-primary), 0.6);
  transform: scale(1.05);
}
</style>