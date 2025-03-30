let s:path = fnameescape(resolve(expand('<sfile>:p:h')) . '/lib')
let s:lib = ''

func launchpad#lib#dispatch(tgt, fn, ...)
	let args = []
	if a:0 > 0
		let args = a:1
	endif
	let Func = function(printf("launchpad#lib#%s#%s", a:tgt, a:fn), args)
	return Func()
endfunc

func launchpad#lib#init()
	if len(s:lib)
		return
	endif

	for d in readdir(s:path)
		let d = strpart(d, 0, strridx(d, '.'))
		if launchpad#lib#dispatch(d, "check")
			let s:lib = d
			return
		endif
	endfor

	echo "Unable to find a launch definition for the current project"
endfunc

func launchpad#lib#build()
	call launchpad#lib#dispatch(s:lib, "build")
endfunc

func launchpad#lib#launch()
	call launchpad#lib#dispatch(s:lib, "launch")
endfunc

func launchpad#lib#parse_output(l)
	" returns 1 if it consumes the event
	return launchpad#lib#dispatch(s:lib, "parse_output", [a:l])
endfunc
