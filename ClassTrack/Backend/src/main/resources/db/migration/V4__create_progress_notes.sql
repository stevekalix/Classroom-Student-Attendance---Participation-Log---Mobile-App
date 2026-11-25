CREATE TABLE progress_notes (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, student_id BIGINT NOT NULL, teacher_id BIGINT NOT NULL,
 category VARCHAR(50) NOT NULL, content TEXT NOT NULL,
 created_at DATETIME(6) NOT NULL, updated_at DATETIME(6) NOT NULL,
 CONSTRAINT fk_note_student FOREIGN KEY(student_id) REFERENCES students(id),
 CONSTRAINT fk_note_teacher FOREIGN KEY(teacher_id) REFERENCES teachers(id),
 INDEX ix_student_notes(student_id,updated_at), INDEX ix_teacher_notes(teacher_id,updated_at)
) ENGINE=InnoDB;
