func launchpad#init()
	let g:launchpad_options = extend(launchpad#default_options(), get(g:, 'launchpad_options', {}))

	let g:build_cmd = ''
	let g:launch_cmd = ''
	let s:run = 0

	if g:launchpad_options.default_mappings
		nnoremap <silent> <Leader>r :call launchpad#run()<CR>
	endif
endfunc

func launchpad#default_options()
	return #{
		\ autosave: 1,
		\ default_mappings: 1,
	\ }
endfunc

func launchpad#job(cmd, cb)
	if has('nvim')
		let s:job = jobstart(a:cmd)
	else
		let options = #{noblock: 1, exit_cb: function(a:cb)}
		let s:job = job_start(a:cmd, options)
	endif
endfunc

func launchpad#build()
	if g:launchpad_options.autosave
		silent exe 'wa'
	endif
	call launchpad#lib#init()
	echo 'Building...'
	call launchpad#job(g:build_cmd, 'launchpad#build_cb')
endfunc

func launchpad#run()
	let s:run = 1
	call launchpad#build()
endfunc

func launchpad#launch()
	call launchpad#job(g:launch_cmd, 'launchpad#launch_cb')
endfunc

func launchpad#build_cb(j, s)
	if a:s != 0
		echo 'Build failed!'
		return
	else
		echo 'Build done.'
	endif
	if s:run
		call launchpad#launch()
		let s:run = 0
	endif
endfunc

func launchpad#launch_cb(j, s)
	echo 'Program quit with exit code ' . a:s
endfunc

func launchpad#build_progress_cb(p)
	echo a:p
endfunc
