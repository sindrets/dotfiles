hl.config({
  plugin = {
    hyprbars = {
      enabled = true,
      bar_blur = false,
      bar_height = 32,
      bar_color = "rgb(1e1e1e)",
      col = { text = "rgb(899296)" },
      bar_text_size = 11,
      bar_text_font = "Jetbrains Mono Nerd Font",
      bar_text_weight = "Bold",
      bar_button_padding = 8,
      bar_padding = 10,
      bar_part_of_window = true,
      bar_precedence_over_border = true,
    },
  },
})

hl.plugin.hyprbars.add_button({
  bg_color = "rgb(dc6d77)",
  fg_color = "rgb(ffffff)",
  size = 14,
  icon = " ",
  action = "hyprctl dispatch 'hl.dsp.window.close()'",
})

hl.plugin.hyprbars.add_button({
  bg_color = "rgb(e4c17c)",
  fg_color = "rgb(000000)",
  size = 14,
  icon = " ",
  action = "hyprctl dispatch 'hl.dsp.window.fullscreen()'",
})

hl.plugin.hyprbars.add_button({
  bg_color = "rgb(7eb1d8)",
  fg_color = "rgb(000000)",
  size = 14,
  icon = " ",
  action = [=[hyprctl dispatch 'hl.dsp.window.float({ action = "toggle" })']=],
})
