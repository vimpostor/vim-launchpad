let s:path = fnameescape(resolve(expand('<sfile>:p:h')) . '/lib')
let s:lib = 'dummy'
let s:overwrite_launch = ''

func launchpad#lib#dispatch(tgt, fn, ...)
	let args = []
	if a:0 > 0
		let args = a:1
	endif
	let Func = function(printf("launchpad#lib#%s#%s", a:tgt, a:fn), args)
	return Func()
endfunc

func launchpad#lib#list()
	return readdir(s:path)->map({_, v -> strpart(v, 0, strridx(v, '.'))})
endfunc

func launchpad#lib#init()
	let ft = get(g:launchpad_options.filetype_mappings, &filetype, launchpad#lib#list())->insert("00_config")->uniq()
	for d in ft
		if launchpad#lib#dispatch(d, "check")
			let s:lib = d
			return
		endif
	endfor

	echo "Unable to find a launch definition for the current project"
endfunc

func launchpad#lib#build()
	if len(s:overwrite_launch) && g:launchpad_options.focusskipsbuild
		" go straight to launch
		call timer_start(0, {a -> launchpad#build_cb(a, 0)})
		return
	endif

	call launchpad#lib#dispatch(s:lib, "build")
endfunc

func launchpad#lib#launch()
	if len(s:overwrite_launch)
		" custom hardcoded launch
		call launchpad#job(s:overwrite_launch, #{out_cb: function('launchpad#launch_out_cb'), err_cb: function('launchpad#launch_out_cb'), exit_cb: function('launchpad#launch_cb')})
		return 1
	endif

	return launchpad#lib#dispatch(s:lib, "launch")
endfunc

func launchpad#lib#parse_output(l)
	" returns 1 if it consumes the event
	return launchpad#lib#dispatch(s:lib, "parse_output", [a:l])
endfunc

func launchpad#lib#launch_cmd()
	return launchpad#lib#dispatch(s:lib, "launch_cmd")
endfunc

func launchpad#lib#cmdlist()
	let cmd = launchpad#lib#launch_cmd()
	if type(cmd) == v:t_string
		let cmd = [cmd]
	endif
	return cmd
endfunc

func launchpad#lib#cmdstr()
	return launchpad#lib#cmdlist()->join()
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

func launchpad#lib#overwrite_launch(l)
	let s:overwrite_launch = a:l
endfunc

func launchpad#lib#overwrite_lib(l)
	let s:lib = a:l
	" need to call a specific lib function to initialize the autoload
	if !launchpad#lib#dispatch(s:lib, "check")
		echoe "Warning: Unsupported project for " . s:lib
	endif
endfunc

func launchpad#lib#lib_compl(a, l, p)
	return launchpad#lib#list()->filter({_, v -> !stridx(v, a:a)})
endfunc

call launchpad#lib#init()
