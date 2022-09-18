# vim-picgo

vim/nvim 插件，功能是调用 PicGo-Core 上传本地剪贴板图片到图床，并在 vim 的当前
buffer 中插入返回后的 https 地址

## 安装方法

### 先决条件

首先需要系统全局安装 picgo 软件，安装 picgo 前确保系统中存在 nodejs, 安装方式如下，配置 picgo 参见在线[手册](https://picgo.github.io/PicGo-Core-Doc/zh/guide/config.html)


```sh
sudo pacman -Sy nodejs
sudo npm install -g picgo
```

### 推荐使用 vim-plug 管理插件

vim 修改 ~/.vimrc, nvim 则修改 ~/.config/nvim/init.vim 初始配置文件

```vim
Plug 'zhumengu/vim-picgo'
```

## 使用方法

插件提供如下连个命令

```vim
:PicGoClip
:PicGoFile /path/to/file
```

`PicGoClip` 上传本地剪贴板图片到图床，截图软件推荐使用 flameshot `PicGoFile` 上
传本地文件到图床。命令默认没有做快捷键映射如需要可以安装如下配置

```vim
nmap <silent> <leader>u :PicGoClip<cr>
```

## 自定义配置

插件默认提供简单的插入 markdown 图片连接功能, 可以通过 全局变量 g:picgo_handler
自定义返回类型

```vim
" url  : 上传成功返回的图床图片地址
" src  : 使用何种方式上传，值为 'clipboard' 或者 'file'
" fname: 上传本地文件路径
function! s:upload_succ(url, src, fname)
  if matchstr(&filetype, 'html') != ''
    call append(line('.'), '<img src="' . a:url . '" alt="' . a:fname . '"/>')
  elseif matchstr(&filetype, 'markdown') != ''
    call append(line('.'), '![pic](' . a:url . ')')
  else
    call append(line('.'), a:url)
  endif
  echomsg 'picgo: Upload successfully'
endfunction

let g:picgo_handler = {
    \ 'success': function('s:upload_succ')
    \ }
```


