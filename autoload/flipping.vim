if !has('python')
	echoerr "vim-flipping requires Vim compiled with python support"
endif

if exists('g:vim_flipping_loaded') && g:vim_flipping_loaded
	finish
endif
let g:vim_flipping_loaded = 1

if !exists('g:vim_flipping_mkdir')
	let g:vim_flipping_mkdir = 0
endif

if !exists('g:vim_flipping_substitutions')
	let g:vim_flipping_substitutions = {}
endif

function! flipping#flip()
python << PYTHON
from __future__ import print_function
import errno
import os
import re
import vim

def read_global_var(var):
    try:
        return vim.vars[var]
    except AttributeError:
        return vim.eval("g:{var}".format(var=var))

FILEPATH = vim.eval("expand('%:p')")
MKDIR_P  = str(read_global_var("vim_flipping_mkdir")) == "1"
SUBST    = read_global_var("vim_flipping_substitutions")

def main():
    try:
        switch(match(FILEPATH))
    except StandardError as ex:
        warn(ex)

def switch(path):
    """Switch to new buffer if 'path' is not 'None'.

    If buffer for 'path' has been opened already just move in
    with ':b', otherwise open a new buffer with ':e'.
    """
    if path:
        if path in map(lambda b: b.name, vim.buffers):
            vim.command(":b {path}".format(path=path))
        else:
            if MKDIR_P:
                mkdir_p(path)
            vim.command(":e {path}".format(path=path))
    else:
        warn("No matching file")

def mkdir_p(path):
    try:
        os.makedirs(os.path.dirname(path))
    except OSError as ex:
        if ex.errno == errno.EEXIST:
            pass
        else:
            raise ex

def match(path):
    """Return the first matching file from the list of patterns.
    """
    for pattern, replacement in SUBST.items():
        try:
            newpath, n = re.subn(pattern, replacement, path)
            if n > 0:
                return newpath
        except re.error as ex:
            error("{ex} in {pat}, {repl} pair".format(ex=ex, pat=pattern, repl=replacement))

class FlippingError(StandardError):
    pass

def warn(str):
    """Print a message to stderr with the plugin name prefix.
    """
    print("vim-flipping: {str}".format(str=str), file=sys.stderr)

def error(str):
    """Warn and exit.
    """
    warn(str)
    raise FlippingError("Terminated")

main()
PYTHON
endfunction
