if exists("g:loaded_surround") || &cp || v:version <# 700
  finish
endif
let g:loaded_surround = 1
function! s:getchar()
  let c = getchar()
  if c =~# '^\d\+$'
    let c = nr2char(c)
  endif
  return c
endfunction
function! s:inputtarget()
  let c = s:getchar()
  while c =~# '^\d\+$'
    let c .= s:getchar()
  endwhile
  if c ==# " "
    let c .= s:getchar()
  endif
  if c =~# "\<Esc>\|\<C-C>\|\0"
    return ""
  else
    return c
  endif
endfunction
function! s:inputreplacement()
  let c = s:getchar()
  if c ==# " "
    let c .= s:getchar()
  endif
  if c =~# "\<Esc>" || c =~# "\<C-C>"
    return ""
  else
    return c
  endif
endfunction
function! s:beep()
  execute "norm! \<Esc>"
  return ""
endfunction
function! s:redraw()
  redraw
  return ""
endfunction
function! s:extractbefore(str)
  if a:str =~# '\r'
    return matchstr(a:str, '.*\ze\r')
  else
    return matchstr(a:str, '.*\ze\n')
  endif
endfunction
function! s:extractafter(str)
  if a:str =~# '\r'
    return matchstr(a:str, '\r\zs.*')
  else
    return matchstr(a:str, '\n\zs.*')
  endif
endfunction
function! s:fixindent(str, spc)
  let a:str = substitute(a:str, '\t', repeat(' ', &sw), 'g')
  let a:spc = substitute(a:spc, '\t', repeat(' ', &sw), 'g')
  let a:str = substitute(a:str, '\(\n\|\%^\).\@=', '\1' . a:spc, 'g')
  if !&et
    let a:str = substitute(a:str, '\s\{' . &ts . '\}', "\t", 'g')
  endif
  return a:str
endfunction
function! s:process(string)
  let i = 0
  for i in range(7)
    let repl_{i} = ''
    let m = matchstr(a:string, nr2char(i) . '.\{-\}\ze' . nr2char(i))
    if m !=# ''
      let m = substitute(strpart(m, 1), '\r.*', '', '')
      let repl_{i} = input(substitute(m, ':\s*$', '', '') . ': ')
    endif
  endfor
  let s = ""
  let i = 0
  while i <# strlen(a:string)
    let char = strpart(a:string, i, 1)
    if char2nr(char) <# 8
      let next = stridx(a:string, char, i + 1)
      if next ==# -1
        let s .= char
      else
        let insertion = repl_{char2nr(s:char)}
        let subs = strpart(a:string, i + 1, next - i - 1)
        let subs = matchstr(subs, '\r.*')
        while subs =~# '^\r.*\r'
          let sub = matchstr(subs, "^\r\\zs[^\r]*\r[^\r]*")
          let subs = strpart(subs, strlen(sub) + 1)
          let r = stridx(sub, "\r")
          let insertion = substitute(insertion, strpart(sub, 0, r), strpart(sub, r + 1), '')
        endwhile
        let s .= insertion
        let i = next
      endif
    else
      let s .= char
    endif
    let i += 1
  endwhile
  return s
