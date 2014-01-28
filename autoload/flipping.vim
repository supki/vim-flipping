if !has('python')
	echoerr "vim-flipping requires Vim compiled with python support"
endif

if exists('g:vim_flipping_loaded') && g:vim_flipping_loaded
	finish
endif
let g:vim_flipping_loaded = 1

func! flipping#flip()
python << PYTHON
from __future__ import print_function
import errno
import os
import re
import vim

filepath = vim.eval("expand('%:p')")
subst    = {
    r'src/Main(\.l?hs)':      r'test/Spec\1'
  , r'test/Spec(\.l?hs)':     r'src/Main\1'
  , r'src/(.+)(\.l?hs)':      r'test/\1Spec\2'
  , r'test/(.+)Spec(\.l?hs)': r'src/\1\2'
  , r'lib/(.+).rb':           r'spec/\1_spec.rb'
  , r'spec/(.+)_spec.rb':     r'lib/\1.rb'
}

def switch(path):
	"""Switch to new buffer if 'path' is not 'None'.
	"""
	if path:
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
	for pattern, replacement in subst.items():
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

try:
	switch(match(filepath))
except StandardError as ex:
	warn(ex)
PYTHON
endfunction
