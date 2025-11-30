func launchpad#vimspector#gen()
	if &filetype != "cpp" && &filetype != "c"
		echoe "Not supported for this filetype yet"
		return
	endif

	let json = json_encode(launchpad#vimspector#cpptools())
	let pretty = systemlist("jq", json)
	call writefile(v:shell_error ? [json] : pretty, ".vimspector.json")
endfunc

func launchpad#vimspector#cpptools()
	return #{configurations: #{Launch: #{adapter: "vscode-cpptools", configuration: #{request: "launch", program: launchpad#lib#cmdlist()[0], args: launchpad#lib#cmdlist()[1:], cwd: $PWD, environment: launchpad#vimspector#micore_environment(launchpad#lib#launch_env()), externalConsole: 1, MIMode: "gdb"}}}}
endfunc

func launchpad#vimspector#micore_environment(env)
	" MIcore is fucking retarded
	return mapnew(a:env, {k, v -> #{name: k, value: v}})->values()
endfunc
