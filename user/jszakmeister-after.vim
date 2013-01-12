" =============================================================
" Variables
" =============================================================

" Default font size.
let g:SZAK_FONT_SIZE = 14

" =============================================================
" Detect custom exectuables
" =============================================================

if filereadable(expand("$HOME/.local/bin/ctags"))
    let Tlist_Ctags_Cmd='/Users/jszakmeister/.local/bin/ctags'
    let g:tagbar_ctags_bin = '/Users/jszakmeister/.local/bin/ctags'
endif

if filereadable(expand("$HOME/.local/bin/git"))
    let g:fugitive_git_executable = expand("$HOME/.local/bin/git")
    let g:Gitv_GitExecutable = g:fugitive_git_executable
endif

" =============================================================
" Mappings
" =============================================================

" Make Y work the way I expect it to: yank to the end of the line.
nnoremap Y y$

" Keep the block highlighted while shifting.
vnoremap < <gv
vnoremap > >gv

" Some reminders of the tag-related shortcuts, since I tend to check my
" configuration first.
" C-] - go to definition
" C-T - Jump back from the definition.
" C-W C-] - Open the definition in a horizontal split

" C-\ - Open the definition in a new tab
" A-] - Open the definition in a vertical split
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" The next several entries are taken from:
"     <http://stevelosh.com/blog/2010/09/coming-home-to-vim/>

" Split the window vertically, and go to it.
nnoremap <leader>w <C-w>v<C-w>l

" I often want to close a buffer without closing the window.  Using
" :BW also drops the associated metadata.
nnoremap <leader><leader>d :BW<CR>

" Shortcut for clearing CtrlP caches
nnoremap <Leader><Leader>r :<C-U>CtrlPClearAllCaches<CR>

" Add some mappings for Regrep since I don't use the function keys.
vnoremap <expr> <Leader><Leader>g VisualRegrep()
nnoremap <expr> <Leader><Leader>g NormalRegrep()

" Add a mapping for the Quickfix window.  Unfortunately, C-Q doesn't appear to
" work in a terminal.
nnoremap <Leader><Leader>q :call QuickFixWinToggle()<CR>

" =============================================================
" Options
" =============================================================

" Turn on list, and setup the listchars.
set listchars=tab:▸\ ,trail:·,extends:>,precedes:<,nbsp:·
if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
    let &listchars = "tab:\u21e5 ,trail:\u2423,extends:\u21c9,precedes:\u21c7,nbsp:\u26ad"
    let &fillchars = "vert:\u254e,fold:\u00b7"
endif
set list

" Turn on cursor shapes under iTerm, and use 256 colors under gnome-terminal.
" For some reason, gnome-terminal says xterm-color even though it supports
" xterm-256color.
if !has("gui_running")
    if has("macunix") && $TERM_PROGRAM == "iTerm.app"
        " This works only in iTerm... but that's what I use on the Mac.
        " Set the cursor to a vertical line in insert mode.
        let &t_SI = "\<Esc>]50;CursorShape=1\x7"
        let &t_EI = "\<Esc>]50;CursorShape=0\x7"
    elseif $COLORTERM == "gnome-terminal"
        if &t_Co <= 16
            set t_Co=256
        endif
    endif
endif

" Turn off the scrollbars... I don't need them.
if has("gui_running")
    set guioptions-=R
    set guioptions-=r
    set guioptions-=L
    set guioptions-=l
endif

colorscheme szakdark

if has("gui_macvim")
    set macmeta
endif

set nowrap

