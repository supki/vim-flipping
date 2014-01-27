if !has('python')
	echoerr "vim-flipping requires Vim compiled with python support"
endif

if exists('g:vim_flipping_loaded') && g:vim_flipping_loaded
	finish
endif
let g:vim_flipping_loaded = 1

func! flipping#flip()
python << PYTHON
import re
import vim

filename = vim.eval("expand('%:p')")
subst    = {
	r'src/Main.(l?)hs':       r'test/Spec.\1hs'
  , r'test/Spec.(l?)hs':      r'src/Main.\1hs'
  , r'src/(.+)(\.l?hs)':      r'test/\1Spec\2'
  , r'test/(.+)Spec(\.l?hs)': r'src/\1\2'
  , r'lib/(.+).rb':           r'spec/\1_spec.rb'
  , r'spec/(.+)_spec.rb':     r'lib/\1.rb'
}

def matching_file():
	"""Return the first matching file from the list of patterns
	"""
	for pattern, replacement in subst.items():
		newfile, n = re.subn(pattern, replacement, filename)
		if n > 0:
			return newfile

vim.command(":e {path}".format(path=matching_file()))
PYTHON
endfunction
