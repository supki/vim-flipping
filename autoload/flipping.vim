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
import re
import vim

filepath = vim.eval("expand('%:p')")
subst    = {
	r'src/Main.(l?)hs':       r'test/Spec.\1hs'
  , r'test/Spec.(l?)hs':      r'src/Main.\1hs'
  , r'src/(.+)(\.l?hs)':      r'test/\1Spec\2'
  , r'test/(.+)Spec(\.l?hs)': r'src/\1\2'
  , r'lib/(.+).rb':           r'spec/\1_spec.rb'
  , r'spec/(.+)_spec.rb':     r'lib/\1.rb'
}

def switch(path):
	"""Switch to new buffer if 'path' is not 'None'.
	"""
	if path:
		vim.command(":e {path}".format(path=path))
	else:
		print("vim-flipping: No matching file", file=sys.stderr)

def match(path):
	"""Return the first matching file from the list of patterns.
	"""
	for pattern, replacement in subst.items():
		newpath, n = re.subn(pattern, replacement, path)
		if n > 0:
			return newpath

switch(match(filepath))
PYTHON
endfunction
