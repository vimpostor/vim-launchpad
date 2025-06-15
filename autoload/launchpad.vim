let s:job_lines = []
let s:build_running = 0
let s:launch_buf = -1
let s:launch_running = 0
let s:job_killed = 0

func launchpad#init()
	let g:launchpad_options = extend(launchpad#default_options(), get(g:, 'launchpad_options', {}))

	let s:run = 0

	if g:launchpad_options.default_mappings
		nnoremap <silent> <Leader>r :call launchpad#run()<CR>
		nnoremap <silent> <F3> :call launchpad#stop(1)<CR>
	endif

	command LaunchpadBoilerplate call launchpad#boilerplate()
	command LaunchpadVimspectorGen call launchpad#vimspector#gen()
	command -nargs=1 -complete=customlist,launchpad#target_compl LaunchpadFocus call launchpad#focus_target(<q-args>)
endfunc

func launchpad#default_options()
	return #{
		\ autojump: 1,
		\ autoopenquickfix: "open",
		\ autosave: 1,
		\ closepreview: "auto",
		\ default_mappings: 1,
		\ filetype_mappings: launchpad#default_ft(),
	\ }
endfunc

func launchpad#default_ft()
	return #{
		\ c: ["cmake"],
		\ cmake: ["cmake"],
		\ cpp: ["cmake"],
		\ qml: ["cmake"],
		\ rust: ["cargo"],
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
	call launchpad#stop(0)
	cclose
	let s:job_lines = []
	if g:launchpad_options.autosave
		silent exe 'wa'
	endif
	echo 'Building...'
	call launchpad#lib#build()
	let s:build_running = 1
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
	let s:launch_running = launchpad#lib#launch()
endfunc

func launchpad#stop(toggle)
	if !s:launch_running
		if a:toggle
			" toggle if already stopped
			call launchpad#toggle_launch_out()
		else
			pclose
		endif
		if !s:build_running
			return
		endif
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
	let s:build_running = 0
	" add errors to quickfix-list
	call setqflist([], 'r', #{lines: s:job_lines, efm: &efm})
	if g:launchpad_options.autojump && a:s != 0 && getqflist(#{size: 1}).size
		cc
	endif
	if g:launchpad_options.autoopenquickfix != "noop"
		cwindow
		if g:launchpad_options.autoopenquickfix == "open"
			wincmd p
		endif
	endif

	call launchpad#util#oneline_hide()
	if a:s != 0
		call launchpad#util#notify('Build failed!')
		return
	endif
	echom 'Build done.'

	if s:run
		let s:run = 0
		call launchpad#launch()
		if s:launch_running
			call launchpad#util#oneline_show("Target running...")
		endif
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

func launchpad#toggle_launch_out()
	if bufwinid(s:launch_buf) + 1
		pclose
	elseif s:launch_buf + 1
		call launchpad#open_launch_out()
	endif
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
	if !filereadable(".launchpad.json")
		call filecopy(fnameescape(resolve(expand('<script>:p:h') . "/../doc/.launchpad.json")), ".launchpad.json")
	endif
	edit .launchpad.json
endfunc
