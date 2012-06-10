module Riml
  module Constants
    RIML_KEYWORDS = %w(def function function! end if then else elseif unless while
                       for in true false nil command command? return finish break
                       continue call let)
    VIML_END_KEYWORDS = %w(endif endfunction endwhile endfor)
    KEYWORDS = RIML_KEYWORDS + VIML_END_KEYWORDS

    VIML_SPECIAL_VARIABLE_PREFIXES = %w(& @ $)

    VIML_FUNC_NO_PARENS_NECESSARY = %W(echo echon echohl execute sleep)

    BUILTIN_FUNCTIONS = %w(
abs
acos
add
append
append
argc
argidx
argv
argv
asin
atan
atan2
browse
browsedir
bufexists
buflisted
bufloaded
bufname
bufnr
bufwinnr
byte2line
byteidx
call
ceil
changenr
char2nr
cindent
clearmatches
col
complete
complete_add
complete_check
confirm
copy
cos
cosh
count
cscope_connection
cursor
cursor
deepcopy
delete
did_filetype
diff_filler
diff_hlID
empty
escape
eval
eventhandler
executable
exists
extend
exp
expand
feedkeys
filereadable
filewritable
filter
finddir
findfile
float2nr
floor
fmod
fnameescape
fnamemodify
foldclosed
foldclosedend
foldlevel
foldtext
foldtextresult
foreground
function
garbagecollect
get
get
getbufline
getbufvar
getchar
getcharmod
getcmdline
getcmdpos
getcmdtype
getcwd
getfperm
getfsize
getfontname
getftime
getftype
getline
getline
getloclist
getmatches
getpid
getpos
getqflist
getreg
getregtype
gettabvar
gettabwinvar
getwinposx
getwinposy
getwinvar
glob
globpath
has
has_key
haslocaldir
hasmapto
histadd
histdel
histget
histnr
hlexists
hlID
hostname
iconv
indent
index
input
inputdialog
inputlist
inputrestore
inputsave
inputsecret
insert
isdirectory
islocked
items
join
keys
len
libcall
libcallnr
line
line2byte
lispindent
localtime
log
log10
map
maparg
mapcheck
match
matchadd
matcharg
matchdelete
matchend
matchlist
matchstr
max
min
mkdir
mode
mzeval
nextnonblank
nr2char
pathshorten
pow
prevnonblank
printf
pumvisible
range
readfile
reltime
reltimestr
remote_expr
remote_foreground
remote_peek
remote_read
remote_send
remove
remove
rename
repeat
resolve
reverse
round
search
searchdecl
searchpair
searchpairpos
searchpos
server2client
serverlist
setbufvar
setcmdpos
setline
setloclist
setmatches
setpos
setqflist
setreg
settabvar
settabwinvar
setwinvar
shellescape
simplify
sin
sinh
sort
soundfold
spellbadword
spellsuggest
split
sqrt
str2float
str2nr
strchars
strdisplaywidth
strftime
stridx
string
strlen
strpart
strridx
strtrans
strwidth
submatch
substitute
synID
synIDattr
synIDtrans
synstack
system
tabpagebuflist
tabpagenr
tabpagewinnr
taglist
tagfiles
tempname
tan
tanh
tolower
toupper
tr
trunc
type
undofile
undotree
values
virtcol
visualmode
winbufnr
wincol
winheight
winline
winnr
winrestcmd
winrestview
winsaveview
winwidth
writefile
)
  end
end