return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<c-n>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
    { "<c-e>", "<cmd><C-U>TmuxNavigateDown<cr>" },
    { "<c-i>", "<cmd><C-U>TmuxNavigateUp<cr>" },
    { "<c-o>", "<cmd><C-U>TmuxNavigateRight<cr>" },
  },
}
