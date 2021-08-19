let s:init = 0

func launchpad#lib#init()
	if s:init
		return
	endif

	if &filetype == 'cpp'
		call launchpad#lib#cmake#init()
	endif

	let s:init = 1
endfunc
