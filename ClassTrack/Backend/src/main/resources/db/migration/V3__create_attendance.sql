CREATE TABLE attendance (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, student_id BIGINT NOT NULL, attendance_date DATE NOT NULL,
 status VARCHAR(20) NOT NULL, created_at DATETIME(6) NOT NULL, updated_at DATETIME(6) NOT NULL,
 CONSTRAINT fk_attendance_student FOREIGN KEY(student_id) REFERENCES students(id),
 CONSTRAINT uq_attendance_day UNIQUE(student_id,attendance_date), INDEX ix_attendance_date(attendance_date),
 CONSTRAINT ck_attendance_status CHECK(status IN ('PRESENT','ABSENT','LATE'))
) ENGINE=InnoDB;
