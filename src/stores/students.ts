import { defineStore } from 'pinia'
import { supabase } from '../lib/supabase'
import type { Student, Guardian, Class, Enrollment, Payment } from '../types'

export const useStudentsStore = defineStore('students', {
  state: () => ({
    students: [] as Student[],
    classes: [] as Class[],
    enrollments: [] as Enrollment[],
    payments: [] as Payment[],
    loading: false,
    error: null as string | null,
  }),

  getters: {
    getStudentsByClass: (state) => (classId: string) => {
      const classEnrollments = state.enrollments.filter(e => e.class_id === classId)
      return classEnrollments.map(enrollment => {
        const student = state.students.find(s => s.id === enrollment.student_id)
        return { ...student, enrollment }
      }).filter(Boolean)
    },

    getEnrollmentsByStatus: (state) => (status: string) => {
      return state.enrollments.filter(e => e.status === status)
    },

    getPaymentStats: (state) => {
      const total = state.payments.length
      const completed = state.payments.filter(p => p.status === 'completed').length
      const pending = state.payments.filter(p => p.status === 'pending').length
      const totalAmount = state.payments
        .filter(p => p.status === 'completed')
        .reduce((sum, p) => sum + p.amount, 0)
      
      return { total, completed, pending, totalAmount }
    }
  },

  actions: {
    async fetchClasses() {
      this.loading = true
      try {
        const { data, error } = await supabase
          .from('classes')
          .select('*')
          .order('level', { ascending: true })
          .order('name', { ascending: true })

        if (error) throw error
        this.classes = data || []
        this.error = null
      } catch (error: any) {
        this.error = error.message
        console.error('Error fetching classes:', error)
      } finally {
        this.loading = false
      }
    },

    async fetchStudents() {
      this.loading = true
      try {
        const { data, error } = await supabase
          .from('students')
          .select(`
            *,
            guardians(*),
            enrollments(
              *,
              classes(*)
            )
          `)
          .order('last_name', { ascending: true })

        if (error) throw error
        this.students = data || []
        this.error = null
      } catch (error: any) {
        this.error = error.message
        console.error('Error fetching students:', error)
      } finally {
        this.loading = false
      }
    },

    async fetchEnrollments() {
      this.loading = true
      try {
        const { data, error } = await supabase
          .from('enrollments')
          .select(`
            *,
            students(*),
            classes(*),
            payments(*)
          `)
          .order('created_at', { ascending: false })

        if (error) throw error
        this.enrollments = data || []
        this.error = null
      } catch (error: any) {
        this.error = error.message
        console.error('Error fetching enrollments:', error)
      } finally {
        this.loading = false
      }
    },

    async createStudent(studentData: Omit<Student, 'id'>, guardianData: Omit<Guardian, 'id' | 'student_id'>) {
      this.loading = true
      try {
        // Create student
        const { data: student, error: studentError } = await supabase
          .from('students')
          .insert([studentData])
          .select()
          .single()

        if (studentError) throw studentError

        // Create guardian
        const { error: guardianError } = await supabase
          .from('guardians')
          .insert([{ ...guardianData, student_id: student.id }])

        if (guardianError) throw guardianError

        await this.fetchStudents()
        this.error = null
        return student
      } catch (error: any) {
        this.error = error.message
        console.error('Error creating student:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    async updateStudent(id: string, updates: Partial<Student>) {
      try {
        const { error } = await supabase
          .from('students')
          .update({ ...updates, updated_at: new Date().toISOString() })
          .eq('id', id)

        if (error) throw error
        await this.fetchStudents()
        this.error = null
      } catch (error: any) {
        this.error = error.message
        console.error('Error updating student:', error)
        throw error
      }
    },

    async createEnrollment(enrollmentData: Omit<Enrollment, 'id'>) {
      try {
        const { data, error } = await supabase
          .from('enrollments')
          .insert([enrollmentData])
          .select()
          .single()

        if (error) throw error
        await this.fetchEnrollments()
        this.error = null
        return data
      } catch (error: any) {
        this.error = error.message
        console.error('Error creating enrollment:', error)
        throw error
      }
    },

    async updateEnrollmentStatus(id: string, status: string, notes?: string) {
      try {
        const updates: any = { 
          status, 
          updated_at: new Date().toISOString() 
        }
        if (notes) updates.notes = notes

        const { error } = await supabase
          .from('enrollments')
          .update(updates)
          .eq('id', id)

        if (error) throw error
        await this.fetchEnrollments()
        this.error = null
      } catch (error: any) {
        this.error = error.message
        console.error('Error updating enrollment status:', error)
        throw error
      }
    },

    async createPayment(paymentData: Omit<Payment, 'id'>) {
      try {
        const { data, error } = await supabase
          .from('payments')
          .insert([paymentData])
          .select()
          .single()

        if (error) throw error
        
        // Update enrollment status if payment is completed
        if (paymentData.status === 'completed') {
          await this.updateEnrollmentStatus(paymentData.enrollment_id, 'approved')
        }
        
        this.error = null
        return data
      } catch (error: any) {
        this.error = error.message
        console.error('Error creating payment:', error)
        throw error
      }
    },

    async deleteStudent(id: string) {
      try {
        const { error } = await supabase
          .from('students')
          .delete()
          .eq('id', id)

        if (error) throw error
        await this.fetchStudents()
        this.error = null
      } catch (error: any) {
        this.error = error.message
        console.error('Error deleting student:', error)
        throw error
      }
    }
  }
})