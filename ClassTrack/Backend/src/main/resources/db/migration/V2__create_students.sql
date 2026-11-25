CREATE TABLE students (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, teacher_id BIGINT NOT NULL, full_name VARCHAR(150) NOT NULL,
 roll_id VARCHAR(50) NOT NULL, class_name VARCHAR(100) NOT NULL, subject_group VARCHAR(100) NOT NULL,
 enrollment_date DATE NOT NULL, academic_notes TEXT, is_active BIT NOT NULL DEFAULT 1,
 created_at DATETIME(6) NOT NULL, updated_at DATETIME(6) NOT NULL,
 CONSTRAINT fk_student_teacher FOREIGN KEY(teacher_id) REFERENCES teachers(id),
 CONSTRAINT uq_teacher_roll UNIQUE(teacher_id,roll_id), INDEX ix_roster(teacher_id,is_active,full_name)
) ENGINE=InnoDB;