endfunction
function! s:wrap(string, char, type, ...)
  let keeper = a:string
  let newchar = a:char
  let s:tag = ""
  let a:type = a:type
  let linemode = a:type ==# 'V' ? 1 : 0
  let special = a:0 ? a:1 : 0
  let before = ""
  let after = ""
  if a:type ==# "V"
    let initspaces = matchstr(keeper, '\%^\s*')
  else
    let initspaces = matchstr(getline('.'), '\%^\s*')
  endif
  let pairs = "b()B{}r[]a<>"
  let extraspace = ""
  if newchar =~# '^ '
    let newchar = strpart(newchar, 1)
    let extraspace = ' '
  endif
  let idx = stridx(pairs, newchar)
  if newchar ==# ' '
    let before = ''
    let after = ''
  elseif exists("b:surround_" . char2nr(s:newchar))
    let all = s:process(b:surround_{char2nr(s:newchar)})
    let before = s:extractbefore(all)
    let after = s:extractafter(all)
  elseif exists("g:surround_" . char2nr(s:newchar))
    let all = s:process(g:surround_{char2nr(s:newchar)})
    let before = s:extractbefore(all)
    let after = s:extractafter(all)
  elseif s:newchar ==# "p"
    let before = "\n"
    let after = "\n\n"
  elseif s:newchar ==# 's'
    let before = ' '
    let after = ''
  elseif s:newchar ==# ':'
    let before = ':'
    let after = ''
  elseif s:newchar =~# "[tT\<C-T><,]"
    let dounmapp = 0
    let dounmapb = 0
    if !maparg(">", "c")
      let dounmapb = 1
      execute "cn" . "oremap > <CR>"
    endif
    let default = ""
    if newchar ==# "T"
      if !exists("s:lastdel")
        let s:lastdel = ""
      endif
      let default = matchstr(s:lastdel, '<\zs.\{-\}\ze>')
    endif
    let tag = input("<", default)
    echo "<" . substitute(tag, '>*$', '>', '')
    if dounmapb
      silent! cunmap >
    endif
    let s:tag = tag
    if tag !=# ""
      let tag = substitute(tag, '>*$', '', '')
      let s:tag = tag . '>'
      let before = '<' . tag . '>'
      if tag =~# '/$'
        let after = ''
      else
        let after = '</' . substitute(tag, ' .*', '', '') . '>'
      endif
      if newchar ==# "\<C-T>" || newchar ==# ","
        if a:type ==# "v" || a:type ==# "V"
          let before .= "\n\t"
        endif
        if a:type ==# "v"
          let after = "\n" . after
        endif
      endif
    endif
  elseif s:newchar ==# 'l' || s:newchar ==# '\'
    let env = input('\begin{')
    let env = '{' . env
    let env .= s:closematch(env)
    echo '\begin' . env
    if env !=# ""
      let before = '\begin' . env
      let after = '\end' . matchstr(env, '[^}]*') . '}'
    endif
  elseif s:newchar ==# 'f' || s:newchar ==# 'F'
    let fnc = input('function: ')
    if fnc !=# ""
      let before = substitute(fnc, '($', '', '') . '('
      let after = ')'
      if newchar ==# 'F'
        let before .= ' '
        let after = ' ' . after
      endif
    endif
  elseif s:newchar ==# "\<C-F>"
    let fnc = input('function: ')
    let before = '(' . fnc . ' '
    let after = ')'
  elseif s:idx >=# 0
    let spc = (idx % 3) ==# 1 ? " " : ""
    let idx = idx / 3 * 3
    let before = strpart(pairs, idx + 1, 1) . spc
    let after = spc . strpart(pairs, idx + 2, 1)
  elseif s:newchar ==# "\<C-[>" || s:newchar ==# "\<C-]>"
    let before = "{\n\t"
    let after = "\n}"
  elseif s:newchar !~# '\a'
    let before = newchar
    let after = newchar
  else
    let before = ''
    let after = ''
  endif
  let after = substitute(after, '\n', '\n' . initspaces, 'g')
  if a:type ==# 'V' || (special && a:type ==# "v")
    let before = substitute(before, ' \+$', '', '')
    let after = substitute(after, '^ \+', '', '')
    if after !~# '^\n'
      let after = initspaces.after
    endif
    if keeper !~# '\n$' && after !~# '^\n'
      let keeper .= "\n"
    elseif s:keeper =~# '\n$' && s:after =~# '^\n'
      let after = strpart(after, 1)
    endif
    if before !~# '\n\s*$'
      let before .= "\n"
      if special
        let before .= "\t"
      endif
    endif
  endif
  if a:type ==# 'V'
    let before = initspaces.before
  endif
  if before =~# '\n\s*\%$'
    if a:type ==# 'v'
      let keeper = initspaces.keeper
    endif
    let padding = matchstr(before, '\n\zs\s\+\%$')
    let before = substitute(before, '\n\s\+\%$', '\n', '')
    let keeper = s:fixindent(keeper, padding)
  endif
  if a:type ==# 'V'
    let keeper = before.keeper.after
  elseif s:type =~# "^\<C-V>"
    let repl = substitute(before, '[\\~]', '\\&', 'g') . '\1' . substitute(after, '[\\~]', '\\&', 'g')
    let repl = substitute(repl, '\n', ' ', 'g')
    let keeper = substitute(keeper . "\n", '\(.\{-\}\)\(\n\)', repl . '\n', 'g')
    let keeper = substitute(keeper, '\n\%$', '', '')
  else
    let keeper = before.extraspace.keeper.extraspace.after
  endif
  return keeper
