# Python has many built-in functions, built-in constants, and so on.
# Print built-in functions

for i in dir(__builtins__):
    print(i)

# Getting Help
# The help() function is possibly the most important Python function you can learn. 
# If you can remember how to use help(), you hold the key to understanding most other functions.
# Common pitfall: when you're looking up a function, remember to pass in the name of the 
# function itself, and not the result of calling that function.

# Here is an example:
help(print)

# If you were looking for it, you might learn that print can take an argument called sep, 
# and that this describes what we put between all the other arguments when we print them.
print("Hello", "World", "!", sep="-")

# Defining functions
# Builtin functions are great, but we can only get so far with them before we need to start defining our own functions. Below is a simple example.
def least_difference(a, b, c):
    diff1 = abs(a - b)
    diff2 = abs(b - c)
    diff3 = abs(a - c)
    return min(diff1, diff2, diff3)

# This creates a function called least_difference, which takes three arguments, a, b, and c.
# The function body is indented, and contains three statements. 
# The first two calculate the differences between the arguments, 
# and the third returns the smallest of those differences.

# Is it clear what least_difference() does from the source code? If we're not sure, we can always try it out on a few examples:
print(
    least_difference(1, 10, 100),
    least_difference(1, 10, 10),
    least_difference(5, 6, 7), # Python allows trailing commas in argument lists. How nice is that?
)

# Or maybe the help() function can tell us something about it.
help(least_difference)

# Python isn't smart enough to read my code and turn it into a nice English description. 
# However, when I write a function, I can provide a description in what's called the docstring.
def least_difference(a, b, c):
    """Return the smallest difference between any two numbers
    among a, b and c.
    
    >>> least_difference(1, 5, -5)
    4
    """
    diff1 = abs(a - b)
    diff2 = abs(b - c)
    diff3 = abs(a - c)
    return min(diff1, diff2, diff3)

# The docstring is a triple-quoted string (which may span multiple lines) that comes 
# immediately after the header of a function. When we call help() on a function, it shows the docstring.
help(least_difference)

# Aside: The last two lines of the docstring are an example function call and result. 
# (The >>> is a reference to the command prompt used in Python interactive shells.) 
# Python doesn't run the example call - it's just there for the benefit of the reader. 
# The convention of including 1 or more example calls in a function's docstring is far 
# from universally observed, but it can be very effective at helping someone understand 
# your function. For a real-world example, see this docstring for the numpy function np.eye.

# Good programmers use docstrings unless they expect to throw away the code soon after it's 
# used (which is rare). So, you should start writing docstrings, too!

# Adding optional arguments with default values to the functions we define turns out to be pretty easy:
def greet(who="Colin"):
    print("Hello,", who)
    
greet()
greet(who="Kaggle")
# (In this case, we don't need to specify the name of the argument, because it's unambiguous.)
greet("world")

# Functions Applied to Functions
# Here's something that's powerful, though it can feel very abstract at first. You can supply functions as arguments to other functions. Some example may make this clearer:
def mult_by_five(x):
    return 5 * x

def call(fn, arg):
    """Call fn on arg"""
    return fn(arg)

def squared_call(fn, arg):
    """Call fn on the result of calling fn on arg"""
    return fn(fn(arg))

print(
    call(mult_by_five, 1),
    squared_call(mult_by_five, 1), 
    sep='\n', # '\n' is the newline character - it starts a new line
)



# Functions that operate on other functions are called "higher-order functions." 
# You probably won't write your own for a little while. But there are higher-order 
# functions built into Python that you might find useful to call.
# Here's an interesting example using the max function.
# By default, max returns the largest of its arguments. But if we pass in a function 
# using the optional key argument, it returns the argument x that maximizes key(x) (aka the 'argmax').
def mod_5(x):
    """Return the remainder of x after dividing by 5"""
    return x % 5

print(
    'Which number is biggest?',
    max(100, 51, 14),
    'Which number is the biggest modulo 5?',
    max(100, 51, 14, key=mod_5),
    sep='\n',
)
