let s:job_lines = []
let s:launch_lines = []

func launchpad#init()
	let g:launchpad_options = extend(launchpad#default_options(), get(g:, 'launchpad_options', {}))

	let s:run = 0

	if g:launchpad_options.default_mappings
		nnoremap <silent> <Leader>r :call launchpad#run()<CR>
	endif
endfunc

func launchpad#default_options()
	return #{
		\ autojump: 1,
		\ autoopenquickfix: 1,
		\ autosave: 1,
		\ default_mappings: 1,
	\ }
endfunc

func launchpad#job(cmd, opts)
	if has('nvim')
		let s:job = jobstart(a:cmd)
	else
		let options = extend(#{noblock: 1}, a:opts)
		let s:job = job_start(a:cmd, options)
	endif
endfunc

func launchpad#build()
	let s:job_lines = []
	if g:launchpad_options.autosave
		silent exe 'wa'
	endif
	call launchpad#lib#init()
	echo 'Building...'
	call launchpad#lib#build()
endfunc

func launchpad#run()
	let s:run = 1
	call launchpad#build()
endfunc

func launchpad#launch()
	let s:launch_lines = []
	call launchpad#lib#launch()
endfunc

func launchpad#build_cb(j, s)
	" add errors to quickfix-list
	if g:launchpad_options.autojump
		cexpr s:job_lines
	else
		cgetexpr s:job_lines
	endif
	if g:launchpad_options.autoopenquickfix
		cwindow
	endif

	if a:s != 0
		call launchpad#util#notify('Build failed!')
		return
	endif
	echom 'Build done.'

	if s:run
		call launchpad#launch()
		let s:run = 0
	endif
endfunc

func launchpad#launch_cb(j, s)
	echom 'Program quit with exit code ' . a:s
endfunc

func launchpad#out_cb(channel, msg)
	if !launchpad#lib#parse_output(a:msg)
		call add(s:job_lines, a:msg)
	endif
endfunc

func launchpad#launch_out_cb(channel, msg)
	echom a:msg
	call add(s:launch_lines, a:msg)
endfunc

func launchpad#build_progress(i, n)
	echo printf("Building %d/%d", a:i, a:n)
endfunc
