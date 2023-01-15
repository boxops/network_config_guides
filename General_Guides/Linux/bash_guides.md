# Environment Variables

BASH environment variables contain information about the current session. Environment
variables are available in all operating systems and are typically set when you open your
terminal from a configuration file associated with your login. You set these variables with
similar syntax to how you set them when programming. You do not often use these variables
directly, but the programs and applications you launch do. You can view all of your currently
set environment variables by entering the env command. Since there can be more entries
than you have room to display on a single terminal page, you can pipe the results to the
more command to pause between pages:

Shows all environment variables with page breaks:
```
$env | more
```

If you execute this command, you are likely to notice a lot of keywords with the = sign tied
to values. One environment variable that you use every time you execute a command is the
PATH variable. This is where your shell looks for executable files. If you add a new command
and can’t execute it, more than likely the place where the command was copied is not listed
in your PATH. To view any variable value, you can use the echo command and the variable
you want to view. You also need to tell BASH that it’s a variable by using the $ in front of it.
Here’s an example:
```
$ echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Applications/VMware
Fusion.app/Contents/Public:/opt/X11/bin
```
To add a new value to the PATH variable, you can’t just type $PATH=/new_directory
because the operating system reads the environment variables only when the terminal ses-
sion starts. To inform Linux that an environment variable needs to be updated, you use the
export command. This command allows you to append your additional path to BASH and
exists for the duration of the session. Make sure you add the : or , in front of your new
value, depending on your operating system. The following example is for a Linux-style OS:
```
$ export PATH=$PATH:/Home/chrijack/bin
```
When you end your terminal session, the changes you made are not saved. To retain the
changes, you need to write the path statement to your .bashrc (or .zshrc if using Z shell) pro-
file settings. Anything written here will be available anytime you launch a terminal. You can
simply copy, add the previous command to the end of the .bashrc with your favorite text
editor, or use the following command:
```
$ echo "export PATH=$PATH:/Home/chrijack/bin" >> .bashrc
```
This addition becomes active only after you close your current session or force it to reload
the variable. The source command can be used to reload the variables from the hidden con-
figuration file .bashrc:
```
$ source ~/.bashrc
```
The following command does the same thing as the previous one because . is also an alias for
the source command:
```
$ . ~/.bashrc
```
