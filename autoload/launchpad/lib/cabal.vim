let s:targets = []
let s:current_target = -1

func launchpad#lib#cabal#check()
	return len(glob("*.cabal"))
endfunc

func launchpad#lib#cabal#build()
	call launchpad#job(printf("cabal build%s", s:current_target < 0 ? "" : " " . s:targets[s:current_target]), #{out_cb: function('launchpad#out_cb'), err_cb: function('launchpad#out_cb'), exit_cb: function('launchpad#build_cb')})
endfunc

func launchpad#lib#cabal#launch()
	call launchpad#job(launchpad#lib#cabal#launch_cmd(), #{out_cb: function('launchpad#launch_out_cb'), err_cb: function('launchpad#launch_out_cb'), exit_cb: function('launchpad#launch_cb')})
	return 1
endfunc

func launchpad#lib#cabal#parse_output(l)
	let r = matchlist(a:l, '^\[\(\d\+\) of \(\d\+\)\] ')
	if len(r)
		call launchpad#build_progress_cb(str2nr(r[1]), str2nr(r[2]), #{})
		return 2
	endif
	return 0
endfunc

func launchpad#lib#cabal#launch_cmd()
	let targets = launchpad#lib#cabal#targets()
	let i = max([0, s:current_target])
	return i >= len(targets) ? ["cabal", "run"] : glob(printf("dist-newstyle/build/*/ghc-*/%1$s-*/x/%1$s/build/%1$s/%1$s", strpart(targets[i], 0, stridx(targets[i], ':'))))
endfunc

func launchpad#lib#cabal#launch_env()
	return {}
endfunc

func launchpad#lib#cabal#targets()
	let s:targets = systemlist("cabal target exes")->filter({_, v -> !stridx(v, " - ")})->map({_, v -> strpart(v, 3)})
	return s:targets
endfunc

func launchpad#lib#cabal#focus_target(i)
	let s:current_target = a:i
endfunc
