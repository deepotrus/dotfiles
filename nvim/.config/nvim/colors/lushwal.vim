set background=dark
if exists('g:colors_name')
hi clear
if exists('syntax_on')
syntax reset
endif
endif
let g:colors_name = 'lushwal'
highlight Normal guifg=#C2C2C2 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight! link User Normal
highlight Bold guifg=#C2C2C2 guibg=#0D0C0C guisp=NONE blend=NONE gui=bold
highlight Boolean guifg=#AA5C4B guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Character guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight ColorColumn guifg=#867474 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Comment guifg=#C2C2C2 guibg=NONE guisp=NONE blend=NONE gui=italic
highlight Conceal guifg=#6B5757 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight! link Whitespace Conceal
highlight Conditional guifg=#BCB8BC guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Constant guifg=#AA5C4B guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Cursor guifg=#0D0C0C guibg=#C2C2C2 guisp=NONE blend=NONE gui=NONE
highlight CursorColumn guifg=#867474 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight CursorLine guifg=NONE guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight CursorLineNr guifg=#C2C2C2 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight Debug guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Define guifg=#BCB8BC guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Delimiter guifg=#B94631 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight DiagnosticError guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight DiagnosticHint guifg=#C9BAB6 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight DiagnosticInfo guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight DiagnosticUnderlineError guifg=#B73A24 guibg=NONE guisp=#B73A24 blend=NONE gui=underline
highlight DiagnosticUnderlineHint guifg=#C9BAB6 guibg=NONE guisp=#C9BAB6 blend=NONE gui=underline
highlight DiagnosticUnderlineInfo guifg=#7E7F86 guibg=NONE guisp=#7E7F86 blend=NONE gui=underline
highlight DiagnosticUnderlineWarn guifg=#968479 guibg=NONE guisp=#968479 blend=NONE gui=underline
highlight DiagnosticWarn guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight DiffAdd guifg=#8B756F guibg=#6B5757 guisp=NONE blend=NONE gui=bold
highlight! link DiffAdded DiffAdd
highlight DiffChange guifg=#A49D9D guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight DiffDelete guifg=#B73A24 guibg=#6B5757 guisp=NONE blend=NONE gui=bold
highlight! link DiffRemoved DiffDelete
highlight! link diffRemoved DiffDelete
highlight DiffFile guifg=#B73A24 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight DiffLine guifg=#7E7F86 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight DiffNewFile guifg=#8B756F guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight DiffText guifg=#7E7F86 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight Directory guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight EndOfBuffer guifg=#C2C2C2 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight Error guifg=#B73A24 guibg=#C2C2C2 guisp=NONE blend=NONE gui=NONE
highlight ErrorMsg guifg=#B73A24 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight Exception guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Float guifg=#AA5C4B guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight FoldColumn guifg=#7E7F86 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight Folded guifg=#C2C2C2 guibg=#6B5757 guisp=NONE blend=NONE gui=italic
highlight Function guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Identifier guifg=#C9BAB6 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight IncSearch guifg=#6B5757 guibg=#AA5C4B guisp=NONE blend=NONE gui=NONE
highlight Include guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Italic guifg=#C2C2C2 guibg=#0D0C0C guisp=NONE blend=NONE gui=italic
highlight Keyword guifg=#BCB8BC guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Label guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight LineNr guifg=#A49D9D guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight Macro guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MatchParen guifg=#C2C2C2 guibg=#A49D9D guisp=NONE blend=NONE gui=NONE
highlight MiniCompletionActiveParameter guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniCursorword guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=underline
highlight! link MiniCursorwordCurrent MiniCursorword
highlight MiniIndentscopePrefix guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=nocombine
highlight MiniIndentscopeSymbol guifg=#6B5757 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight MiniJump guifg=#7E7F86 guibg=NONE guisp=#A49D9D blend=NONE gui=underline
highlight MiniJump2dSpot guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=undercurl
highlight MiniStarterCurrent guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniStarterFooter guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=bold
highlight MiniStarterHeader guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=bold
highlight MiniStarterInactive guifg=#C2C2C2 guibg=NONE guisp=NONE blend=NONE gui=italic
highlight MiniStarterItem guifg=#C2C2C2 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight MiniStarterItemBullet guifg=#B94631 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniStarterItemPrefix guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniStarterQuery guifg=#8B756F guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniStarterSection guifg=#B94631 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineDevinfo guifg=#C2C2C2 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineFileinfo guifg=#C2C2C2 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineFilename guifg=#968479 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineInactive guifg=#867474 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineModeCommand guifg=#0D0C0C guibg=#C9BAB6 guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineModeInsert guifg=#0D0C0C guibg=#7E7F86 guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineModeNormal guifg=#0D0C0C guibg=#8B756F guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineModeOther guifg=#0D0C0C guibg=#BCB8BC guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineModeReplace guifg=#0D0C0C guibg=#B73A24 guisp=NONE blend=NONE gui=NONE
highlight MiniStatuslineModeVisual guifg=#0D0C0C guibg=#AA5C4B guisp=NONE blend=NONE gui=NONE
highlight MiniSurround guifg=#6B5757 guibg=#AA5C4B guisp=NONE blend=NONE gui=NONE
highlight MiniTablineCurrent guifg=#A49D9D guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight MiniTablineFill guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MiniTablineHidden guifg=#8B756F guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight MiniTablineModifiedCurrent guifg=#C2C2C2 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight MiniTablineModifiedHidden guifg=#867474 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight MiniTablineModifiedVisible guifg=#C2C2C2 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight MiniTablineVisible guifg=#A49D9D guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight MiniTestEmphasis guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=bold
highlight MiniTestFail guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=bold
highlight MiniTestPass guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=bold
highlight MiniTrailspace guifg=#B73A24 guibg=#C2C2C2 guisp=NONE blend=NONE gui=NONE
highlight ModeMsg guifg=#8B756F guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight MoreMsg guifg=#8B756F guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight NonText guifg=#A49D9D guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Number guifg=#AA5C4B guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Operator guifg=#C2C2C2 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight PMenu guifg=#C2C2C2 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight PMenuSel guifg=#C2C2C2 guibg=#7E7F86 guisp=NONE blend=NONE gui=NONE
highlight PmenuSbar guifg=#867474 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight PmenuThumb guifg=#C2C2C2 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight PreProc guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Question guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Repeat guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Search guifg=#A49D9D guibg=#968479 guisp=NONE blend=NONE gui=NONE
highlight! link MiniTablineTabpagesection Search
highlight SignColumn guifg=#867474 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight Special guifg=#C9BAB6 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight SpecialChar guifg=#B94631 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight SpecialKey guifg=#A49D9D guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight SpellBad guifg=#B73A24 guibg=NONE guisp=#B73A24 blend=NONE gui=underline
highlight SpellCap guifg=#968479 guibg=NONE guisp=#968479 blend=NONE gui=underline
highlight SpellLocal guifg=#C9BAB6 guibg=NONE guisp=#C9BAB6 blend=NONE gui=underline
highlight SpellRare guifg=#BCB8BC guibg=NONE guisp=#BCB8BC blend=NONE gui=underline
highlight Statement guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight StatusLine guifg=#C2C2C2 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight StatusLineNC guifg=#867474 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight StatusLineTerm guifg=#8B756F guibg=#8B756F guisp=NONE blend=NONE gui=NONE
highlight StatusLineTermNC guifg=#968479 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight StorageClass guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight String guifg=#8B756F guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Structure guifg=#BCB8BC guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight TabLine guifg=#A49D9D guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight TabLineFill guifg=#A49D9D guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight TabLineSel guifg=#8B756F guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight Tag guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Title guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=bold
highlight Todo guifg=#968479 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight TooLong guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Type guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Typedef guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight Underlined guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight VertSplit guifg=#C2C2C2 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight! link WinSeparator VertSplit
highlight Visual guifg=#0D0C0C guibg=#867474 guisp=NONE blend=NONE gui=NONE
highlight VisualNOS guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight WarningMsg guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight WildMenu guifg=#C2C2C2 guibg=#7E7F86 guisp=NONE blend=NONE gui=NONE
highlight WinBar guifg=#C2C2C2 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight WinBarNC guifg=#867474 guibg=#0D0C0C guisp=NONE blend=NONE gui=NONE
highlight gitCommitOverflow guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight gitCommitSummary guifg=#8B756F guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight helpCommand guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight helpExample guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @attribute guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @boolean guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @character guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @character.special guifg=#B94631 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @comment guifg=#C2C2C2 guibg=NONE guisp=NONE blend=NONE gui=italic
highlight @conditional guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @constant guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @constant.builtin guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @constant.macro guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @constructor guifg=#C2C2C2 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @debug guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @define guifg=#BCB8BC guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @exception guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @field guifg=#8B756F guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @float guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @function guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @function.builtin guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @function.macro guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @include guifg=#C9BAB6 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @keyword guifg=#BCB8BC guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @keyword.function guifg=#C9BAB6 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @keyword.operator guifg=#BCB8BC guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @label guifg=#C9BAB6 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @method guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @namespace guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @none guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @number guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @operator guifg=#C2C2C2 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @parameter guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @preproc guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @property guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @punctuation.bracket guifg=#C2C2C2 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @punctuation.delimiter guifg=#C2C2C2 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @punctuation.special guifg=#C9BAB6 guibg=NONE guisp=NONE blend=NONE gui=bold
highlight @repeat guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @storageclass guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @string guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @string.escape guifg=#8B756F guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @string.regex guifg=#8B756F guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @string.special guifg=#B94631 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @symbol guifg=#C9BAB6 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @tag guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @tag.attribute guifg=#C9BAB6 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @tag.delimiter guifg=#C9BAB6 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text guifg=#8B756F guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.bold guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=bold
highlight @text.danger guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.diff.add guifg=#8B756F guibg=#6B5757 guisp=NONE blend=NONE gui=bold
highlight @text.diff.delete guifg=#B73A24 guibg=#6B5757 guisp=NONE blend=NONE gui=bold
highlight @text.emphasis guifg=#BCB8BC guibg=NONE guisp=NONE blend=NONE gui=italic
highlight @text.environment guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.environment.name guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.literal guifg=#8B756F guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.math guifg=#C9BAB6 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.note guifg=#C9BAB6 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.reference guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @text.strike guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=strikethrough
highlight @text.title guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=bold
highlight @text.todo guifg=#968479 guibg=#6B5757 guisp=NONE blend=NONE gui=NONE
highlight @text.underline guifg=NONE guibg=NONE guisp=NONE blend=NONE gui=underline
highlight @text.uri guifg=NONE guibg=#6B5757 guisp=NONE blend=NONE gui=underline
highlight @type guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @type.builtin guifg=#7E7F86 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @type.definition guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @variable guifg=#968479 guibg=NONE guisp=NONE blend=NONE gui=NONE
highlight @variable.builtin guifg=#B73A24 guibg=NONE guisp=NONE blend=NONE gui=NONE
