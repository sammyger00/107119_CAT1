class Book:
    def __init__(self, title, author):
        self.title = title
        self.author = author
        self.is_borrowed = False
    
    def mark_as_borrowed(self):
        """Marks the book as borrowed."""
        self.is_borrowed = True
    
    def mark_as_returned(self):
        """Marks the book as returned."""
        self.is_borrowed = False
    
    def __str__(self):
        return f"{self.title} by {self.author} (Borrowed: {self.is_borrowed})"


class LibraryMember:
    def __init__(self, name, member_id):
        self.name = name
        self.member_id = member_id
        self.borrowed_books = []
    
    def borrow_book(self, book):
        """Allows the member to borrow a book if it is available."""
        if not book.is_borrowed:
            book.mark_as_borrowed()
            self.borrowed_books.append(book)
            print(f"{self.name} has borrowed '{book.title}' by {book.author}.")
        else:
            print(f"Sorry, '{book.title}' is currently borrowed by someone else.")
    
    def return_book(self, book):
        """Allows the member to return a book if they have borrowed it."""
        if book in self.borrowed_books:
            book.mark_as_returned()
            self.borrowed_books.remove(book)
            print(f"{self.name} has returned '{book.title}' by {book.author}.")
        else:
            print(f"{self.name} does not have '{book.title}' borrowed.")
    
    def list_borrowed_books(self):
        """Lists all books currently borrowed by the member."""
        if self.borrowed_books:
            print(f"{self.name} has borrowed the following books:")
            for book in self.borrowed_books:
                print(f"- {book.title} by {book.author}")
        else:
            print(f"{self.name} has no borrowed books.")

# Example interactive code to demonstrate borrowing and returning books

# Create sample books
book1 = Book("2003", "Harry Potter and the Order of the Phoenix")
book2 = Book("The Hunger Games", "Suzanne Collins")
book3 = Book("The Letter for the King", "Tonke Dragt")

# Create a library member
member = LibraryMember("Joe", "LM001")

# Borrow and return process
print("---- Library Management System ----")
member.borrow_book(book1)
member.borrow_book(book2)
member.list_borrowed_books()

# Returning a book
member.return_book(book1)
member.list_borrowed_books()

# Trying to borrow a book that is already borrowed by someone else
member.borrow_book(book1)
member.borrow_book(book3)

# Final list of borrowed books
member.list_borrowed_books()