endfunction
function! s:wrapreg(reg, char, ...)
  let orig = getreg(a:reg)
  let type = substitute(getregtype(a:reg), '\d\+$', '', '')
  let special = a:0 ? a:1 : 0
  let _new = s:wrap(orig, a:char, type, special)
  call setreg(a:reg, _new, type)
endfunction
function! s:insert(...)
  let linemode = a:0 ? a:1 : 0
  let char = s:inputreplacement()
  while char ==# "\<CR>" || char ==# "\<C-S>"
    let linemode += 1
    let char = s:inputreplacement()
  endwhile
  if char ==# ""
    return ""
  endif
  let cb_save = &clipboard
  set clipboard-=unnamed clipboard-=unnamedplus
  let reg_save = @@
  call setreg('"', "\r", 'v')
  call s:wrapreg('"', char, linemode)
  if linemode && match(getreg('"'), '^\n\s*\zs.*') ==# 0
    call setreg('"', matchstr(getreg('"'), '^\n\s*\zs.*'), getregtype('"'))
  endif
  if exists("g:surround_insert_tail")
    call setreg('"', g:surround_insert_tail, "a" . getregtype('"'))
  endif
  if col('.') >=# col('$')
    norm! ""p
  else
    norm! ""P
  endif
  if linemode
    call s:reindent()
  endif
  norm! `]
  call search('\r', 'bW')
  let @@ = reg_save
  let &clipboard = cb_save
  return "\<Del>"
endfunction
function! s:reindent()
  if exists("b:surround_indent") ? b:surround_indent : (!exists("g:surround_indent") || g:surround_indent)
    silent norm! '[=']
  endif
endfunction
function! s:dosurround(...)
  let scount = v:count1
  let char = (a:0 ? a:1 : s:inputtarget())
  let spc = ""
  if char =~# '^\d\+'
    let scount = scount * matchstr(char, '^\d\+')
    let char = substitute(char, '^\d\+', '', '')
  endif
  if char =~# '^ '
    let char = strpart(char, 1)
    let spc = 1
  endif
  if char ==# 'a'
    let char = '>'
  endif
  if char ==# 'r'
    let char = ']'
  endif
  let newchar = ""
  if a:0 ># 1
    let newchar = a:2
    if newchar ==# "\<Esc>" || newchar ==# "\<C-C>" || newchar ==# ""
      return s:beep()
    endif
  endif
  let cb_save = &clipboard
  set clipboard-=unnamed clipboard-=unnamedplus
  let append = ""
  let original = getreg('"')
  let otype = getregtype('"')
  call setreg('"', "")
  let strcount = (scount ==# 1 ? "" : scount)
  if char ==# '/'
    execute 'norm! ' . strcount . '[/d' . strcount . ']/'
  else
    execute 'norm! d' . strcount . 'i' . char
  endif
  let keeper = getreg('"')
  let okeeper = keeper
  if keeper ==# ""
    call setreg('"', original, otype)
    let &clipboard = cb_save
    return ""
  endif
  let oldline = getline('.')
  let oldlnum = line('.')
  if char ==# "p"
    call setreg('"', '', 'V')
  elseif s:char ==# "s" || s:char ==# "w" || s:char ==# "W"
    call setreg('"', '')
  elseif s:char =~# "[\"'`]"
    execute "norm! i \<Esc>d2i" . char
    call setreg('"', substitute(getreg('"'), ' ', '', ''))
  elseif s:char ==# '/'
    norm! "_x
    call setreg('"', '/**/', "c")
    let keeper = substitute(substitute(keeper, '^/\*\s\=', '', ''), '\s\=\*$', '', '')
  else
    call search('.', 'bW')
    execute "norm! da" . char
  endif
  let removed = getreg('"')
  let rem2 = substitute(removed, '\n.*', '', '')
  let oldhead = strpart(oldline, 0, strlen(oldline) - strlen(rem2))
  let oldtail = strpart(oldline, strlen(oldline) - strlen(rem2))
  let regtype = getregtype('"')
  if char =~# '[\[({<T]' || spc
    let keeper = substitute(keeper, '^\s\+', '', '')
    let keeper = substitute(keeper, '\s\+$', '', '')
  endif
  if col("']") ==# col("$") && col('.') + 1 ==# col('$')
    if oldhead =~# '^\s*$' && a:0 <# 2
      let keeper = substitute(keeper, '\%^\n' . oldhead . '\(\s*.\{-\}\)\n\s*\%$', '\1', '')
    endif
    let pcmd = "p"
  else
    let pcmd = "P"
  endif
  if line('.') + 1 <# oldlnum && regtype ==# "V"
    let pcmd = "p"
  endif
  call setreg('"', keeper, regtype)
  if newchar !=# ""
    call s:wrapreg('"', newchar)
  endif
  silent execute 'norm! ""'.pcmd.'`['
  if removed =~# '\n' || okeeper =~# '\n' || getreg('"') =~# '\n'
    call s:reindent()
  endif
  if getline('.') =~# '^\s\+$' && keeper =~# '^\s*\n'
    silent norm! cc
  endif
  call setreg('"', original, otype)
  let s:lastdel = removed
  let &clipboard = cb_save
  if newchar ==# ""
    silent! call repeat#set("\<Plug>Dsurround".char,scount)
  else
    silent! call repeat#set("\<Plug>Csurround".char.newchar.s:tag,scount)
  endif
