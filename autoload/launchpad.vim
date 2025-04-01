let s:job_lines = []
let s:launch_lines = []
let s:launch_buf = 0
let s:launch_running = 0

func launchpad#init()
	let g:launchpad_options = extend(launchpad#default_options(), get(g:, 'launchpad_options', {}))

	let s:run = 0

	if g:launchpad_options.default_mappings
		nnoremap <silent> <Leader>r :call launchpad#run()<CR>
		nnoremap <silent> <Leader><F3> :call launchpad#stop()<CR>
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
	call launchpad#stop()
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
	let s:launch_running = 1
endfunc

func launchpad#stop()
	if !s:launch_running
		return
	endif
	if has('nvim')
		call jobstop(s:job)
	else
		call job_stop(s:job)
	endif
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
	let s:launch_running = 0
	pclose
	echom 'Program quit with exit code ' . a:s
endfunc

func launchpad#out_cb(channel, msg)
	if !launchpad#lib#parse_output(a:msg)
		call add(s:job_lines, a:msg)
	endif
endfunc

func launchpad#launch_out_cb(channel, msg)
	if empty(s:launch_lines)
		" create a scratch buffer
		let s:launch_buf = bufadd("")
		call setbufvar(s:launch_buf, "&buftype", "nofile")
		call setbufvar(s:launch_buf, "&bufhidden", "hide")
		call setbufvar(s:launch_buf, "&swapfile", 0)
		exe s:launch_buf . 'pbuffer'
	endif
	call add(s:launch_lines, a:msg)
	" append the line to the buffer
	if len(getbufoneline(s:launch_buf, '$'))
		call appendbufline(s:launch_buf, '$', a:msg)
	else
		call setbufline(s:launch_buf, '$', a:msg)
	endif
	let win = bufwinid(s:launch_buf)
	if line('.', win) == line('$', win) - 1
		" scroll to end if cursor was on last line
		call win_execute(win, "norm G")
	endif
endfunc

func launchpad#build_progress(i, n)
	echo printf("Building %d/%d", a:i, a:n)
endfunc
