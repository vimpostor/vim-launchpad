func launchpad#bisect#sequencer()
	call launchpad#run()
	call launchpad#util#choose("Bisection status", ["Good", "Bad", "Skip"], "launchpad#bisect#choose_callback")
endfunc

func launchpad#bisect#choose_callback(w, i)
	echom a:i
	if a:i > 0
		" the special exit code 125 is for git bisect skip as per man git-bisect(1)
		exe "cquit " . (a:i == 3 ? 125 : a:i - 1)
	endif
endfunc
