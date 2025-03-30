func launchpad#util#notify(msg)
	echo a:msg
	if !has('nvim')
		call popup_notification(a:msg, #{col: 2})
	endif
endfunc
