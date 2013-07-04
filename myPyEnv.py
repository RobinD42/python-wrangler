# -*- python -*-

import sys, os

# A simple map of environment names to installation prefixes or
# virtual env base paths.  On Windows the path names should use the
# cygwin path not the equivalent Windows path names.

envMap = {
    'Py26'      : '/Library/Frameworks/Python.framework/Versions/2.6',
    'Py27'      : '/Library/Frameworks/Python.framework/Versions/2.7',
    'Py32'      : '/Library/Frameworks/Python.framework/Versions/3.2',
    'Py33'      : '/Library/Frameworks/Python.framework/Versions/3.3',

    'System64'  : '~/Library/Enthought/Canopy_64bit/System',
    'User64'    : '~/Library/Enthought/Canopy_64bit/User',

    'test_virtualenv' : '~/PyVE/tester',
}


def main(args):
    if len(args) < 2:
        return 1
    
    if args[1] == '--list':
        maxwidth = reduce(max, [len(x) for x in envMap.keys()])
        for env in sorted(envMap.keys()):
            print('%s: %s' % (env.ljust(maxwidth+1), envMap[env]))
        return 0

    try:
        path = envMap[args[1]]
        if os.name == 'posix':
            path = os.path.abspath(
                os.path.expandvars(
                    os.path.expanduser(path)))
        sys.stdout.write(path)
        return 0
    except KeyError:
        return 1


if __name__ == '__main__':
    sys.exit( main(sys.argv) )