endfunction
function! s:changesurround()
  let a = s:inputtarget()
  if a ==# ""
    return s:beep()
  endif
  let b = s:inputreplacement()
  if b ==# ""
    return s:beep()
  endif
  call s:dosurround(a, b)
endfunction
function! s:opfunc(type, ...)
  let char = s:inputreplacement()
  if char ==# ""
    return s:beep()
  endif
  let reg = '"'
  let sel_save = &selection
  let &selection = "inclusive"
  let cb_save = &clipboard
  set clipboard-=unnamed clipboard-=unnamedplus
  let reg_save = getreg(reg)
  let reg_type = getregtype(reg)
  let a:type = a:type
  if a:type ==# "char"
    silent exe 'norm! v`[o`]"'.reg.'y'
    let a:type = 'v'
  elseif a:type ==# "line"
    silent exe 'norm! `[V`]"'.reg.'y'
    let a:type = 'V'
  elseif a:type ==# "v" || a:type ==# "V" || a:type ==# "\<C-V>"
    let &selection = sel_save
    let ve = &virtualedit
    if !(a:0 && a:1)
      set virtualedit=
    endif
    silent exe 'norm! gv"'.reg.'y'
    let &virtualedit = ve
  elseif a:type =~# '^\d\+$'
    let a:type = 'v'
    silent exe 'norm! ^v'.a:type.'$h"'.reg.'y'
    if mode() ==# 'v'
      norm! v
      return s:beep()
    endif
  else
    let &selection = sel_save
    let &clipboard = cb_save
    return s:beep()
  endif
  let keeper = getreg(reg)
  if a:type ==# "v" && a:type !=# "v"
    let append = matchstr(keeper, '\_s\@<!\s*$')
    let keeper = substitute(keeper, '\_s\@<!\s*$', '', '')
  endif
  call setreg(reg, keeper, a:type)
  call s:wrapreg(reg, char, a:0 && a:1)
  if a:type ==# "v" && a:type !=# "v" && append !=# ""
    call setreg(reg, append, "ac")
  endif
  silent exe 'norm! gv'.(reg == '"' ? '' : '"' . reg).'p`['
  if a:type ==# 'V' || (getreg(reg) =~# '\n' && a:type ==# 'v')
    call s:reindent()
  endif
  call setreg(reg, reg_save, reg_type)
  let &selection = sel_save
  let &clipboard = cb_save
  if a:type =~# '^\d\+$'
    silent! call repeat#set("\<Plug>Y".(a:0 && a:1 ? "S" : "s")."surround".char.s:tag,a:type)
  else
    silent! call repeat#set("\<Plug>SurroundRepeat".char.s:tag)
  endif
