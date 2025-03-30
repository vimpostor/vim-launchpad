func launchpad#util#notify(msg)
	if has('nvim')
		echoe a:msg
	else
		call popup_notification(a:msg, {})
	endif
endfunc
