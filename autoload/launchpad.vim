let s:job_lines = []
let s:launch_buf = -1
let s:launch_running = 0
let s:job_killed = 0

func launchpad#init()
	let g:launchpad_options = extend(launchpad#default_options(), get(g:, 'launchpad_options', {}))

	let s:run = 0

	if g:launchpad_options.default_mappings
		nnoremap <silent> <Leader>r :call launchpad#run()<CR>
		nnoremap <silent> <F3> :call launchpad#stop()<CR>
	endif

	command LaunchpadBoilerplate call launchpad#boilerplate()
	command LaunchpadVimspectorGen call launchpad#vimspector#gen()
	command -nargs=1 -complete=customlist,launchpad#target_compl LaunchpadFocus call launchpad#focus_target(<q-args>)
endfunc

func launchpad#default_options()
	return #{
		\ autojump: 1,
		\ autoopenquickfix: 1,
		\ autosave: 1,
		\ closepreview: "auto",
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
	cclose
	let s:job_lines = []
	if g:launchpad_options.autosave
		silent exe 'wa'
	endif
	echo 'Building...'
	call launchpad#lib#build()
endfunc

func launchpad#run()
	let s:run = 1
	call launchpad#build()
endfunc

func launchpad#launch()
	if s:launch_buf >= 0
		" unload the last output buffer
		exe 'bdelete ' . s:launch_buf
		let s:launch_buf = -1
	endif
	let s:job_killed = 0
	call launchpad#lib#launch()
	let s:launch_running = 1
endfunc

func launchpad#stop()
	if !s:launch_running
		pclose
		return
	endif
	let s:job_killed = 1
	if has('nvim')
		call jobstop(s:job)
	else
		call job_stop(s:job)
	endif
endfunc

func launchpad#out_cb(channel, msg)
	if launchpad#lib#parse_output(a:msg)
		call launchpad#util#oneline_show(a:msg)
	else
		call add(s:job_lines, a:msg)
	endif
endfunc

func launchpad#build_cb(j, s)
	" add errors to quickfix-list
	call setqflist([], 'r', #{lines: s:job_lines, efm: &efm})
	if g:launchpad_options.autojump && getqflist(#{size: 1}).size
		cc
	endif
	if g:launchpad_options.autoopenquickfix
		cwindow
	endif

	if a:s != 0
		call launchpad#util#oneline_hide()
		call launchpad#util#notify('Build failed!')
		return
	endif
	echom 'Build done.'

	if s:run
		call launchpad#launch()
		let s:run = 0
		call launchpad#util#oneline_show("Target running...")
	else
		call launchpad#util#oneline_hide()
	endif
endfunc

func launchpad#close_preview(s)
	if g:launchpad_options.closepreview == "never"
		return
	endif
	if s:job_killed || !a:s || g:launchpad_options.closepreview == "always"
		pclose
	endif
endfunc

func launchpad#open_launch_out()
	exe s:launch_buf . 'pbuffer'
endfunc

func launchpad#launch_cb(j, s)
	let s:launch_running = 0
	call launchpad#util#oneline_hide()
	call launchpad#close_preview(a:s)
	echom 'Program quit with exit code ' . a:s
endfunc

func launchpad#launch_out_cb(channel, msg)
	if s:launch_buf < 0
		" create a scratch buffer
		let s:launch_buf = bufadd("")
		call setbufvar(s:launch_buf, "&buftype", "nofile")
		call setbufvar(s:launch_buf, "&bufhidden", "hide")
		call setbufvar(s:launch_buf, "&swapfile", 0)
		call launchpad#open_launch_out()
	endif
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

func launchpad#target_compl(a, l, p)
	return launchpad#lib#targets()->filter({_, v -> !stridx(v, a:a)})
endfunc

func launchpad#focus_target(n)
	call launchpad#lib#focus_target(indexof(launchpad#lib#targets(), {_, v -> a:n == v}))
endfunc

func launchpad#focus_target_popup()
	call launchpad#util#choose("Select target", launchpad#lib#targets(), 'launchpad#focus_callback')
endfunc

func launchpad#focus_callback(w, i)
	if a:i > 0
		call launchpad#lib#focus_target(a:i - 1)
	endif
endfunc

func launchpad#boilerplate()
	call filecopy(fnameescape(resolve(expand('<script>:p:h') . "/../doc/.launchpad.json")), ".launchpad.json")
	edit .launchpad.json
endfunc
