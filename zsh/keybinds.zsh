#
# $ZDOTDIR/keybinds.zsh
#

## Zsh Keybindings and editing configurations

# Copy text to system clipboard using OSC 52 escape sequence
function osc52-copy() {
  local encoded=$(printf '%s' "$1" | base64 -w 0)
  printf '\e]52;c;%s\e\\' "$encoded" > /dev/tty
}

function copy-buffer-to-clipboard() {
  osc52-copy "$BUFFER"
}
zle -N copy-buffer-to-clipboard

function cut-buffer-to-clipboard() {
  osc52-copy "$BUFFER"
  zle kill-buffer -w
}
zle -N cut-buffer-to-clipboard

# Move cursor to the end of the buffer.
function end-of-buffer() {
    CURSOR=${#BUFFER}
    # trigger syntax highlighting redraw
    zle end-of-line -w
}
zle -N end-of-buffer

# Move cursor to the beginning of the buffer.
function beginning-of-buffer() {
    CURSOR=0
    zle beginning-of-line -w
}
zle -N beginning-of-buffer

# Only a lil jank
function select-all() {
    CURSOR=0
    zle set-mark-command
    CURSOR=${#BUFFER}
    zle end-of-line -w
}
zle -N select-all

function shift-select::kill-region() {
    zle kill-region -w
    zle -K main
}
zle -N shift-select::kill-region

function shift-select::clear-selection() {
    zle deactivate-region -w
    zle -K main
}
zle -N shift-select::clear-selection

# Deactivate the selection region, and process input with the main keymap
function shift-select::deselect-and-input() {
    zle deactivate-region -w
    zle -K main
    # Push the typed keys back to the input stack, i.e. process them again,
    # but now with the main keymap.
    zle -U "$KEYS"
}
zle -N shift-select::deselect-and-input

function shift-select::cut-region() {
    zle kill-region -w
    osc52-copy "$CUTBUFFER"
    zle -K main
}
zle -N shift-select::cut-region

function shift-select::copy-region() {
    zle copy-region-as-kill -w
    osc52-copy "$CUTBUFFER"
}
zle -N shift-select::copy-region

function shift-select::quote-region() {
    zle quote-region -w
    zle -K main
}
zle -N shift-select::quote-region

# If the selection region is not active, set the mark at the cursor position,
# switch to the shift-select keymap, and call $WIDGET without 'shift-select::'
# prefix. This function must be used only for shift-select::<widget> widgets.
function shift-select::select-and-invoke() {
    if (( !REGION_ACTIVE )); then
        zle set-mark-command -w
        zle -K shift-select
    fi
    zle ${WIDGET#shift-select::} -w
}

autoload -Uz edit-command-line
zle -N edit-command-line

# The keymaps use the sequences from kitty

## Main keymap bindings
for kcap    seq         widget (
    x       '^[[1;5D'   backward-word             # Ctrl + LeftArrow
    x       '^[[1;5C'   forward-word              # Ctrl + RightArrow
    x       '^[[H'      beginning-of-line         # Ctrl + Home
    x       '^[[F'      end-of-line               # Ctrl + End
    x       '^[[3~'     delete-char               # Delete
    x       '^[[3;5~'   delete-word               # Ctrl + Delete
    x       '^H'        backward-delete-word      # Ctrl + Backspace
    x       '^E'        edit-command-line         # Ctrl + E
    x       '^Z'        undo                      # Ctrl + Z
    x       '^[[122;6u' redo                      # Ctrl + Shift + Z
    x       '^[[99;6u'  copy-buffer-to-clipboard  # Ctrl + Shift + C
    x       '^[[120;6u' cut-buffer-to-clipboard   # Ctrl + Shift + X
    x       '^S'        undefined-key
); do
    bindkey ${terminfo[$kcap]:-$seq} $widget
done

# Create a new keymap for the shift-select
bindkey -N shift-select

# Bind all possible key sequences to deselect-and-input, i.e. it will be used
# as a fallback for "unbound" key sequences.
bindkey -M shift-select -R '^@'-'^?' shift-select::deselect-and-input

## Bind Shift keys in the main and shift-select keymaps.
for kcap    seq         widget (            # key name
    kLFT    '^[[1;2D'   backward-char       # Shift + LeftArrow
    kRIT    '^[[1;2C'   forward-char        # Shift + RightArrow
    kri     '^[[1;2A'   up-line             # Shift + UpArrow
    kind    '^[[1;2B'   down-line           # Shift + DownArrow
    kHOM    '^[[1;2H'   beginning-of-line   # Shift + Home
    kEND    '^[[1;2F'   end-of-line         # Shift + End
    x       '^[[1;6D'   backward-word       # Shift + Ctrl + LeftArrow
    x       '^[[1;6C'   forward-word        # Shift + Ctrl + RightArrow
    x       '^[[1;6H'   beginning-of-buffer # Shift + Ctrl + Home
    x       '^[[1;6F'   end-of-buffer       # Shift + Ctrl + End
    x       '^A'        select-all
); do
    zle -N shift-select::$widget shift-select::select-and-invoke
    bindkey -M main ${terminfo[$kcap]:-$seq} shift-select::$widget
    bindkey -M shift-select ${terminfo[$kcap]:-$seq} shift-select::$widget
done

## Bind keys in the shift-select keymap.
for kcap    seq         widget (                        # key name
    kdch1   '^[[3~'     shift-select::kill-region       # Delete
    x       '^[[3;5~'   shift-select::kill-region       # Ctrl + Delete
    kbs     '^?'        shift-select::kill-region       # Backspace
    x       '^H'        shift-select::kill-region       # Ctrl + Backspace
    x       '^X'        shift-select::cut-region        # Ctrl + X
    x       '^[[99;6u'  shift-select::copy-region       # Ctrl + Shift + C
    x       \'          shift-select::quote-region      # Quote
); do
    bindkey -M shift-select ${terminfo[$kcap]:-$seq} $widget
done

# Binds for deja
DEJA_TOGGLE_KEY=''
DEJA_CYCLE_FUZZY_KEY='^[.'
DEJA_CYCLE_FUZZY_BACK_KEY=''
DEJA_CYCLE_KEY='^N'
DEJA_DISMISS_KEY='^[^['
