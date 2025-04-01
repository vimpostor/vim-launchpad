func launchpad#util#notify(msg)
	echom a:msg
	if !has('nvim')
		call popup_notification(a:msg, #{col: 2})
	endif
endfunc
