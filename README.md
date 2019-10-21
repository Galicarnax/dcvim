# dcvim
An extension for `Double Commander` file manager to provide Vim-like key bindings

While there is a number of console file managers with Vim-like keybindings (e.g., `ranger` and `vifm`), it seems that no GUI analogs exist. The `dcvim` extension allows to use `Double Commander (DC)`, a cross-platform GUI file manager, in Vim-like manner to the extent allowed by the application's API. Since DC does not expose some of its functionality (e.g., basic cursor movements) to its scripts, `dcvim` relies on external key emulation utilities (`xdotool` in case of Unix/Linux, and an *ad hoc* self-made small utility in case of MS Windows).

Currently, `dcvim` works in `Unix/Linux` and `MS Windows` only.

If you want to keep your custom shortcuts along with `dcvim` keybindings, you should copy the contents of `keys.xml` into `shortcuts.csf` instead of using `dcvim.csf` (but make sure there is no interference).

# Install
### Linux
- Install `xdotool` utility (e.g., in Ubuntu: `sudo apt install xdotool`)
- [Make sure](https://doublecmd.github.io/doc/en/lua.html#dllrequired) Lua library is installed  (e.g., in Ubuntu: `sudo apt install liblua5.1-0`)
- Copy/clone `dcvim` directory into DC's [config directory](https://doublecmd.github.io/doc/en/configxml.html)
- Copy or move `dcvim.scf` from `dcvim` one level up into DC's config directory
- Configure DC:
	- `Options->Keys`: set `Typing->Letters` to `None`  
	- `Options->Keys->Hotkeys`: select `dcvim.scf` as the `Shortcut file`

### MS Windows
- [Make sure](https://doublecmd.github.io/doc/en/lua.html#dllrequired) `lua5.1.dll` is present in your DC folder
- Copy/clone `dcvim` directory into DC's [config directory](https://doublecmd.github.io/doc/en/configxml.html)
- Copy the contents of `dcvim\mswin\toolbar_items.xml` into `doublecmd.xml`, into the section enclosed by `<Toolbars><MainToolbar><Row>` tags (before copying, make sure DC is not running). <span style="font-size:0.9em;">[Note that this will introduce several buttons in the toolbar menu. They are used to launch key emulation utility from Lua scripts, since direct call of such utility from Lua does not work properly in Windows.]</span>
- (Optional) If you are fussy about running extraneous executables, you may prefer to build `dcvim\mswin\keyemulate.exe` from C++ code yourself.
- Copy or move `dcvim.scf` from `dcvim` one level up into DC's config directory
- Configure DC:
	- `Options->Keys`: set `Typing->Letters` to `None`  
	- `Options->Keys->Hotkeys`: select `dcvim.scf` as the `Shortcut file` 


# Keybindings

Keys | Description 
---|---
`k` | move cursor up
`j` | move cursor down
`h` | move to parent directory
`l`| enter subdirectory or archive[<sup>1</sup>](#1)
`gg` | go to top of list
`G` | go to bottom of list
`gj` | move page down
`gk` | move page up
`]` | move 5 entries down
`[` | move 5 entries up
`H` | move back in history
`L` | move forward in history
`f{char}` | jump to first entry which starts with the character `{char}`
`;` | jump to next entry in the search initiated with `f{char}` 
`,` | jump to next entry in the search initiated with `f{char}` (exclude directories)
`/` | quick search
`gh` | go to home directory
`g/` | go to root directory
`:` | command line
`vv` | select (mark) all entries
`vu` | unselect all entries
`va`, `v+` | add entries to selection using masks
`vd`, `v-` | remove entries from selection using masks
`ve` | select files with the same extension as that of the file under cursor
`vi` | invert selection
`K` | move cursor up and toggle selection of entries
`J` | move cursor down and toggle selection of entries
`yy` | yank (copy) to clipboard
`yd` | cut to clipboard
`yf` | copy full paths to clipboard
`yn` | copy names only
`pp` | put (paste) from clipboard
`cp` | copy into opposite panel (without confirmation)
`cm` | move into opposite panel (without confirmation)
`dd` | delete to trash
`DD` | delete permanently 
`sn` | sort by name / toggle direction
`ss` | sort by size / toggle direction
`sd` | sort by date / toggle direction
`se` | sort by extension / toggle direction
`sa` | sort by attribute / toggle direction
`m{char}` | bookmark current location[<sup>2</sup>](#2)
`'{char}`, `` `{char}`` | go to bookmarked location
`''`, ` `` ` | show DC's directory hotlist 
`nf` | new file
`nd` | new directory
`nn` | new network connection
`x` | close network connection
`gf` | advanced search
`g.` | toggle hidden files
`gb` | toggle flat view of directory contents
`gy` | sync directories
`gi` | show history
`rr` | rename 
`ri` | rename (put cursor in front of file name)
`ra` | rename (put cursor after file name)[<sup>3</sup>](#3)
`re` | rename (put cursor after file extension)
`rm` | multi-rename tool
`gs` | count sizes of subdirectories
`z` | hide/show right (or lower) panel
`>` | increment size of the left/upper panel
`<` | decrement size of the left/upper panel
`u` | swap panels
`R` | refresh
`e` | edit file
`gt` | open terminal
`go` | open Options window
`Esc` | cancel previous "modifier"-key - `g`, `f`, `y`, etc. (back to "normal" mode)
`Q` | quit


<a class="anchor" id="1">1</a>. Unlike in `ranger` and `vifm`, `l` does not open files, only directories. Binding it to open files is not a good idea as it often leads to casual launch of apps while navigating. However, this might be Ok if a file is an archive, in which case DC enters it as if it was a directory. However, with DC APIs it seems impossible to distinguish files and directories within archives, as well as within remote (FTP) paths, so in these cases `l` acts as an Open action for files as well.

<a class="anchor" id="2">2</a>. These bookmarks are different from DC's own directory hotlist. NB: when bookmarking a remote (FTP) location, DC API does not provide WFX-plugin prefix in the path (although internally it works correct for DC's directory hotlist). So to be able to jump to that bookmark, you have to manually add a prefix (e.g., wfx://FTP/...) for the corresponding entry in `dcvim/vars/bookmarks`.

<a class="anchor" id="3">3</a>. This key binding assumes you have set the option `Select file name without extension when renaming` in `Options->File Operations->User Interface` (if not, `ra` acts as `re`)
