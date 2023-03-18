# Extension link
* [https://github.com/asvetliakov/vscode-neovim](https://github.com/asvetliakov/vscode-neovim)

# Requirements
* whichkey extension in vscode

# Settings VSCode

For performance optimization, put these lines in vscode settings : 

```json
    "extensions.experimental.affinity": {
        "asvetliakov.vscode-neovim": 1
    },

```

# Whichkey keybindings
```
leader = , 
```


## Buffers

```
<leader>bb         : Show all bufffers
<leader>bd         : Close Active Editor
<leader>bm         : Close Other Editors
<leader>bh/j/k/l   : Move editor to left/below/above/right
<leader>bn/p       : Next/Previous editor
<leader>N          : New editor
<leader>u          : Reopen close editor
<leader>y          : Copy buffer to clipboard

```
## Explorer
```
<leader>e          : Toggle Explorer
```

## Terminal

```
<leader>tt         : Toggle Terminal
<leader>tT         : Focus Terminal
```

