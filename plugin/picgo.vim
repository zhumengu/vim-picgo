if exists("g:loaded_picgo") | finish | endif

if ! executable("picgo")
    echomsg "picgo: Please run 'npm -g picgo' install PicGo-Core"
    finish
endif

function! s:handle_success(url, src, fname)
    if a:url != ""
        call append(line('.'), '![pic](' . a:url . ')')
        echomsg 'picgo: Upload from ' . a:src . ' successfully'
    endif
endfunction

function! s:handle_error(errmsg, src, fname)
    if a:errmsg != ""
        echomsg a:errmsg
    endif
endfunction

function! s:OnEvent(job_id, data, event) dict
    if a:event == 'stdout'
        for log in a:data
            if matchstr(log, '^\[PicGo SUCCESS\]') != ''
                call s:picgo_handler.success(a:data[-2], self.source, self.fname)
                break
            elseif matchstr(log, '^\[PicGo ERROR\]') != ''
                call s:picgo_handler.error(substitute(log, '^\[.\{-\}]:\s*', '', ''), self.source, self.fname)
                break
            endif
        endfor
    endif
    "elseif a:event == 'stderr'
    "    let str = substitute(a:data[-1], '^\[PicGo ERROR\]:\s*', '', 'ig')
    "    echomsg str
    "elseif a:event == 'exit'
        "echomsg 'on exit: ' . a:data
    "endif
endfunction

function! s:upload(...)
    let argc = a:0
    if argc == 0
        call jobstart(['picgo', 'upload'], extend({'source': 'clipboard', 'fname': ''}, s:callbacks))
    else
        let fname = a:1
        if !filereadable(fname)
            let fname = s:looklikePath(getreg('"'))
            if fname != ""
                let tmp_ans = input('Use this path (' . fname . ')? [Y/n]')
            else
                if fname == ""
                    echomsg 'picgo: Please select a image file'
                    return
                endif
                echomsg 'picgo: [' . fname . '] not exists'
                return
            endif
            if tmp_ans != '' && tmp_ans ==? 'n'
                return
            else
                if !filereadable(fname)
                    echomsg 'picgo: The file unreadable [' . fname . ']'
                    return
                endif
            endif
        endif
        call jobstart(['picgo', 'upload', fname], extend({'source': 'file', 'fname': fname}, s:callbacks))
    endif
endfunction

function! s:looklikePath(path)
    return matchstr(a:path, '^\(\/\|[a-zA-Z]:[\\\/]\)\?\([^\/\\]\{-\}[\\\/]\)*[^\/\\]\{-\}\.\(png\|jpe\?g\)$')
endfunction

let s:callbacks = {
            \ 'on_stdout': function('s:OnEvent'),
            \ 'on_stderr': function('s:OnEvent'),
            \ 'on_exit': function('s:OnEvent')
            \ }

let s:picgo_handler = {
            \ 'success': function('s:handle_success'),
            \ 'error': function('s:handle_error')
            \ }

if exists('g:picgo_handler')
    let s:picgo_handler = extend(s:picgo_handler, g:picgo_handler)
endif

command! PicgoClip :call s:upload()
command! -nargs=? -complete=file PicgoFile :call s:upload(<q-args>)

let g:loaded_picgo = 1
