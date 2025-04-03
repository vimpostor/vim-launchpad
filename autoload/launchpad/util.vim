func launchpad#util#choose(title, arr, callback)
	let l = len(a:arr)
	if l < 2
		call function(a:callback)(-1, -1 + l * 2)
		return
	endif

	if has('nvim')
		let buf = nvim_create_buf(0, 1)
		call nvim_buf_set_lines(buf, 0, -1, 1, a:arr)
		let win = nvim_open_win(buf, 1, #{relative: "cursor", row: 0, col: 0, title: a:title, title_pos: "center", border: "rounded", width: len(a:arr[0]), height: l, style: "minimal"})
		call nvim_buf_set_keymap(buf, "n", "<CR>", ':let a = line(".")<CR>:close<CR>:call ' . a:callback . '(-1, a)<CR>', #{})
	else
		call popup_menu(a:arr, #{title: a:title, line: "cursor+1", col: "cursor", pos: "topleft", callback: a:callback})
	endif
endfunc

func launchpad#util#notify(msg)
	echom a:msg
	if !has('nvim')
		call popup_notification(a:msg, #{col: 2})
	endif
endfunc
