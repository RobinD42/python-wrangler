============================
Robin's Python Wrangler v2.0
============================

This project provides a handy script that will help you switch between
and use the many different Pythons that may be on your system. It can
deal with multiple full Python install trees as well as virtualenvs.
(This is accomplished by injecting an activate script into the full
Pythons so they can be activated the same way that a virtualenv can.)
The script can also be used with Cygwin's bash to switch between
multiple Windows Pythons or virtualenvs as well.

Please see the header in wrangler.sh for more details.


Installation
------------

1. Copy or link wrangler.sh someplace where you can have easy
access to it.

2. Create a folder in your home directory named .myPyEnv. Place one
file in this folder for each Python environment you want to be able to
switch to.  The name of the file is the name you will use on the
command line, and the contents of the file is the path to the root of
that environment.

3. (Optional) Create an alias that sources the activateEnv.sh script.
For example:

    alias wrangler='source ~/bin/wrangler.sh'

Even you can be a snake wrangler!
Have fun.

This isn't a real change, just testing...
This is not the PR you are looking for...

