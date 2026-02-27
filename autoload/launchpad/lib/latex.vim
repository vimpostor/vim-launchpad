func launchpad#lib#latex#check()
	return len(glob("*.tex"))
endfunc

func launchpad#lib#latex#build()
	call launchpad#job("latexmk -pdf", #{err_cb: function('launchpad#out_cb'), exit_cb: function('launchpad#build_cb')})
endfunc

func launchpad#lib#latex#launch()
	return 0
endfunc

func launchpad#lib#latex#parse_output(l)
	return 0
endfunc

func launchpad#lib#latex#launch_cmd()
	return []
endfunc

func launchpad#lib#latex#launch_env()
	return {}
endfunc

func launchpad#lib#latex#targets()
	return []
endfunc

func launchpad#lib#latex#focus_target(i)
endfunc
