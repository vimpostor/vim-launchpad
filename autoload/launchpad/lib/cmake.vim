func launchpad#lib#cmake#init()
	if filereadable('CMakeLists.txt')
		let g:build_cmd = 'cmake --build build'
		let g:launch_cmd = 'sh -c ' . fnameescape('$(find build -maxdepth 1 -type f -executable | head -1)')
		return 1
	endif
	return 0
endfunc

func launchpad#lib#cmake#build()
	call launchpad#job('cmake --build build', 'launchpad#build_cb')
endfunc

func launchpad#lib#cmake#launch()
	call launchpad#job(g:launch_cmd, 'launchpad#launch_cb')
endfunc
