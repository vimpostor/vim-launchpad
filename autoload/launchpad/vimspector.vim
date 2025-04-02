func launchpad#vimspector#gen()
	if &filetype != "cpp" && &filetype != "c"
		" for the moment supported only for C/C++
		echoe "Not supported for this filetype yet"
		return
	endif

	let cmd = launchpad#lib#launch_cmd()
	call writefile([json_encode(#{configurations: #{Launch: #{adapter: "vscode-cpptools", configuration: #{request: "launch", program: cmd[0], args: cmd[1:], cwd: $PWD, env: launchpad#lib#launch_env(), externalConsole: 1, MIMode: "gdb"}}}})], ".vimspector.json")
endfunc
