# Implementing an Employee and Department Management System in Python with the specified requirements

class Employee:
    def __init__(self, name, employee_id, salary):
        self.name = name
        self.employee_id = employee_id
        self.salary = salary
    
    def display_details(self):
        """Displays the details of the employee."""
        print(f"Employee ID: {self.employee_id}, Name: {self.name}, Salary: ${self.salary}")
    
    def update_salary(self, new_salary):
        """Updates the employee's salary."""
        self.salary = new_salary
        print(f"Updated salary for {self.name} to ${self.salary}.")


class Department:
    def __init__(self, department_name):
        self.department_name = department_name
        self.employees = []
    
    def add_employee(self, employee):
        """Adds an employee to the department."""
        self.employees.append(employee)
        print(f"Added employee {employee.name} (ID: {employee.employee_id}) to {self.department_name} department.")
    
    def calculate_total_salary_expenditure(self):
        """Calculates and displays the total salary expenditure for the department."""
        total_salary = sum(emp.salary for emp in self.employees)
        print(f"Total salary expenditure for {self.department_name} department is: ${total_salary}")
        return total_salary
    
    def display_all_employees(self):
        """Displays all employees in the department."""
        if self.employees:
            print(f"Employees in {self.department_name} department:")
            for emp in self.employees:
                emp.display_details()
        else:
            print(f"No employees in the {self.department_name} department.")


# Example interactive code to demonstrate adding employees, updating salary, and displaying details

# Create a department
department = Department("Research and Development")

# Create sample employees
employee1 = Employee("Mark Maina", "E001", 50000)
employee2 = Employee("Victor Juma", "E002", 70000)

# Adding employees to the department
print("---- Employee and Department Management System ----")
department.add_employee(employee1)
department.add_employee(employee2)

# Display all employees in the department
department.display_all_employees()

# Update salary for an employee
employee1.update_salary(65000)

# Calculate and display total salary expenditure
department.calculate_total_salary_expenditure()
