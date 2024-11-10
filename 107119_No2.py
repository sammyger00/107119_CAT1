class Student:
    def __init__(self, name, student_id):
        self.name = name
        self.student_id = student_id
        self.assignments = {}
    
    def add_assignment(self, assignment_name, grade):
        """Adds an assignment with the given grade to the student's record."""
        self.assignments[assignment_name] = grade
        print(f"Added assignment '{assignment_name}' with grade {grade} for {self.name}.")
    
    def display_grades(self):
        """Displays all assignments and grades for the student."""
        if self.assignments:
            print(f"Grades for {self.name}:")
            for assignment, grade in self.assignments.items():
                print(f"- {assignment}: {grade}")
        else:
            print(f"{self.name} has no graded assignments.")


class Instructor:
    def __init__(self, name, course_name):
        self.name = name
        self.course_name = course_name
        self.students = []
    
    def add_student(self, student):
        """Adds a student to the course."""
        self.students.append(student)
        print(f"Added student {student.name} (ID: {student.student_id}) to the course {self.course_name}.")
    
    def assign_grade(self, student_id, assignment_name, grade):
        """Assigns a grade to a student for a specific assignment."""
        student = next((s for s in self.students if s.student_id == student_id), None)
        if student:
            student.add_assignment(assignment_name, grade)
        else:
            print(f"Student with ID {student_id} not found in course {self.course_name}.")
    
    def display_all_students_grades(self):
        """Displays all students in the course and their grades."""
        if self.students:
            print(f"Grades for all students in {self.course_name}:")
            for student in self.students:
                student.display_grades()
        else:
            print("No students enrolled in this course.")


# Example interactive code to demonstrate adding students and assigning grades

# Create an instructor and course
instructor = Instructor("Mr. Kiptoo", "Business Finance")

# Create sample students
student1 = Student("Brian", "S001")
student2 = Student("Kevin", "S002")

# Adding students to the course
print("---- Course Management System ----")
instructor.add_student(student1)
instructor.add_student(student2)

# Assigning grades
instructor.assign_grade("S001", "Assignment 1", 85)
instructor.assign_grade("S001", "Assignment 2", 90)
instructor.assign_grade("S002", "Assignment 1", 78)

# Displaying all students and their grades
instructor.display_all_students_grades()
