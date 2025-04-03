" allow the user to overwrite any settings with a .launchpad.json file

let s:json = {}

func launchpad#lib#00_config#sanitize(c)
	if len(a:c) && a:c[0] == '~'
		return $HOME . strpart(a:c, 1)
	endif
	return a:c
endfunc

func launchpad#lib#00_config#sanitize_cmd(c)
	if type(a:c) == v:t_string
		return launchpad#lib#00_config#sanitize(a:c)
	endif
	return map(a:c, {_, v -> launchpad#lib#00_config#sanitize(v)})
endfunc

func launchpad#lib#00_config#check()
	if !filereadable('.launchpad.json')
		return 0
	endif
	let s:json = json_decode(readfile(".launchpad.json")->join())
	return 1
endfunc

func launchpad#lib#00_config#build()
	" TODO: Add support for multiple targets
	call launchpad#job(launchpad#lib#00_config#sanitize_cmd(s:json.targets[0].build.cmd), #{env: get(s:json.targets[0].build, "env", {}), out_cb: function('launchpad#out_cb'), exit_cb: function('launchpad#build_cb')})
endfunc

func launchpad#lib#00_config#launch()
	call launchpad#job(launchpad#lib#00_config#launch_cmd(), #{env: launchpad#lib#00_config#launch_env(), out_cb: function('launchpad#launch_out_cb'), err_cb: function('launchpad#launch_out_cb'), exit_cb: function('launchpad#launch_cb')})
endfunc

func launchpad#lib#00_config#parse_output(l)
	if s:json.targets[0].build->has_key("kind")
		let Func = function(printf("launchpad#lib#parse_output_%s", s:json.targets[0].build.kind), [a:l])
		return Func()
	endif
	return 0
endfunc

func launchpad#lib#00_config#launch_cmd()
	return launchpad#lib#00_config#sanitize_cmd(s:json.targets[0].launch.cmd)
endfunc

func launchpad#lib#00_config#launch_env()
	return launchpad#lib#00_config#sanitize_cmd(get(s:json.targets[0].launch, "env", {}))
endfunc
