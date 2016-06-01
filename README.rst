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

Please see the header in activateEnv.sh for more details.


Installation
------------

1. Copy or link activateEnv.sh someplace where you can have easy
access to it.

2. Create a Python script in your home directory named .myPyEnv. This
script will be run with an environment name on the command-line and
needs to write the path name of that environment to stdout. There is
an example given in this project folder that you can modify to your
needs if desired.

3. (Optional) Create an alias that sources the activateEnv.sh script.
For example:

    alias workon='source ~/bin/activateEnv.sh'

Even you can be a snake wrangler!
Have fun.
