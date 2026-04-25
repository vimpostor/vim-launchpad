let s:targets = []
let s:current_target = -1

func launchpad#lib#cargo#check()
	return filereadable('Cargo.toml')
endfunc

func launchpad#lib#cargo#build()
	call launchpad#job(printf("cargo build%s", s:current_target < 0 ? "" : " --bin " . s:targets[s:current_target]), #{env: #{CARGO_TERM_PROGRESS_WHEN: 'always', CARGO_TERM_PROGRESS_WIDTH: '80'}, err_cb: function('launchpad#out_cb'), exit_cb: function('launchpad#build_cb')})
endfunc

func launchpad#lib#cargo#launch()
	call launchpad#job(launchpad#lib#cargo#launch_cmd(), #{out_cb: function('launchpad#launch_out_cb'), err_cb: function('launchpad#launch_out_cb'), exit_cb: function('launchpad#launch_cb')})
	return 1
endfunc

func launchpad#lib#cargo#parse_output(l)
	if !stridx(a:l, "   Compiling") || !stridx(a:l, "    Blocking")
		return 1
	elseif !stridx(a:l, "    Building ")
		let a = stridx(a:l, ']', 14) + 2
		let b = stridx(a:l, '/', a + 1)
		let x = strpart(a:l, a, b - a)
		let b += 1
		let y = strpart(a:l, b, stridx(a:l, ':', b + 1) - b)
		call launchpad#build_progress_cb(str2nr(x), str2nr(y))
		return 2
	endif
	return 0
endfunc

func launchpad#lib#cargo#launch_cmd()
	let targets = launchpad#lib#cargo#targets()
	let i = max([0, s:current_target])
	return i >= len(targets) ? ["cargo", "run"] : "target/debug/" . targets[i]
endfunc

func launchpad#lib#cargo#launch_env()
	return {}
endfunc

func launchpad#lib#cargo#targets()
	let s:targets = systemlist("cargo run --bin")->filter({_, v -> stridx(v, "    ") == 0})->map({_, v -> trim(v)})
	return s:targets
endfunc

func launchpad#lib#cargo#focus_target(i)
	let s:current_target = a:i
endfunc
