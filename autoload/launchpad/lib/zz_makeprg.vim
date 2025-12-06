func launchpad#lib#zz_makeprg#check()
	return len(&makeprg)
endfunc

func launchpad#lib#zz_makeprg#build()
	call launchpad#job(&makeprg, #{out_cb: function('launchpad#out_cb'), err_cb: function('launchpad#out_cb'), exit_cb: function('launchpad#build_cb')})
endfunc

func launchpad#lib#zz_makeprg#launch()
	return 1
endfunc

func launchpad#lib#zz_makeprg#parse_output(l)
	return 0
endfunc

func launchpad#lib#zz_makeprg#launch_cmd()
	return ""
endfunc

func launchpad#lib#zz_makeprg#launch_env()
	return {}
endfunc

func launchpad#lib#zz_makeprg#targets()
	return []
endfunc

func launchpad#lib#zz_makeprg#focus_target(i)
endfunc
