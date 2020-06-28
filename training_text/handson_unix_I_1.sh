#!/bin/bash

# Author: Amitava Roy    
# Purpose: The document contains some of the basic commands of UNIX
#          examples of their usage.
# Date -
# Creation : August 9, 2018
# Last modification : August 9, 2018
#
# Usage -
# The document is for reference purpose only. If needed it can be used as
# bash handson_unix_I_1.sh  
# Some of the materials has been used from the book 
# Unix and Perl Primer for Biologists (Version 3.1.2 — October 2016) - Keith Bradnam & Ian Korf


# Unix keeps files arranged in a hierarchical structure. From the ‘top-level’ of the computer, 
# there will be a number of directories, each of which can contain files and subdirectories, 
# and each of those in turn can of course contain more files and directories and so on, 
# ad infinitum. It’s important to note that you will always be “in” a directory when using
# the terminal. The default behavior is that when you open a new terminal you start in your own 
# ’home” directory (containing files and directories that only you can modify).

ls

# There may be many hundreds of directories on any Unix machine, so how do you know which one 
# you are in? The command pwd will Print the Working Directory.

pwd

# To change directories in Unix, we use the cd command. We can use the pwd command to find
# out which directory we are in every time we change directory.

cd /bin
pwd
ls
cd
pwd
cd ..
pwd
cd ../..
pwd
cd
pwd

# The .. operator that we saw earlier can also be used with the ls command.
cd 
ls ../..

# If every Unix command has so many options, you might be wondering how you find out what they 
# are and what they do. Well, thankfully every Unix command has an associated ‘manual’ that you 
# can access by using the man command. E.g.

man ls
man cd
man man # yes even the man command has a manual page

# There are many, many different options for the ls command. Try out the following
ls -l
ls -R
ls -l -t -r
ls -lh

# If we want to make a new directory, we can use the mkdir command:

mkdir Temp1
ls
cd Temp1
mkdir Temp2
cd Temp2
pwd
cd ../../
mkdir Temp3

# You can remove an empty directory by rmdir

rmdir Temp3
rmdir Temp1 # it will not remove Temp1 as it is not an empty directory
rm -r Temp1 # will remove both Temp1 and the directories under it. 
            # Depending on your settings you ma have to use the option "rm -rf"

# In the last example we created the two temp directories in two separate steps. 
# If we had used the -p option of the mkdir command we could have done this in one step

mkdir -p Temp1/Temp2
ls Temp1
rm -r Temp1

# Saving keystrokes may not seem important, but the longer that you spend typing in a terminal 
# window, the happier you will be if you can reduce the time you spend at the keyboard. 
# Especially, as prolonged typing is not good for your body. So the best Unix tip to learn early 
# on is that you can tab complete the names of files and programs on most Unix
# systems. Type enough letters that uniquely identify the name of a file, directory or program 
# and press tab...Unix will do the rest.

# The Unix command touch will let us create a new, empty file. The touch command does other things 
# too, but for now we just want a couple of files to work with.
touch interesting.txt
touch boring.txt
ls
rm boring.txt #"use "rm -f" if "rm" options asks for your permission

# "rm" is the most dangerous Unix command you will ever learn!
# Potentially, rm is a very dangerous command; if you delete something with rm , you will not get 
# it back! It does not go into the trash or recycle can, it is permanently removed. It is possible 
# to delete everything in your home directory (all directories and subdirectories) with rm , 
# that is why it is such a dangerous command.
# Let me repeat that last part again. It is possible to delete EVERY file you have ever created 
# with the rm command. Later in the workshop we can go over some tricks to make the rm command
# less dangerous.

# We still have the interesting.txt file. Let’s assume that we want to move these files to a new 
# directory (‘Temp’). We will do this using the Unix mv (move) command:

mkdir Temp
mv interesting.txt Temp/
ls
ls Temp/

# Use touch to create three files called ‘nice’, ‘nicer’, and ‘nicest’ inside the Temp directory. I.e.
cd Temp
touch nice nicer nicest
ls nice*
ls nice?

# In the earlier example, the destination for the mv command was a directory name (Temp). 
# So we moved a file from its source location to a target location 
# (‘source’ and ‘target’ are important concepts for many Unix commands). But
# note that the target could have also been a (different) file name, rather than a directory. 
# E.g. let’s make a new file and move it whilst renaming it at the same time:


mv interesting.txt best.txt
ls

# Copying files with the cp (copy) command is very similar to moving them. 
# Remember to always specify a source and a target location. Let’s copy the best.txt  
# to interesting.txt

cp best.txt interesting.txt
ls

# Let us tidy up
cd ../
rm -rf Temp/


