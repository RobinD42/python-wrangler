============================
Robin's Python Wrangler v2.0
============================

This project provides a handy script that will help you switch between
and use the many different Pythons that may be on your system. It can
deal with multiple full Python install trees as well as virtualenvs.
(This is accomplished by injecting an activate script into the full
Pythons so they can be activated the same way that a virtualenv can.)
In addition to working on Linux, OSX or other \*nix systems, the script 
can also be used on Windows with Cygwin's bash to switch between multiple 
Windows Pythons or virtualenvs.

Please see the header in wrangler.sh for more details.


Installation
------------

1. Copy or link wrangler.sh someplace where you can have easy
access to it.

2. Create a folder in your home directory named .myPyEnv. Each item in this
folder will refer to a Python environment that you want to be able to switch
to or manage with this tool. The items can be one of the following:

  * A file containing the full path to to the root of a Python environment.
  * A sym-link pointing to a Python environment.
  * A folder containing a Python environment.

The name of the item is the name you will use on the wrangler command line.

3. (Optional) Create an alias that sources the activateEnv.sh script.
For example:

    alias wrangler='source ~/bin/wrangler.sh'

Even you can be a snake wrangler!
Have fun.

.. image:: wrangler.jpg
   :align: center
