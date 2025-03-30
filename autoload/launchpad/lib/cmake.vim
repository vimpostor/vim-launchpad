func launchpad#lib#cmake#check()
	return filereadable('CMakeLists.txt')
endfunc

func launchpad#lib#cmake#build()
	call launchpad#job('cmake --build build', #{out_cb: function('launchpad#out_cb'), exit_cb: function('launchpad#build_cb')})
endfunc

func launchpad#lib#cmake#launch()
	for f in readdirex("build")
		if f.type == "file" && f.perm[2] == 'x'
			call launchpad#job("build/" . f.name, #{exit_cb: function('launchpad#launch_cb')})
			return
		endif
	endfor

	echo "Unable to find a target to launch"
endfunc
