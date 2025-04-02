# vim-launchpad

This plugin provides automatic zero-configuration "Build and Run" functionality in a language-agnostic way.
Vim by default ships with usable build support as per [:h :compiler](https://vimhelp.org/quickfix.txt.html#%3Acompiler) and [:h 'makeprg'](https://vimhelp.org/options.txt.html#%27makeprg%27). The goal is to not stray too far from this original idiomatic vim compiler support and leverage for example the builtin quickfix error jumping from [:h :cexpr](https://vimhelp.org/quickfix.txt.html#%3Acexpr), and then extend it in the following principles:
- Make the build step asynchronous
- Allow to launch the built program
- Require zero configuration for the common case
- Provide a reasonable interface (e.g. show program output)
- Add debugging integration with [vimspector](https://github.com/puremourning/vimspector)

# Installation

Using **vim-plug**:

```vim
Plug 'vimpostor/vim-launchpad'
```

# Alternatives

- [vim-dispatch](https://github.com/tpope/vim-dispatch)
- [asyncrun](https://github.com/skywind3000/asyncrun.vim)

These alternatives are good in their own rights, but do not provide an opinionated "just works" experience like this plugin does.