" Ignore some Clojure/Java-related files.
set wildignore+=target/**,asset-cache

" I regularly create tmp folders that I don't want searched.
set wildignore+=tmp,.lein-*,*.egg-info,.*.swo

" On remote systems, I like to change the background color so that I remember
" I'm on a remote system. :-)  This does break when you sudo su to root though.
if !empty($SSH_TTY)
    hi Normal guibg=#0d280d
endif

" Set colorcolumn, if available.
if exists('+colorcolumn')
    " This sets it to textwidth+1
    set colorcolumn=+1
endif

" -------------------------------------------------------------
" Font selection
" -------------------------------------------------------------

" Helper to aid in locating Powerline-enabled fonts in standard directory
" locations.
function! HasFont(filename)
    if has("macunix")
        let l:search_paths = ["~/Library/Fonts", "/Library/Fonts"]
    else
        let l:search_paths = ["~/.fonts", "/usr/share/fonts"]
    endif

    for path in l:search_paths
        let path = expand(path)
        if filereadable(expand(path . "/**/" . a:filename))
            return 1
        endif
    endfor

    return 0
endfunction

" Searches for several Powerline-enabled fonts.  If it finds one, it'll choose
" it and turn on fancy symbols for Powerline.  Otherwise, fallback to a normal
" font, and use unicode symbols for Powerline.
function! SetFont()
    " Turn on fancy symbols on the status line
    if has("gui_running")
        let powerline_fonts=[
                    \   ["DejaVu Sans Mono", "DejaVuSansMono-Powerline.ttf"],
                    \   ["Droid Sans Mono", "DroidSansMono-Powerline.ttf"],
                    \   ]
        let fontname=map(copy(powerline_fonts), 'v:val[0]')

        for font in powerline_fonts
            if HasFont(font[1])
                let fontname=[font[0] . " for Powerline"]
                let g:Powerline_symbols = 'fancy'
                break
            endif
        endfor

        if has("macunix")
            let fontstring=join(map(
                        \ copy(fontname), 'v:val . ":h" . g:SZAK_FONT_SIZE'), ",")
        else
            let fontstring=join(map(
                        \ copy(fontname), 'v:val . " " . g:SZAK_FONT_SIZE'), ",")
        endif

        let &guifont=fontstring
    endif
endfunction
command! SetFont call SetFont()

autocmd GUIEnter * SetFont

" =============================================================
" Fullscreen
" =============================================================

" Allow Vim to go fullscreen under Mac and Linux.
if has("gui_macvim")
    " grow to maximum horizontal width on entering fullscreen mode
    set fuopt+=maxhorz

    " This needs to go in a gvimrc, otherwise the macmenu defaults
    " clobber my setting.  Not sure how I want to do this just yet.
    " " free up Command-F
    " macmenu Edit.Find.Find\.\.\. key=<nop>

    " " toggle fullscreen mode
    " map <D-f> :set invfu<CR>
    nnoremap <Leader><Leader>f :set invfu<CR>
endif

if has("unix")
    let s:os = substitute(system('uname'), "\n", "", "")
    if v:version >= 703 && s:os == "Linux" && has("gui_running")
        function! ToggleFullScreen()
           call system("wmctrl -i -r ".v:windowid." -b toggle,fullscreen")
           redraw
        endfunction

        nnoremap <Leader><Leader>f call ToggleFullScreen()<CR>
    endif
endif

" =============================================================
" Setup routines
" =============================================================

function! SetupManPager()
    setlocal nonu nolist
    nnoremap <Space> <PageDown>
    nnoremap b <PageUp>
    nnoremap q :quit<CR>
endfunction
command! SetupManPager call SetupManPager()

" =============================================================
" Plugin settings
" =============================================================

" -------------------------------------------------------------
" Gitv
" -------------------------------------------------------------

let g:Gitv_WipeAllOnClose = 1
let g:Gitv_OpenHorizontal = 1
let g:Gitv_OpenPreviewOnLaunch = 1

" -------------------------------------------------------------
" Grep
" -------------------------------------------------------------

" Use ack for grep
if executable('ack')
    set grepprg=ack
    set grepformat=%f:%l:%m
endif

" Be compatible with both grep on Linux and Mac
let Grep_Xargs_Options = '-0'

