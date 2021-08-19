if exists('g:loaded_launchpad') || !(has('nvim') || has('job'))
	finish
endif
let g:loaded_launchpad = 1

call launchpad#init()
