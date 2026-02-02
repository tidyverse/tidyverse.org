# Some beautiful ggplot2 code
mpg |>
  ggplot(aes(displ, hwy)) +
  geom_point() +
  geom_line(
    data = grid,
    colour = "blue",
    linewidth = 1.5
  ) +
  geom_text(
    data = outlier,
    aes(label = model)
  )