" -------------------------------------------------------------
" VimClojure
" -------------------------------------------------------------

" Highlight Clojure's builtins and turn on rainbow parens
let g:vimclojure#HighlightBuiltins=1
let g:vimclojure#ParenRainbow=1

" Treat forms that start with def as lispwords
let g:vimclojure#FuzzyIndent=1

" I keep my nailgun client in ~/.local/bin.  If it's there, then let
" VimClojure know.
if executable(expand("~/.local/bin/ng"))
    let g:vimclojure#NailgunClient=expand("~/.local/bin/ng")
endif

" -------------------------------------------------------------
" Powerline
" -------------------------------------------------------------

if g:EnablePowerline
    " Add back in a few segments...
    call Pl#Theme#InsertSegment('mode_indicator', 'after', 'paste_indicator')
    call Pl#Theme#InsertSegment('filetype', 'before', 'scrollpercent')
    call Pl#Theme#InsertSegment('fileformat', 'before', 'filetype')

    call Pl#Theme#InsertSegment('ws_marker', 'after', 'lineinfo')

    if !has("gui_running")
        let g:Powerline_symbols_override = {
            \ 'BRANCH': [0x2442],
            \ }
    endif
endif

" =============================================================
" Autocommands
" =============================================================

augroup jszakmeister_vimrc
    autocmd!
    autocmd FileType man call setpos("'\"", [0, 0, 0, 0])|exe "normal! gg"
augroup END

" =============================================================
" Commands
" =============================================================

function! ShowHighlightGroup()
    echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
        \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
        \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"
endfunction
command! ShowHighlightGroup call ShowHighlightGroup()

function! ShowAvailableColors()
    " Optional: First enter ":let g:rgb_fg=1" to highlight foreground only.
    " Restore normal highlighting by typing ":call clearmatches()"
    "
    " Create a new scratch buffer:
    " - Read file $VIMRUNTIME/rgb.txt
    " - Delete lines where color name is not a single word (duplicates).
    " - Delete "grey" lines (duplicate "gray"; there are a few more "gray").
    " Add matches so each color name is highlighted in its color.
    call clearmatches()
    new
    setlocal buftype=nofile bufhidden=hide noswapfile
    0read $VIMRUNTIME/rgb.txt
    let find_color = '^\s*\(\d\+\s*\)\{3}\zs\w*$'
    silent execute 'v/'.find_color.'/d'
    silent g/grey/d
    let namedcolors=[]
    1
    while search(find_color, 'W') > 0
        let w = expand('<cword>')
        call add(namedcolors, w)
    endwhile

    for w in namedcolors
        execute 'hi col_'.w.' guifg=black guibg='.w
        execute 'hi col_'.w.'_fg guifg='.w.' guibg=NONE'
        execute '%s/\<'.w.'\>/'.printf("%-36s%s", w, w).'/g'

        call matchadd('col_'.w, '\<'.w.'\>', -1)
        " determine second string by that with large # of spaces before it
        call matchadd('col_'.w.'_fg', ' \{10,}\<'.w.'\>', -1)
    endfor
    1
    nohlsearch
endfunction
command! ShowAvailableColors call ShowAvailableColors()

" Size for the big screen.
function! BigScreenTv()
    set columns=120
    set lines=36
    let &guifont = substitute(&guifont, ':h\([^:]*\)', ':h25', '')
endfunction
command! BigScreenTv call BigScreenTv()

" =============================================================
" Machine Specific Settings
" =============================================================

if $VIMMACHINE == ""
    let $VIMMACHINE=hostname()
endif

let s:VIMMACHINE_CONFIG = $VIMUSERFILES . "/" . $VIMUSER .
    \ "/machine/" . $VIMMACHINE . ".vim"

" If a machine local config exists, source it.
if filereadable(s:VIMMACHINE_CONFIG)
    execute "source " . s:VIMMACHINE_CONFIG
endif
