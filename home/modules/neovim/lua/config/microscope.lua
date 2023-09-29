local microscope = require("microscope")

local actions = require("microscope.builtin.actions")
local files = require("microscope-files")
local buffers = require("microscope-buffers")
local code = require("microscope-code")

local display = require("microscope.api.display")
local builtin = require("microscope.builtin.layouts")

local layout_list = {
  function(opts)
    if opts.full_screen then
      return display
        .horizontal({
          display.preview(),
          display.vertical({
            display.input(1),
            display.results(5),
            display.space(),
          }),
        })
        :build(opts.ui_size)
    else
      return display
        .horizontal({
          display.vertical({
            display.input(1),
            display.results(5),
            display.space(),
          }),
          display.preview(),
        })
        :build(opts.ui_size)
    end
  end,
  builtin.default,
  function(opts)
    return display
      .horizontal({
        display.space("20%"),
        display.vertical({
          display.input(1),
          display.results(5),
          display.space(),
        }),
        display.space("20%"),
      })
      :build(opts.ui_size)
  end,
}
local function rotate_layout(instance)
  instance:alter(function(opts)
    opts.mode = opts.mode or 1
    opts.layout = layout_list[opts.mode + 1]
    opts.mode = (opts.mode + 1) % #layout_list
    return opts
  end)
end

microscope.setup({
  prompt = "> ",
  size = {
    width = 125,
    height = 40,
  },
  bindings = {
    ["<c-j>"] = actions.next,
    ["<c-k>"] = actions.previous,
    ["<c-n>"] = actions.scroll_down,
    ["<c-p>"] = actions.scroll_up,
    ["<c-m>"] = actions.toggle_full_screen,
    ["<c-a>"] = rotate_layout,
    ["<a-cr>"] = actions.refine,
    ["<CR>"] = actions.open,
    ["<ESC>"] = actions.close,
    ["<TAB>"] = actions.select,
  },
})

microscope.register(files.finders)
microscope.register(buffers.finders)
microscope.register(code.finders)

keymap("<leader>fw", ":Microscope workspace_grep<CR>")
keymap("<leader>fW", ":Microscope workspace_fuzzy<CR>")
keymap("<leader>of", ":Microscope file<CR>")
keymap("<leader>ob", ":Microscope buffer<CR>")
keymap("gi", ":Microscope code_implementations<CR>")
keymap("gd", ":Microscope code_definitions<CR>")
keymap("gr", ":Microscope code_references<CR>")
keymap("gt", ":Microscope code_type_definition<CR>")

for finder, _ in pairs(microscope.finders) do
  microscope.finders[finder]:override({
    bindings = { ["<c-q>"] = files.actions.quickfix },
    layout = layout_list[1],
  })
end
