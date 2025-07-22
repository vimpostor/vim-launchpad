let s:path = fnameescape(resolve(expand('<sfile>:p:h')) . '/lib')
let s:lib = ''

func launchpad#lib#dispatch(tgt, fn, ...)
	if empty(a:tgt)
		return 0
	endif

	let args = []
	if a:0 > 0
		let args = a:1
	endif
	let Func = function(printf("launchpad#lib#%s#%s", a:tgt, a:fn), args)
	return Func()
endfunc

func launchpad#lib#init()
	let ft = get(g:launchpad_options.filetype_mappings, &filetype, readdir(s:path)->map({_, v -> strpart(v, 0, strridx(v, '.'))}))->insert("00_config")->uniq()
	for d in ft
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
	return launchpad#lib#dispatch(s:lib, "launch")
endfunc

func launchpad#lib#parse_output(l)
	" returns 1 if it consumes the event
	return launchpad#lib#dispatch(s:lib, "parse_output", [a:l])
endfunc

func launchpad#lib#launch_cmd()
	return launchpad#lib#dispatch(s:lib, "launch_cmd")
endfunc

func launchpad#lib#launch_env()
	return launchpad#lib#dispatch(s:lib, "launch_env")
endfunc

func launchpad#lib#targets()
	return launchpad#lib#dispatch(s:lib, "targets")
endfunc

func launchpad#lib#focus_target(i)
	return launchpad#lib#dispatch(s:lib, "focus_target", [a:i])
endfunc

func launchpad#lib#parse_output_ninja(l)
	if a:l !~# '^\[\d\+/\d\+\] '
		return 0
	endif
	let r = matchlist(a:l,  '^\[\(\d\+\)/\(\d\+\)\] ')
	call launchpad#build_progress(r[1], r[2])
	return 1
endfunc

call launchpad#lib#init()
