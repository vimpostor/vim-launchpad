let s:targets = []
let s:current_target = -1

func launchpad#lib#cargo#check()
	return filereadable('Cargo.toml')
endfunc

func launchpad#lib#cargo#build()
	call launchpad#job(printf("cargo build%s", s:current_target < 0 ? "" : "--bin " . s:targets[s:current_target]), #{err_cb: function('launchpad#out_cb'), exit_cb: function('launchpad#build_cb')})
endfunc

func launchpad#lib#cargo#launch()
	call launchpad#job(launchpad#lib#cargo#launch_cmd(), #{out_cb: function('launchpad#launch_out_cb'), err_cb: function('launchpad#launch_out_cb'), exit_cb: function('launchpad#launch_cb')})
endfunc

func launchpad#lib#cargo#parse_output(l)
	if !stridx(a:l, "   Compiling")
		return 1
	endif
	return 0
endfunc

func launchpad#lib#cargo#launch_cmd()
	return printf("cargo run%s", s:current_target < 0 ? "" : "--bin" . s:targets[s:current_target])
endfunc

func launchpad#lib#cargo#launch_env()
	return {}
endfunc

func launchpad#lib#cargo#targets()
	let s:targets = systemlist("cargo run --bin")->filter({_, v -> stridx(v, "    ") == 0})->map({_, v -> trim(v)})
	return s:targets
endfunc

func launchpad#lib#cargo#focus_target(i)
	let s:current_target = -1
endfunc
