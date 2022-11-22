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

\# To print a string in Python 3, just write:
```
print("This line will be printed.")
```
\# Python uses indentation for blocks, instead of curly braces. Both tabs and spaces are supported, but the standard indentation requires standard Python code to use four spaces. For example:
```
x = 1
if x == 1:
    # indented four spaces
    print("x is 1.")
```
## Variables and Types

\# To define an integer, use the following syntax:
```
myint = 7
print(myint)
```
\# To define a floating point number, you may use one of the following notations:
```
myfloat = 7.0
print(myfloat)
myfloat = float(7)
print(myfloat)
```
\# Strings are defined either with a single quote or a double quotes.
```
mystring = 'hello'
print(mystring)
mystring = "hello"
print(mystring)
```
\# The difference between the two is that using double quotes makes it easy to include apostrophes (whereas these would terminate the string if using single quotes)
```
mystring = "Don't worry about apostrophes"
print(mystring)
```
\# Simple operators can be executed on numbers and strings:
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
\# Assignments can be done on more than one variable "simultaneously" on the same line like this:
```
a, b = 3, 4
print(a, b)
```
\# Mixing operators between numbers and strings is not supported:
```
# This will not work!
one = 1
two = 2
hello = "hello"

print(one + two + hello)
```

## Lists

## Basic Operators

## String Formatting

## Basic String Operations

## Conditions

## Loops

## Functions

## Classes and Objects

## Dictionaries

## Modules and Packages

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
