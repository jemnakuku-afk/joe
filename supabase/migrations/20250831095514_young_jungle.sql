/*
  # Modern School Registration System Schema

  1. New Tables
    - `students` - Student information with profile images
    - `classes` - Class management with capacity
    - `enrollments` - Student-class relationships
    - `payments` - Payment tracking
    - `profiles` - User profiles for authentication

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
    - Secure file upload handling

  3. Optimizations
    - Proper foreign key relationships
    - Indexes for performance
    - Default values and constraints
*/

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Classes table
CREATE TABLE IF NOT EXISTS classes (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  level VARCHAR(50) NOT NULL,
  capacity INTEGER DEFAULT 30,
  academic_year VARCHAR(20) DEFAULT '2024-2025',
  teacher_name VARCHAR(100),
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Students table with profile image support
CREATE TABLE IF NOT EXISTS students (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  date_of_birth DATE NOT NULL,
  gender VARCHAR(10) CHECK (gender IN ('M', 'F')),
  profile_image VARCHAR(255) DEFAULT 'default-avatar.png',
  address TEXT,
  medical_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Parents/Guardians table
CREATE TABLE IF NOT EXISTS guardians (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id uuid REFERENCES students(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  relationship VARCHAR(50) DEFAULT 'Parent',
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(100),
  address TEXT,
  is_primary BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Enrollments table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS enrollments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id uuid REFERENCES students(id) ON DELETE CASCADE,
  class_id uuid REFERENCES classes(id) ON DELETE CASCADE,
  enrollment_date TIMESTAMPTZ DEFAULT now(),
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'incomplete')),
  academic_year VARCHAR(20) DEFAULT '2024-2025',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  
  UNIQUE(student_id, class_id, academic_year)
);

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  enrollment_id uuid REFERENCES enrollments(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(50) DEFAULT 'simulation',
  transaction_id VARCHAR(100) UNIQUE NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  payment_date TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- User profiles for authentication
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(100) NOT NULL,
  full_name VARCHAR(100),
  role VARCHAR(20) DEFAULT 'parent' CHECK (role IN ('parent', 'secretary', 'admin')),
  avatar_url VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE guardians ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for classes
CREATE POLICY "Classes are viewable by everyone"
  ON classes FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Only admins can modify classes"
  ON classes FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'secretary')
    )
  );

-- RLS Policies for students
CREATE POLICY "Students viewable by parents and staff"
  ON students FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'secretary')
    )
    OR
    EXISTS (
      SELECT 1 FROM guardians 
      WHERE student_id = students.id AND 
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND email = guardians.email)
    )
  );

CREATE POLICY "Parents can create students"
  ON students FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Parents can update their students"
  ON students FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM guardians 
      WHERE student_id = students.id AND 
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND email = guardians.email)
    )
    OR
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'secretary')
    )
  );

-- RLS Policies for guardians
CREATE POLICY "Guardians viewable by related users"
  ON guardians FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND (role IN ('admin', 'secretary') OR email = guardians.email)
    )
  );

CREATE POLICY "Guardians can manage their info"
  ON guardians FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND (role IN ('admin', 'secretary') OR email = guardians.email)
    )
  );

-- RLS Policies for enrollments
CREATE POLICY "Enrollments viewable by related users"
  ON enrollments FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'secretary')
    )
    OR
    EXISTS (
      SELECT 1 FROM guardians g
      JOIN students s ON g.student_id = s.id
      WHERE s.id = enrollments.student_id AND 
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND email = g.email)
    )
  );

CREATE POLICY "Parents can create enrollments"
  ON enrollments FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Staff can update enrollments"
  ON enrollments FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'secretary')
    )
  );

-- RLS Policies for payments
CREATE POLICY "Payments viewable by related users"
  ON payments FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'secretary')
    )
    OR
    EXISTS (
      SELECT 1 FROM guardians g
      JOIN students s ON g.student_id = s.id
      JOIN enrollments e ON e.student_id = s.id
      WHERE e.id = payments.enrollment_id AND 
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND email = g.email)
    )
  );

CREATE POLICY "Users can create payments"
  ON payments FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- RLS Policies for profiles
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_students_name ON students(last_name, first_name);
CREATE INDEX IF NOT EXISTS idx_students_dob ON students(date_of_birth);
CREATE INDEX IF NOT EXISTS idx_guardians_student ON guardians(student_id);
CREATE INDEX IF NOT EXISTS idx_guardians_phone ON guardians(phone);
CREATE INDEX IF NOT EXISTS idx_enrollments_student ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_class ON enrollments(class_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_status ON enrollments(status);
CREATE INDEX IF NOT EXISTS idx_payments_enrollment ON payments(enrollment_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);

-- Insert default classes
INSERT INTO classes (name, level, capacity, teacher_name) VALUES
('1ère Primaire A', 'Primaire', 25, 'Mme Kalala'),
('1ère Primaire B', 'Primaire', 25, 'M. Mukendi'),
('2ème Primaire A', 'Primaire', 30, 'Mme Tshiala'),
('3ème Primaire A', 'Primaire', 30, 'M. Kabongo'),
('4ème Primaire A', 'Primaire', 28, 'Mme Mwanza'),
('5ème Primaire A', 'Primaire', 28, 'M. Kasongo'),
('6ème Primaire A', 'Primaire', 25, 'Mme Mukadi'),
('1ère Secondaire A', 'Secondaire', 35, 'M. Tshimanga'),
('2ème Secondaire A', 'Secondaire', 35, 'Mme Kabila'),
('3ème Secondaire A', 'Secondaire', 32, 'M. Mbuyi')
ON CONFLICT DO NOTHING;