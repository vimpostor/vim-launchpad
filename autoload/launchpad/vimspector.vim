func launchpad#vimspector#gen()
	let mapping = #{
		\ c: "cpptools",
		\ cpp: "cpptools",
		\ rust: "codelldb",
	\ }
	if index(keys(mapping), &filetype) < 0
		echoe "Not supported for this filetype yet"
		return
	endif

	let json = json_encode(function("launchpad#vimspector#" . mapping[&filetype])())
	let pretty = systemlist("jq", json)
	call writefile(v:shell_error ? [json] : pretty, ".vimspector.json")
endfunc

func launchpad#vimspector#cpptools()
	return #{configurations: #{Launch: #{adapter: "vscode-cpptools", configuration: #{request: "launch", program: launchpad#lib#cmdlist()[0], args: launchpad#lib#cmdlist()[1:], cwd: $PWD, environment: launchpad#vimspector#micore_environment(launchpad#lib#launch_env()), externalConsole: 1, MIMode: "gdb"}}}}
endfunc

func launchpad#vimspector#codelldb()
	return #{configurations: #{launch: #{adapter: "CodeLLDB", configuration: #{request: "launch", program: launchpad#lib#cmdlist()[0]}}}}
endfunc

func launchpad#vimspector#micore_environment(env)
	" MIcore is fucking retarded
	return mapnew(a:env, {k, v -> #{name: k, value: v}})->values()
endfunc
