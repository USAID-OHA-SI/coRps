RBBS - 5 Base R
================
Nada Petrovic
2022-02-28

## RBBS 5 - Base

In this R Building Blocks session, we will focus on understanding base R
and how it connects to the larger tidyverse. This session draws on
[Advanced R](https://adv-r.hadley.nz/index.html) and [Hands-On
Programming in R](https://rstudio-education.github.io/hopr/).

### Learning Objectives

-   Grounding/introduction to base R
-   Learn how base R defines and conceptualizes different types of data
    objects
-   Learn some basic tools for manipulating these objects
-   Connect to the larger tidyverse

### Recording

You can use [this
link](https://drive.google.com/file/d/1EzwZ2ESZb386AOJUpDjR6fifxN9j-pCt/view?usp=sharing)
to access today’s recording.

### Setup

For these sessions, we’ll be using RStudio which is an IDE, “Integrated
development environment” that makes it easier to work with R. For help
on getting set up and installing packages, please reference [this
guide](https://usaid-oha-si.github.io/corps/rbbs/2022/01/28/rbbs-0-setup.html).

### Load Packages

The beauty of base R is that you don’t need to load any extra packages.
All of the functions are already contained in R itself. However, we will
also be going over how some of the basic R functions connect to the
functions available in the tidyverse, so we recommend loading this set
of packages as well.

``` r
library(tidyverse) #install.packages("tidyverse")
```

### Introduction to base R

Base R is a package that contains the basic functions R requires to
function as a programming language: arithmetic, input/output, basic
programming support, etc. The contents of the base R package are
available through inheritance from any environment and don’t need to be
separately loaded. For a complete list of functions, use
`library(help = "base")` and see the [base R cheat
sheet](https://github.com/rstudio/cheatsheets/blob/main/base-r.pdf) for
a great summary of useful commands.

So why learn `base R` given the plethora of fancier functions that are
now available? Because it provides the underlying structures for all of
these more sophisticated packages and functions. Without R there would
be no [tidyverse](https://www.tidyverse.org/)! Additionally, the
tidyverse can be a little overwhelming – there are so many different
functions and packages to remember! Going back to basics in base R can
illuminate the organizing principles that underlie these packages and
can make it easier to put it all together.

We can think of numbers and characters as the atoms of base R, vectors
and strings as molecules, lists and data frames as stars, and galaxies
as functions and packages – building up the tidyverse from base R
step-by-step.

### Objects in R

Let’s start with the basics – by defining what an object is in R. It
turns out that in R **everything** is an object – vectors,lists, data
frames and even functions.

> <span style="color: black;"> **An object** is defined as a data
> structure having some attributes and methods which act on its
> attributes.</span>

This makes R very flexible and able to handle many situations and data
types. Base R also includes some pre-defined objects that are
particularly useful for working with mixed data types.

### Assigning names to objects

The assignment operator `<-` binds together a name and a value, or any
type of object. Names must use letters, digits, . and \_ but can’t begin
with \_ or a digit, nor use [reserved
words](https://rdrr.io/r/base/Reserved.html).

Below are two examples, one assigning a number and another a letter to
object x.

``` r
    x <- 3    # Value 3 is assigned to object x
    x <- "a"  # Character "a" is assigned to object x
```

As a note, there are multiple ways to signal equivalence in R. For our
purposes `<-` is used in most situations and `=` is used for input to
functions (e.g. `function(x=3, y=5)`).

### Learning more about objects in R

A few useful commands can help us understand the objects encountered in
R: The command `typeof()` returns the data type for vectors & object
type for more complex structures `str()` returns the structure. Finally
the `print()` command prints the contents of an object. See below for
some example output:

``` r
vec<-c(1,2,3)
typeof(vec) 
## [1] "double"
str(vec) ## Note: str=structure not string!
##  num [1:3] 1 2 3
print(vec) ## values contained in an object
## [1] 1 2 3
```

Another useful base R function is `list.files()`, which lists the names
of all the files in a particular directory whose names include a given
pattern.

### Data types in R

So let’s dive into the atoms of our R universe — the data types that the
more complicated objects consist of. Four common data types used in R
are:

<table>
<thead>
<tr>
<th style="text-align:left;">
Data types
</th>
<th style="text-align:left;">
Examples
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
doubles
</td>
<td style="text-align:left;">
2.5, 3.7, 8.1
</td>
</tr>
<tr>
<td style="text-align:left;">
integers
</td>
<td style="text-align:left;">
1, 5, 8
</td>
</tr>
<tr>
<td style="text-align:left;">
logicals
</td>
<td style="text-align:left;">
TRUE, FALSE
</td>
</tr>
<tr>
<td style="text-align:left;">
characters
</td>
<td style="text-align:left;">
a, b, c, abc
</td>
</tr>
</tbody>
</table>

Base R also includes a set of commands that allows us to learn what type
of variables we are dealing with, which can be particularly useful if
these variables are being read in from an existing data set, rather than
defined by the user.

``` r
is.character("hi")
## [1] TRUE
is.numeric ("hi")
## [1] FALSE
typeof("hi")
## [1] "character"
```

Variables can also be forced from one form to another — in this case the
number 5 can be viewed as a number or as the character “5.”

``` r
as.character(5)
## [1] "5"
as.numeric("5")
## [1] 5
as.logical(0)
## [1] FALSE
as.logical(1)  # Note that this will also be FALSE for any other non-zero value
## [1] TRUE
```

#### Data types in R: A detour into strings

Before moving on to vectors, let’s zoom in on strings, which are defined
as collections of characters. A string is enclosed inside a set of
quotes (e.g. `x<-"this is a string"`). We often need to work with this
data type, especially in the process of data cleaning. We may have data
that contains important information that needs to be extracted from a
longer string. Or we may want to combine strings together to create a
new variable or a plot title or label.

A few very useful commands for combining, manipulating and searching
strings can be found in base R. The `paste()` command combines
components into longer expressions, while `gsub()` replaces a chunk of
text within a string, and `grep()` locates smaller chunks of text within
a longer string or a vector of strings. These functions will never go
out of style, but the tidyverse package
[stringr](https://stringr.tidyverse.org/) includes many more
sophisticated functions that can be used to work with strings ([see
cheatsheet](https://evoldyn.gitlab.io/evomics-2018/ref-sheets/R_strings.pdf)).

``` r
paste("happy","birthday",sep='-') # The separation is a single space by default, but can be re-defined.
## [1] "happy-birthday"
vec<-c("happy","birthday") 
paste(vec, collapse=' ') # The collapse parameter turns a vector into a string.
## [1] "happy birthday"

gsub("sad","happy","sad birthday") # Replaces text within a string
## [1] "happy birthday"

grep("a",vec) # Function returns all vector components containing the letter "a"
## [1] 1 2
```

### Data objects in R

#### Data objects: one-dimensional vectors

Now that we’ve covered the data elements or atoms of the R universe,
let’s shift to vectors, the simplest object type and the molecules of
the base R universe.

> <span style="color: black;"> **Vectors** are 1-dimensional objects
> consisting of multiple data elements, all of which are the same type.
> Common vector types include two types of numeric vectors (integer and
> double) and two types of atomic vectors (logical and character).
> </span>

**Vectors are generated using the `c()` command,** which binds together
multiple elements.

``` r
#Numeric vectors
int_vec <- c(1L, 6L, 10L) # The `L` ensures numbers are saved as integers rather than doubles.
dbl_vec <- c(1, 2.5, 4.5)

#Atomic vectors
lgl_vec <- c(TRUE, FALSE)
chr_vec <- c("some", "strings")
```

Note that when the `c()` command receives inputs of different data
types, everything is cast as a character. But don’t worry, R has a
structure called a `list` that can help with this conundrum and will be
introduced later.

``` r
c(6,FALSE,"string") 
## [1] "6"      "FALSE"  "string"
```

##### Commands for working with vectors

A few base R commands are very helpful when working with vectors. For
example, the `rep()` and `seq()` commands can easily generate a vector
that repeats values or a vector that contains a sequence of values
defined by its boundaries and intervals. Two integers separated by `:` –
e.g. `1:5` will also generate a sequence of integers.

``` r
## Shortcuts for generating vectors
1:5
## [1] 1 2 3 4 5
rep(1:2,times=3); rep(1:2,each=3) # Parameters times/each define how the vector is constructed
## [1] 1 2 1 2 1 2
## [1] 1 1 1 2 2 2
seq(2,3,by=0.5)
## [1] 2.0 2.5 3.0
```

All of the arithmetic operations in R are vector-based and don’t require
loops to be calculated. Additionally `sort()` and `rev()` are helpful
functions with intuitive names. The `unique()` function returns all of
the unique values in a vector and can be used to quickly assess the
contents of a long vector of data. The function `table()` provides even
more information by counting the instances of these unique values.

``` r
## Math with vectors
vec<-c(1,2,3)
vec+vec; vec*vec; vec/vec; vec-vec
## [1] 2 4 6
## [1] 1 4 9
## [1] 1 1 1
## [1] 0 0 0

## Vector functions
sort(c(1,3,2)) 
## [1] 1 2 3
rev(c(1,2,3))
## [1] 3 2 1
unique(c(1,1,2)) 
## [1] 1 2
table(c(6,6,7))
## 
## 6 7 
## 2 1
```

#### Data Objects: multi-dimensional vectors

While vectors are one-dimensional, R can also handle two-dimensional
matrices as well as multi-dimensional arrays. Like vectors, these
objects can only contain one data type. However, some of these commands
will translate to data frames, a more flexible two-dimensional object
that will be introduced later. The commands below include the
two-dimensional and multi-dimensional versions of `names()`,`length()`
and `c()` – which provide information about the various dimensions of
the objects and bind together rows and columns.

<table>
<thead>
<tr>
<th style="text-align:left;">
Vectors
</th>
<th style="text-align:left;">
Matrices
</th>
<th style="text-align:left;">
Arrays
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
names()
</td>
<td style="text-align:left;">
rownames(), colnames()
</td>
<td style="text-align:left;">
dimnames()
</td>
</tr>
<tr>
<td style="text-align:left;">
length()
</td>
<td style="text-align:left;">
nrow(), ncol()
</td>
<td style="text-align:left;">
dim()
</td>
</tr>
<tr>
<td style="text-align:left;">
c()
</td>
<td style="text-align:left;">
rbind(), cbind()
</td>
<td style="text-align:left;">
abind::abind()
</td>
</tr>
<tr>
<td style="text-align:left;">
–
</td>
<td style="text-align:left;">
t()
</td>
<td style="text-align:left;">
aperm()
</td>
</tr>
<tr>
<td style="text-align:left;">
is.null(dim(x))
</td>
<td style="text-align:left;">
is.matrix()
</td>
<td style="text-align:left;">
is.array()
</td>
</tr>
</tbody>
</table>

### Data Objects: Factors

> <span style="color: black;"> **A factor** is an object that can
> contain only predefined values and is typically used to store
> categorical data. These pre-defined values are called **levels**.
> </span>

Factors are built on top of an integer vector with two attributes: the
“factor” class, which makes it behave differently from regular integer
vectors and the “levels”, which define set of allowed values. Factors
are useful when the universe of *possible* values is well-understood,
even if the values are not all represented in a specific data set.
Factors can be generated in base R via the `factor()` command and other
objects can be turned into vectors with `as.factor()` — but remember
that in this case there may be some missing levels not contained in your
data sample.

``` r
# Generating a factor
x <-factor(c("a", "b", "a", "b"),levels=c("a", "b", "c"))

# Transforming a vector into a factor
y<-c("a","b","a"); x <- as.factor(y)
levels(x)
## [1] "a" "b"

# An example that illustrates the difference between a vector and a factor when 
# some data values not represented in a data set
sex_char<-c("m", "m", "m"); table(sex_char)
## sex_char
## m 
## 3
sex_fac<-factor(sex_char, levels = c("m", "f")); table(sex_fac)
## sex_fac
## m f 
## 3 0
```

A few factor commands are also listed below. The `levels()` and
`factor()` commands allows for reassigning the names of levels
throughout the entire data set (e.g. switching from `m` to `male`) as
well as re-ordering levels. The reordering can be useful when a
different order than the default is preferable (e.g temporal rather than
alphabetical order for months). While factors a great data structure,
some of the base R commands for more sophisticated factor operations can
be confusing and the tidyverse package
[forcats](https://forcats.tidyverse.org/) has a lot to offer to fill
these gaps (see [cheat
sheet](https://raw.githubusercontent.com/rstudio/cheatsheets/main/factors.pdf).

``` r
# Useful commands for reassigning level names and reordering
levels(sex_fac)<-c("male", "female"); print(sex_fac) # forcats analogs fct_recode(), fct_relabel()
## [1] male male male
## Levels: male female
sex_fac<-factor(sex_fac, levels = c("female", "male")); print(sex_fac) # forcats analogs fct_relevel(), fct_reorder()
## [1] male male male
## Levels: female male
```

### Data Objects: Lists

Next I want to talk about lists, the stars in our universe, which are a
very flexible type of object.

> <span style="color: black;"> A **list** is an object in which each
> element can be any type – this includes objects that are vectors in
> themselves, including vectors of different lengths! This works because
> each element is actually a reference to another object. <span>

Why are lists so useful? Because they allow for working with mixed data
types and even object types. This finally solves our problem from the
section on vectors! The `list()` function preserves data types, unlike
`c()`

``` r
lst <- list(x=1:3, y="a", z=c(TRUE, FALSE, TRUE), q=c(2.3, 5.9))
str(lst)
## List of 4
##  $ x: int [1:3] 1 2 3
##  $ y: chr "a"
##  $ z: logi [1:3] TRUE FALSE TRUE
##  $ q: num [1:2] 2.3 5.9
```

Another useful feature of lists is that you can use them to efficiently
apply the same function to each list element, without having to write
many nested loops. In base R, `lapply()` and several related functions
also allow for some of these capabilities, but the tidyverse
[purrr](https://purrr.tidyverse.org/) package (see [cheat
sheet](https://github.com/rstudio/cheatsheets/blob/main/purrr.pdf)) has
many more options so I would suggest looking there. This includes
functions such as `detect()`, `keep()` and `append()`, which can
accomplish things that would be quite difficult in base R.

``` r
lst<-list(
     a=c(1,2,3),
     b=c(4,5))
lapply(lst, FUN=mean) # purrr analog includes map(l1,mean) and others
## $a
## [1] 2
## 
## $b
## [1] 4.5
unlist(lst) # purrr analog is flatten()
## a1 a2 a3 b1 b2 
##  1  2  3  4  5
```

### Data Objects: Data Frames

> <span style="color: black;"> A **data frame** is a special case of a
> list where all elements are the same length. Unlike matrices and
> arrays, the columns can contain different types of data (numeric,
> strings, factors etc.). Since each row corresponds to an observation,
> the length of the columns is always the same. <span>

Data frames can be generated using the `data.frame()` function and
defining each column.

``` r
# Generating a data frame consisting of two columns, one numeric and one character
df <- data.frame(col1=1:3,col2=c("a","b","c")) 
```

Additionally, when R reads in `.txt` and `.csv` files they are
automatically stored as data frames. Example functions:
`df <- read.table('file.txt')` `df <- read.csv('file.csv')`

There are many ways to call the columns and rows of a data frame in base
R. For example, using the `$`sign between the data frame name and column
name will do it (e.g. `df$col_name`). You can also dynamically add a
column to an existing data frame using the `$`, as seen below. Finally,
data frames can be subset by manually filtering the rows using logical
statements. The [dplyr](https://dplyr.tidyverse.org/) package in the
tidyverse has many more options for working with data frames (see cheat
sheet)\[<https://github.com/rstudio/cheatsheets/blob/main/data-transformation.pdf>\].

``` r
# Different ways to call a column in base R
df$col1; df[,1]; df[[1]] #dplyr analog pull(df,col1) 
## [1] 1 2 3
## [1] 1 2 3
## [1] 1 2 3

# Calling a row in base R
df[1,] #slice(df,1)
##   col1 col2
## 1    1    a

# Calling a cell
df[1,1]; df[[1]][1]; df$col1[1] 
## [1] 1
## [1] 1
## [1] 1

## Column names
names(df)
## [1] "col1" "col2"

## Create column
df$col3<-4:6 #dplyr analog is mutate(col3=4:6)

#Filter rows
df[df$col1==2,] #dplyr analog is filter(df,col1==2)
##   col1 col2 col3
## 2    2    b    5
```

#### Manipulating data frames

The commands for subsetting data frames build off commands for
subsetting vectors. A nice summary of both sets of commands is in the
[base R cheat
sheet](https://github.com/rstudio/cheatsheets/blob/main/base-r.pdf). A
few of the useful commands for vectors include:

``` r
# Examples for subsetting vectors
x<1:5
## [1] NA NA NA NA NA
x[-4] # Note that minus means not that element. 
## [1] a b a
## Levels: a b
x[x<3] # Elements can be susbset using logical operators
## [1] <NA> <NA> <NA>
## Levels: a b
x[x %in% c(1,3,5)] #The %in% command pulls a discrete subset of elements 
## factor(0)
## Levels: a b
```

The cheat sheet also includes a nice summary of commands for data
frames. Data frames inherit many matrix commands like `nrow()`, `ncol()`
as well as `cbind()` and `rbind()`. However, data frames are lists at
their core and therefore also be manipulated using commands that map
more closely onto lists such as `df$column` and `df[[2]]`, which extract
an element of a list, in this case a column.

### Summary

In summary, the logic and structures of base R commands provide us with
an architecture to understand the principles of the language. It can
help us do many basic functions easily and also understand how different
elements of the tidyverse relate to each other. Below is a visual
summary of various elements of base R and how they map onto the the
tidyverse.

\[20220406_petrovic_rbbs_5\_baseR_tidyverse_diagram.png\]

### Exercises for practice

The answer key is located at the bottom.

1)  How can indicator PrEP_CURR be modified to PrEP_CT using the gsub()
    command?

2)  What is the simplest way to create the vector: 1.0 1.0 1.0 1.5 1.5
    1.5 2.0 2.0 2.0 Bonus: What if I am only interested in only the
    unique elements of this vector, sorted in descending order and
    squared?

3)  Turn the vector into a character array and add “cm” to the values
    and then confirm that this is now a character array with length 3.

4)  Create a vector that includes 1 number, 1 character & 1 integer

5)  1)  Create a list that consists of: –the number 5, –the string
        “abcd”, –a vector of integers from 1:3 –a factor with levels
        “a”,“b” and “c”, but no observations o “c”

6)  2)  Use a function to list attributes of the components

7)  1)  Generate a data frame with 3 rows and 2 columns such that: –
        column 1 is named x and contains numbers 1,2,3 – column 2 is
        named y and contains letters t,c,a
    2)  Add column z, which is filled with zeros

8)  Write out “1 cat” using only baseR calls and paste() Bonus: call
    each y component using a different command

9)  1)  Pull out column x and then subset only the elements that are
        less than 3
    2)  Print only the row where x=1. Bonus: Print only the rows where y
        contains consonants

### Answer Key

``` r
# 1) How can indicator PrEP_CURR be modified to PrEP_CT using the gsub() command?

gsub("CURR","CT","PrEP_CURR")
## [1] "PrEP_CT"


# 2) What is the simplest way to create the vector: 1.0 1.0 1.0 1.5 1.5 1.5 2.0 2.0 2.0 
# Bonus: What if I am only interested in only the unique elements of this vector, 
# sorted in descending order and squared? 

vec<-rep(seq(1,2,by=0.5),each=3); print(vec)
## [1] 1.0 1.0 1.0 1.5 1.5 1.5 2.0 2.0 2.0

# Bonus:
vec<-rev(unique(vec))
vec*vec
## [1] 4.00 2.25 1.00


# 3) Turn the vector into a character array and add "cm" to the values and then
#    confirm that this is now a character array with length 3.

vec<-paste(as.character(vec),"cm")
str(vec)
##  chr [1:3] "2 cm" "1.5 cm" "1 cm"


# 4) Create a vector that includes 1 number, 1 character & 1 integer

# TRICK QUESTION!!! A vector cannot include mixed types so the c() command will
# cast everything as a character. A list can have mixed types and is created with
# the list() command

c(3.5,1L,"a")
## [1] "3.5" "1"   "a"
list(3.5,1L,"a")
## [[1]]
## [1] 3.5
## 
## [[2]]
## [1] 1
## 
## [[3]]
## [1] "a"


# 5) a) Create a list that consists of:
#          --the number 5, 
#          --the string "abcd", 
#          --a vector of integers from 1:3 
#          --a factor with levels "a","b" and "c", but no observations of "c" 
# 
# 5) b) Use a function to list attributes of the components 

ls1<-list(5,"abcd", 1:3, factor(c("a","a","b"),levels=c("a","b","c")))
str(ls1)
## List of 4
##  $ : num 5
##  $ : chr "abcd"
##  $ : int [1:3] 1 2 3
##  $ : Factor w/ 3 levels "a","b","c": 1 1 2


# 6) b) Generate a data frame with 3 rows and 2 columns such that:
#          -- column 1 is named x and contains numbers 1,2,3 
#          -- column 2 is named y and contains letters t,c,a 
# 6) b) Add column z, which is filled with zeros

df <- data.frame(x=1:3,y=c("t","c","a")); print(df)
##   x y
## 1 1 t
## 2 2 c
## 3 3 a
df$z<-0; print(df)
##   x y z
## 1 1 t 0
## 2 2 c 0
## 3 3 a 0


# 7) Write out "1 cat" using only baseR calls and paste()
# Bonus: call each y component using a different command

paste(df$x[1], paste(df$y[2], df[[2]][3], df[1,2], sep='')) 
## [1] "1 cat"


# 8) a) Pull out column x and then subset only the elements that are less than 3
#    b) Print only the row where x=1.
# Bonus: Print only the rows where y contains consonants

vec<-df$x; vec<-vec[vec<3]; print(vec)
## [1] 1 2

df[df$x==1,]
##   x y z
## 1 1 t 0

# Bonus
df[df$y %in% c("c","t"),]
##   x y z
## 1 1 t 0
## 2 2 c 0
```
