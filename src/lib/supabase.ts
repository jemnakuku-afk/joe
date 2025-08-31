import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Helper function for file uploads
export async function uploadProfileImage(file: File, studentId: string): Promise<string> {
  const fileExt = file.name.split('.').pop()
  const fileName = `${studentId}.${fileExt}`
  const filePath = `profiles/${fileName}`

  const { error: uploadError } = await supabase.storage
    .from('student-profiles')
    .upload(filePath, file, { upsert: true })

  if (uploadError) {
    throw new Error(`Upload failed: ${uploadError.message}`)
  }

  const { data } = supabase.storage
    .from('student-profiles')
    .getPublicUrl(filePath)

  return data.publicUrl
}

// Helper function to delete profile image
export async function deleteProfileImage(imagePath: string): Promise<void> {
  const { error } = await supabase.storage
    .from('student-profiles')
    .remove([imagePath])

  if (error) {
    throw new Error(`Delete failed: ${error.message}`)
  }
}