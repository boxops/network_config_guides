### Content referenced from learnpython.org

# Table of Contents

<!-- toc -->

## 1. Learn the Basics

- [Hello, World!](#hello-world)
- [Variables and Types](#variables-and-types)
- [Lists](#lists)
- [Basic Operators](#basic-operators)
- [String Formatting](#string-formatting)
- [Basic String Operations](#basic-string-operations)
- [Conditions](#conditions)
- [Loops](#loops)
- [Functions](#functions)
- [Classes and Objects](#classes-and-objects)
- [Dictionaries](#dictionaries)
- [Modules and Packages](#modules-and-packages)

## 2. Data Science Tutorials

- [Numpy Arrays](#numpy-arrays)
- [Pandas Basics](#pandas-basics)

## 3. Advanced Tutorials

- [Generators](#generators)
- [List Comprehensions](#list-comprehensions)
- [Lambda functions](#lambda-functions)
- [Multiple Function Arguments](#multiple-function-arguments)
- [Regular Expressions](#regular-expressions)
- [Exception Handling](#exception-handling)
- [Sets](#sets)
- [Serialization](#serialization)
- [Partial functions](#partial-functions)
- [Code Introspection](#code-introspection)
- [Closures](#closures)
- [Decorators](#decorators)
- [Map, Filter, Reduce](#map-filter-reduce)

<!-- tocstop -->

# Learn the Basics

## Hello, World!

To print a string in Python 3, just write:
```
print("This line will be printed.")
```
Python uses indentation for blocks, instead of curly braces. Both tabs and spaces are supported, but the standard indentation requires standard Python code to use four spaces. For example:
```
x = 1
if x == 1:
    # indented four spaces
    print("x is 1.")
```
## Variables and Types

### Numbers

To define an integer, use the following syntax:
```
myint = 7
print(myint)
```
To define a floating point number, you may use one of the following notations:
```
myfloat = 7.0
print(myfloat)
myfloat = float(7)
print(myfloat)
```

### Strings

Strings are defined either with a single quote or a double quotes.
```
mystring = 'hello'
print(mystring)
mystring = "hello"
print(mystring)
```
The difference between the two is that using double quotes makes it easy to include apostrophes (whereas these would terminate the string if using single quotes)
```
mystring = "Don't worry about apostrophes"
print(mystring)
```
Simple operators can be executed on numbers and strings:
```
one = 1
two = 2
three = one + two
print(three)

hello = "hello"
world = "world"
helloworld = hello + " " + world
print(helloworld)
```
Assignments can be done on more than one variable "simultaneously" on the same line like this:
```
a, b = 3, 4
print(a, b)
```
Mixing operators between numbers and strings is not supported:
```
# This will not work!
one = 1
two = 2
hello = "hello"

print(one + two + hello)
```

## Lists

Lists are very similar to arrays. They can contain any type of variable, and they can contain as many variables as you wish. Lists can also be iterated over in a very simple manner. Here is an example of how to build a list.
```
mylist = []
mylist.append(1)
mylist.append(2)
mylist.append(3)
print(mylist[0]) # prints 1
print(mylist[1]) # prints 2
print(mylist[2]) # prints 3

# prints out 1,2,3
for x in mylist:
    print(x)
```
Accessing an index which does not exist generates an exception (an error).
```
mylist = [1,2,3]
print(mylist[10])
```

## Basic Operators

### Arithmetic Operators

Just as any other programming languages, the addition, subtraction, multiplication, and division operators can be used with numbers.
```
number = 1 + 2 * 3 / 4.0
print(number)
```

Another operator available is the modulo (%) operator, which returns the integer remainder of the division. dividend % divisor = remainder.
```
remainder = 11 % 3
print(remainder)
```

Using two multiplication symbols makes a power relationship.
```
squared = 7 ** 2
cubed = 2 ** 3
print(squared)
print(cubed)
```

### Using Operators with Strings

Python supports concatenating strings using the addition operator:
```
helloworld = "hello" + " " + "world"
print(helloworld)
```

Python also supports multiplying strings to form a string with a repeating sequence:
```
lotsofhellos = "hello" * 10
print(lotsofhellos)
```

### Using Operators with Lists

Lists can be joined with the addition operators:
```
even_numbers = [2,4,6,8]
odd_numbers = [1,3,5,7]
all_numbers = odd_numbers + even_numbers
print(all_numbers)
```

Just as in strings, Python supports forming new lists with a repeating sequence using the multiplication operator:
```
print([1,2,3] * 3)
```

## String Formatting

Let's say you have a variable called "name" with your user name in it, and you would then like to print(out a greeting to that user.)
```
# This prints out "Hello, John!"
name = "John"
print("Hello, %s!" % name)
```

To use two or more argument specifiers, use a tuple (parentheses):
```
# This prints out "John is 23 years old."
name = "John"
age = 23
print("%s is %d years old." % (name, age))
```

Any object which is not a string can be formatted using the %s operator as well. The string which returns from the "repr" method of that object is formatted as the string. For example:
```
# This prints out: A list: [1, 2, 3]
mylist = [1,2,3]
print("A list: %s" % mylist)
```

Here are some basic argument specifiers you should know:
```
%s - String (or any object with a string representation, like numbers)
%d - Integers
%f - Floating point numbers
%.<number of digits>f - Floating point numbers with a fixed amount of digits to the right of the dot.
%x/%X - Integers in hex representation (lowercase/uppercase)
```

## Basic String Operations

Strings are bits of text. They can be defined as anything between quotes:
```
astring = "Hello world!"
astring2 = 'Hello world!'
```

As you can see, the first thing you learned was printing a simple sentence. This sentence was stored by Python as a string. However, instead of immediately printing strings out, we will explore the various things you can do to them. You can also use single quotes to assign a string. However, you will face problems if the value to be assigned itself contains single quotes. For example to assign the string in these bracket(single quotes are ' ') you need to use double quotes only like this
```
astring = "Hello world!"
print("single quotes are ' '")

print(len(astring))
```

That prints out 12, because "Hello world!" is 12 characters long, including punctuation and spaces.
```
astring = "Hello world!"
print(astring.index("o"))
```

That prints out 4, because the location of the first occurrence of the letter "o" is 4 characters away from the first character. Notice how there are actually two o's in the phrase - this method only recognizes the first.

But why didn't it print out 5? Isn't "o" the fifth character in the string? To make things more simple, Python (and most other programming languages) start things at 0 instead of 1. So the index of "o" is 4.
```
astring = "Hello world!"
print(astring.count("l"))
```

For those of you using silly fonts, that is a lowercase L, not a number one. This counts the number of l's in the string. Therefore, it should print 3.
```
astring = "Hello world!"
print(astring[3:7])
```

This prints a slice of the string, starting at index 3, and ending at index 6. But why 6 and not 7? Again, most programming languages do this - it makes doing math inside those brackets easier.

If you just have one number in the brackets, it will give you the single character at that index. If you leave out the first number but keep the colon, it will give you a slice from the start to the number you left in. If you leave out the second number, it will give you a slice from the first number to the end.

You can even put negative numbers inside the brackets. They are an easy way of starting at the end of the string instead of the beginning. This way, -3 means "3rd character from the end".
```
astring = "Hello world!"
print(astring[3:7:2])
```

This prints the characters of string from 3 to 7 skipping one character. This is extended slice syntax. The general form is [start:stop:step].
```
astring = "Hello world!"
print(astring[3:7])
print(astring[3:7:1])
```

Note that both of them produce same output

There is no function like strrev in C to reverse a string. But with the above mentioned type of slice syntax you can easily reverse a string like this:
```
astring = "Hello world!"
print(astring[::-1])
```

This
```
astring = "Hello world!"
print(astring.upper())
print(astring.lower())
```

These make a new string with all letters converted to uppercase and lowercase, respectively.
```
astring = "Hello world!"
print(astring.startswith("Hello"))
print(astring.endswith("asdfasdfasdf"))
```

This is used to determine whether the string starts with something or ends with something, respectively. The first one will print True, as the string starts with "Hello". The second one will print False, as the string certainly does not end with "asdfasdfasdf".
```
astring = "Hello world!"
afewwords = astring.split(" ")
```

This splits the string into a bunch of strings grouped together in a list. Since this example splits at a space, the first item in the list will be "Hello", and the second will be "world!".

## Conditions

Python uses boolean logic to evaluate conditions. The boolean values True and False are returned when an expression is compared or evaluated. For example:
```
x = 2
print(x == 2) # prints out True
print(x == 3) # prints out False
print(x < 3) # prints out True
```

Notice that variable assignment is done using a single equals operator "=", whereas comparison between two variables is done using the double equals operator "==". The "not equals" operator is marked as "!=".

### Boolean operators

The "and" and "or" boolean operators allow building complex boolean expressions, for example:
```
name = "John"
age = 23
if name == "John" and age == 23:
    print("Your name is John, and you are also 23 years old.")

if name == "John" or name == "Rick":
    print("Your name is either John or Rick.")
```

### The "in" operator

The "in" operator could be used to check if a specified object exists within an iterable object container, such as a list:
```
name = "John"
if name in ["John", "Rick"]:
    print("Your name is either John or Rick.")
```

Python uses indentation to define code blocks, instead of brackets. The standard Python indentation is 4 spaces, although tabs and any other space size will work, as long as it is consistent. Notice that code blocks do not need any termination.

Here is an example for using Python's "if" statement using code blocks:
```
statement = False
another_statement = True
if statement is True:
    # do something
    pass
elif another_statement is True: # else if
    # do something else
    pass
else:
    # do another thing
    pass
```

For example:
```
x = 2
if x == 2:
    print("x equals two!")
else:
    print("x does not equal to two.")
```

A statement is evaulated as true if one of the following is correct: 1. The "True" boolean variable is given, or calculated using an expression, such as an arithmetic comparison. 2. An object which is not considered "empty" is passed.

Here are some examples for objects which are considered as empty: 1. An empty string: "" 2. An empty list: [] 3. The number zero: 0 4. The false boolean variable: False

### The 'is' operator

Unlike the double equals operator "==", the "is" operator does not match the values of the variables, but the instances themselves. For example:
```
x = [1,2,3]
y = [1,2,3]
print(x == y) # Prints out True
print(x is y) # Prints out False
```

### The "not" operator

Using "not" before a boolean expression inverts it:
```
print(not False) # Prints out True
print((not False) == (False)) # Prints out False
```

## Loops

There are two types of loops in Python, for and while.

### The "for" loop

For loops iterate over a given sequence. Here is an example:
```
primes = [2, 3, 5, 7]
for prime in primes:
    print(prime)
```

For loops can iterate over a sequence of numbers using the "range" and "xrange" functions. The difference between range and xrange is that the range function returns a new list with numbers of that specified range, whereas xrange returns an iterator, which is more efficient. (Python 3 uses the range function, which acts like xrange). Note that the range function is zero based.
```
# Prints out the numbers 0,1,2,3,4
for x in range(5):
    print(x)

# Prints out 3,4,5
for x in range(3, 6):
    print(x)

# Prints out 3,5,7
for x in range(3, 8, 2):
    print(x)
```

### "while" loops

While loops repeat as long as a certain boolean condition is met. For example:
```
# Prints out 0,1,2,3,4

count = 0
while count < 5:
    print(count)
    count += 1  # This is the same as count = count + 1
```

### "break" and "continue" statements

break is used to exit a for loop or a while loop, whereas continue is used to skip the current block, and return to the "for" or "while" statement. A few examples:
```
# Prints out 0,1,2,3,4

count = 0
while True:
    print(count)
    count += 1
    if count >= 5:
        break

# Prints out only odd numbers - 1,3,5,7,9
for x in range(10):
    # Check if x is even
    if x % 2 == 0:
        continue
    print(x)
```

### Can we use "else" clause for loops?

Unlike languages like C,CPP.. we can use else for loops. When the loop condition of "for" or "while" statement fails then code part in "else" is executed. If a break statement is executed inside the for loop then the "else" part is skipped. Note that the "else" part is executed even if there is a continue statement.

Here are a few examples:
```
# Prints out 0,1,2,3,4 and then it prints "count value reached 5"

count=0
while(count<5):
    print(count)
    count +=1
else:
    print("count value reached %d" %(count))

# Prints out 1,2,3,4
for i in range(1, 10):
    if(i%5==0):
        break
    print(i)
else:
    print("this is not printed because for loop is terminated because of break but not due to fail in condition")
```

## Functions

### What are Functions?

Functions are a convenient way to divide your code into useful blocks, allowing us to order our code, make it more readable, reuse it and save some time. Also functions are a key way to define interfaces so programmers can share their code.

### How do you write functions in Python?

As we have seen on previous tutorials, Python makes use of blocks. A block is a area of code of written in the format of:
```
block_head:
    1st block line
    2nd block line
    ...
```

Where a block line is more Python code (even another block), and the block head is of the following format: block_keyword block_name(argument1,argument2, ...) Block keywords you already know are "if", "for", and "while".

Functions in python are defined using the block keyword "def", followed with the function's name as the block's name. For example:
```
def my_function():
    print("Hello From My Function!")
```

Functions may also receive arguments (variables passed from the caller to the function). For example:
```
def my_function_with_args(username, greeting):
    print("Hello, %s , From My Function!, I wish you %s"%(username, greeting))
```

Functions may return a value to the caller, using the keyword- 'return' . For example:
```
def sum_two_numbers(a, b):
    return a + b
```

### How do you call functions in Python?

Simply write the function's name followed by (), placing any required arguments within the brackets. For example, lets call the functions written above (in the previous example):
```
# Define our 3 functions
def my_function():
    print("Hello From My Function!")

def my_function_with_args(username, greeting):
    print("Hello, %s, From My Function!, I wish you %s"%(username, greeting))

def sum_two_numbers(a, b):
    return a + b

# print(a simple greeting)
my_function()

#prints - "Hello, John Doe, From My Function!, I wish you a great year!"
my_function_with_args("John Doe", "a great year!")

# after this line x will hold the value 3!
x = sum_two_numbers(1,2)
```

## Classes and Objects

Objects are an encapsulation of variables and functions into a single entity. Objects get their variables and functions from classes. Classes are essentially a template to create your objects.

A very basic class would look something like this:
```
class MyClass:
    variable = "blah"

    def function(self):
        print("This is a message inside the class.")
```

We'll explain why you have to include that "self" as a parameter a little bit later. First, to assign the above class(template) to an object you would do the following:
```
class MyClass:
    variable = "blah"

    def function(self):
        print("This is a message inside the class.")

myobjectx = MyClass()
```

Now the variable "myobjectx" holds an object of the class "MyClass" that contains the variable and the function defined within the class called "MyClass".

### Accessing Object Variables

To access the variable inside of the newly created object "myobjectx" you would do the following:
```
class MyClass:
    variable = "blah"

    def function(self):
        print("This is a message inside the class.")

myobjectx = MyClass()

myobjectx.variable
```

So for instance the below would output the string "blah":
```
class MyClass:
    variable = "blah"

    def function(self):
        print("This is a message inside the class.")

myobjectx = MyClass()

print(myobjectx.variable)
```

You can create multiple different objects that are of the same class(have the same variables and functions defined). However, each object contains independent copies of the variables defined in the class. For instance, if we were to define another object with the "MyClass" class and then change the string in the variable above:
```
class MyClass:
    variable = "blah"

    def function(self):
        print("This is a message inside the class.")

myobjectx = MyClass()
myobjecty = MyClass()

myobjecty.variable = "yackity"

# Then print out both values
print(myobjectx.variable)
print(myobjecty.variable)
```

### Accessing Object Functions

To access a function inside of an object you use notation similar to accessing a variable:
```
class MyClass:
    variable = "blah"

    def function(self):
        print("This is a message inside the class.")

myobjectx = MyClass()

myobjectx.function()
```

The above would print out the message, "This is a message inside the class."

### init()

The __init__() function, is a special function that is called when the class is being initiated. It's used for assigning values in a class.
```
class NumberHolder:

   def __init__(self, number):
       self.number = number

   def returnNumber(self):
       return self.number

var = NumberHolder(7)
print(var.returnNumber()) #Prints '7'
```

## Dictionaries

A dictionary is a data type similar to arrays, but works with keys and values instead of indexes. Each value stored in a dictionary can be accessed using a key, which is any type of object (a string, a number, a list, etc.) instead of using its index to address it.

For example, a database of phone numbers could be stored using a dictionary like this:
```
phonebook = {}
phonebook["John"] = 938477566
phonebook["Jack"] = 938377264
phonebook["Jill"] = 947662781
print(phonebook)
```

Alternatively, a dictionary can be initialized with the same values in the following notation:
```
phonebook = {
    "John" : 938477566,
    "Jack" : 938377264,
    "Jill" : 947662781
}
print(phonebook)
```

### Iterating over dictionaries

Dictionaries can be iterated over, just like a list. However, a dictionary, unlike a list, does not keep the order of the values stored in it. To iterate over key value pairs, use the following syntax:
```
phonebook = {"John" : 938477566,"Jack" : 938377264,"Jill" : 947662781}
for name, number in phonebook.items():
    print("Phone number of %s is %d" % (name, number))
```

### Removing a value

To remove a specified index, use either one of the following notations:
```
phonebook = {
   "John" : 938477566,
   "Jack" : 938377264,
   "Jill" : 947662781
}
del phonebook["John"]
print(phonebook)
```

or:
```
phonebook = {
   "John" : 938477566,
   "Jack" : 938377264,
   "Jill" : 947662781
}
phonebook.pop("John")
print(phonebook)
```

## Modules and Packages

In programming, a module is a piece of software that has a specific functionality. For example, when building a ping pong game, one module may be responsible for the game logic, and
another module draws the game on the screen. Each module consists of a different file, which may be edited separately.

### Writing modules

Modules in Python are just Python files with a .py extension. The name of the module is the same as the file name. A Python module can have a set of functions, classes, or variables defined and implemented. The example above includes two files:

mygame/

- mygame/game.py

- mygame/draw.py

The Python script game.py implements the game. It uses the function draw_game from the file draw.py, or in other words, the draw module that implements the logic for drawing the game on the screen.

Modules are imported from other modules using the import command. In this example, the game.py script may look something like this:
```
# game.py
# import the draw module
import draw

def play_game():
    ...

def main():
    result = play_game()
    draw.draw_game(result)

# this means that if this script is executed, then 
# main() will be executed
if __name__ == '__main__':
    main()
```

The draw module may look something like this:
```
# draw.py

def draw_game():
    ...

def clear_screen(screen):
    ...
```

In this example, the game module imports the draw module, which enables it to use functions implemented in that module. The main function uses the local function play_game to run the game, and then draws the result of the game using a function implemented in the draw module called draw_game. To use the function draw_game from the draw module, we need to specify in which module the function is implemented, using the dot operator. To reference the draw_game function from the game module, we need to import the draw module and then call draw.draw_game().

When the import draw directive runs, the Python interpreter looks for a file in the directory in which the script was executed with the module name and a .py suffix. In this case it will look for draw.py. If it is found, it will be imported. If it's not found, it will continue looking for built-in modules.

You may have noticed that when importing a module, a .pyc file is created. This is a compiled Python file. Python compiles files into Python bytecode so that it won't have to parse the files each time modules are loaded. If a .pyc file exists, it gets loaded instead of the .py file. This process is transparent to the user.

### Importing module objects to the current namespace

A namespace is a system where every object is named and can be accessed in Python. We import the function draw_game into the main script's namespace by using the from command.
```
# game.py
# import the draw module
from draw import draw_game

def main():
    result = play_game()
    draw_game(result)
```

You may have noticed that in this example, the name of the module does not precede draw_game, because we've specified the module name using the import command.

The advantages of this notation is that you don't have to reference the module over and over. However, a namespace cannot have two objects with the same name, so the import command may replace an existing object in the namespace.

### Importing all objects from a module

You can use the import * command to import all the objects in a module like this:
```
# game.py
# import the draw module
from draw import *

def main():
    result = play_game()
    draw_game(result)
```

This might be a bit risky as changes in the module may affect the module which imports it, but it is shorter, and doesn't require you to specify every object you want to import from the module.

### Custom import name

Modules may be loaded under any name you want. This is useful when importing a module conditionally to use the same name in the rest of the code.

For example, if you have two draw modules with slighty different names, you may do the following:
```
# game.py
# import the draw module
if visual_mode:
    # in visual mode, we draw using graphics
    import draw_visual as draw
else:
    # in textual mode, we print out text
    import draw_textual as draw

def main():
    result = play_game()
    # this can either be visual or textual depending on visual_mode
    draw.draw_game(result)
```

### Module initialization

The first time a module is loaded into a running Python script, it is initialized by executing the code in the module once. If another module in your code imports the same module again, it will not be loaded again, so local variables inside the module act as a "singleton," meaning they are initialized only once.

You can then use this to initialize objects. For example:
```
# draw.py

def draw_game():
    # when clearing the screen we can use the main screen object initialized in this module
    clear_screen(main_screen)
    ...

def clear_screen(screen):
    ...

class Screen():
    ...

# initialize main_screen as a singleton
main_screen = Screen()
```

### Extending module load path

There are a couple of ways to tell the Python interpreter where to look for modules, aside from the default local directory and built-in modules. You can use the environment variable PYTHONPATH to specify additional directories to look for modules like this:
```
PYTHONPATH=/foo python game.py
```

This executes game.py, and enables the script to load modules from the foo directory, as well as the local directory.

You may also use the sys.path.append function. Execute it before running the import command:
```
sys.path.append("/foo")
```

Now the foo directory has been added to the list of paths where modules are looked for.

### Exploring built-in modules

Check out the full list of built-in modules in the Python standard library here:
https://docs.python.org/3/library/

Two very important functions come in handy when exploring modules in Python - the dir and help functions.

To import the module urllib, which enables us to create read data from URLs, we import the module:
```
# import the library
import urllib

# use it
urllib.urlopen(...)
```

We can look for which functions are implemented in each module by using the dir function:
```
>>> import urllib
>>> dir(urllib)
['ContentTooShortError', 'FancyURLopener', 'MAXFTPCACHE', 'URLopener', '__all__', '__builtins__', 
'__doc__', '__file__', '__name__', '__package__', '__version__', '_ftperrors', '_get_proxies', 
'_get_proxy_settings', '_have_ssl', '_hexdig', '_hextochr', '_hostprog', '_is_unicode', '_localhost', 
'_noheaders', '_nportprog', '_passwdprog', '_portprog', '_queryprog', '_safe_map', '_safe_quoters', 
'_tagprog', '_thishost', '_typeprog', '_urlopener', '_userprog', '_valueprog', 'addbase', 'addclosehook', 
'addinfo', 'addinfourl', 'always_safe', 'basejoin', 'c', 'ftpcache', 'ftperrors', 'ftpwrapper', 'getproxies', 
'getproxies_environment', 'getproxies_macosx_sysconf', 'i', 'localhost', 'main', 'noheaders', 'os', 
'pathname2url', 'proxy_bypass', 'proxy_bypass_environment', 'proxy_bypass_macosx_sysconf', 'quote', 
'quote_plus', 'reporthook', 'socket', 'splitattr', 'splithost', 'splitnport', 'splitpasswd', 'splitport', 
'splitquery', 'splittag', 'splittype', 'splituser', 'splitvalue', 'ssl', 'string', 'sys', 'test', 'test1', 
'thishost', 'time', 'toBytes', 'unquote', 'unquote_plus', 'unwrap', 'url2pathname', 'urlcleanup', 'urlencode', 
'urlopen', 'urlretrieve']
```

When we find the function in the module we want to use, we can read more about it with the help function, using the Python interpreter:
```
help(urllib.urlopen)
```

### Writing packages

Packages are namespaces containing multiple packages and modules. They're just directories, but with certain requirements.

Each package in Python is a directory which MUST contain a special file called __init__.py. This file, which can be empty, indicates that the directory it's in is a Python package. That way it can be imported the same way as a module.

If we create a directory called foo, which marks the package name, we can then create a module inside that package called bar. Then we add the __init__.py file inside the foo directory.

To use the module bar, we can import it in two ways:
```
import foo.bar
```

or:
```
from foo import bar
```

In the first example above, we have to use the foo prefix whenever we access the module bar. In the second example, we don't, because we've imported the module to our module's namespace.

The __init__.py file can also decide which modules the package exports as the API, while keeping other modules internal, by overriding the __all__ variable like so:
```__init__.py:

__all__ = ["bar"]
```

# Data Science Tutorials

## Numpy Arrays

## Pandas Basics

# Advanced Tutorials

## Generators

## List Comprehensions

## Lambda functions

## Multiple Function Arguments

## Regular Expressions

## Exception Handling

## Sets

## Serialization

## Partial functions

## Code Introspection

## Closures

## Decorators

## Map, Filter, Reduce