endfunction
function! s:opfunc2(arg)
  call s:opfunc(a:arg, 1)
endfunction
function! s:closematch(str)
  let tail = matchstr(a:str, '.[^\[\](){}<>]*$')
  if tail =~# '^\[.\+'
    return "]"
  elseif s:tail =~# '^(.\+'
    return ")"
  elseif s:tail =~# '^{.\+'
    return "}"
  elseif s:tail =~# '^<.+'
    return ">"
  else
    return ""
  endif
endfunction
nnoremap <silent> <Plug>SurroundRepeat .
nnoremap <silent> <Plug>Dsurround  :<C-U>call <SID>dosurround(<SID>inputtarget())<CR>
nnoremap <silent> <Plug>Csurround  :<C-U>call <SID>changesurround()<CR>
nnoremap <silent> <Plug>Yssurround :<C-U>call <SID>opfunc(v:count1)<CR>
nnoremap <silent> <Plug>YSsurround :<C-U>call <SID>opfunc2(v:count1)<CR>
nnoremap <silent> <Plug>Ysurround  :<C-U>set opfunc=<SID>opfunc<CR>g@
nnoremap <silent> <Plug>YSurround  :<C-U>set opfunc=<SID>opfunc2<CR>g@
vnoremap <silent> <Plug>VSurround  :<C-U>call <SID>opfunc(visualmode(),visualmode() ==# 'V' ? 1 : 0)<CR>
vnoremap <silent> <Plug>VgSurround :<C-U>call <SID>opfunc(visualmode(),visualmode() ==# 'V' ? 0 : 1)<CR>
inoremap <silent> <Plug>Isurround  <C-R>=<SID>insert()<CR>
inoremap <silent> <Plug>ISurround  <C-R>=<SID>insert(1)<CR>
if !exists("g:surround_no_mappings") || !g:surround_no_mappings
  nmap ds  <Plug>Dsurround
  nmap cs  <Plug>Csurround
  nmap ys  <Plug>Ysurround
  nmap yS  <Plug>YSurround
  nmap yss <Plug>Yssurround
  nmap ySs <Plug>YSsurround
  nmap ySS <Plug>YSsurround
  xmap S   <Plug>VSurround
  xmap gS  <Plug>VgSurround
  if !exists("g:surround_no_insert_mappings") || !g:surround_no_insert_mappings
    if !hasmapto("<Plug>Isurround", "i") && "" ==# mapcheck("<C-S>", "i")
      imap    <C-S> <Plug>Isurround
    endif
    imap      <C-G>s <Plug>Isurround
    imap      <C-G>S <Plug>ISurround
  endif
endif
