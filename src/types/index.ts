export interface Student {
  id?: string
  first_name: string
  last_name: string
  date_of_birth: string
  gender: 'M' | 'F'
  profile_image?: string
  address?: string
  medical_notes?: string
  created_at?: string
  updated_at?: string
}

export interface Guardian {
  id?: string
  student_id?: string
  name: string
  relationship: string
  phone: string
  email?: string
  address?: string
  is_primary: boolean
  created_at?: string
}

export interface Class {
  id?: string
  name: string
  level: string
  capacity: number
  academic_year: string
  teacher_name?: string
  description?: string
  created_at?: string
  updated_at?: string
}

export interface Enrollment {
  id?: string
  student_id: string
  class_id: string
  enrollment_date?: string
  status: 'pending' | 'approved' | 'rejected' | 'incomplete'
  academic_year: string
  notes?: string
  created_at?: string
  updated_at?: string
  student?: Student
  class?: Class
  guardians?: Guardian[]
}

export interface Payment {
  id?: string
  enrollment_id: string
  amount: number
  payment_method: string
  transaction_id: string
  status: 'pending' | 'completed' | 'failed' | 'refunded'
  payment_date?: string
  created_at?: string
}

export interface Profile {
  id?: string
  email: string
  full_name?: string
  role: 'parent' | 'secretary' | 'admin'
  avatar_url?: string
  created_at?: string
  updated_at?: string
}

export interface ApiResponse<T = any> {
  success: boolean
  data?: T
  message?: string
  error?: string
}