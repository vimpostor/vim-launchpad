let s:targets = []
let s:current_target = -1

func launchpad#lib#cmake#check()
	return filereadable('CMakeLists.txt')
endfunc

func launchpad#lib#cmake#build()
	call launchpad#job(printf("cmake --build build%s", s:current_target < 0 ? "" : " --target " . s:targets[s:current_target]), #{out_cb: function('launchpad#out_cb'), exit_cb: function('launchpad#build_cb')})
endfunc

func launchpad#lib#cmake#launch()
	let c = launchpad#lib#cmake#launch_cmd()
	if len(c)
		call launchpad#job(c, #{out_cb: function('launchpad#launch_out_cb'), err_cb: function('launchpad#launch_out_cb'), exit_cb: function('launchpad#launch_cb')})
	else
		echo "Unable to find a target to launch"
	endif
endfunc

func launchpad#lib#cmake#parse_output(l)
	return launchpad#lib#parse_output_ninja(a:l)
endfunc

func launchpad#lib#cmake#launch_cmd()
	for f in readdirex("build")
		if f.type == "file" && f.perm[2] == 'x' && (s:current_target < 0 || s:targets[s:current_target] == f.name)
			return "build/" . f.name
		endif
	endfor
	return ""
endfunc

func launchpad#lib#cmake#launch_env()
	return {}
endfunc

func launchpad#lib#cmake#targets()
	let s:targets = systemlist("ninja -C build -t targets all")->filter({_, v -> stridx(v, "EXECUTABLE") > stridx(v, ' ')})->map({_, v -> strpart(v, 0, stridx(v, ' ') - 1)})
	return s:targets
endfunc

func launchpad#lib#cmake#focus_target(i)
	let s:current_target = a:i
endfunc
