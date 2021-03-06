library(ggplot2)
library(SmarterPoland)
library(dplyr)

# skale -----------------------------------------------------------------

p <- ggplot(data = countries, aes(x = continent, fill = continent)) +
  geom_bar()

p + scale_x_discrete(position = "top")

p + scale_y_continuous(position = "right")

p + scale_x_discrete(limits = sort(unique(countries[["continent"]]), decreasing = TRUE))

continent_order <- group_by(countries, continent) %>% 
  summarise(count = length(continent)) %>% 
  arrange(desc(count)) %>% 
  pull(continent)

p + scale_x_discrete(limits = continent_order)

countries_f <- mutate(countries, continent = factor(continent))

ggplot(data = countries_f, aes(x = continent, fill = continent)) +
  geom_bar() + 
  scale_x_discrete(limits = continent_order)

mutate(countries_f, continent = factor(continent, levels = continent_order)) %>% 
  ggplot(aes(x = continent, fill = continent)) +
  geom_bar()

ggplot(countries_f, aes(x = death.rate, y = birth.rate)) +
  geom_point() +
  facet_wrap(~ continent)


mutate(countries_f, continent = factor(continent, levels = continent_order),
       continent = factor(continent, labels = toupper(levels(continent)))) %>% 
  ggplot(aes(x = death.rate, y = birth.rate)) +
  geom_point() +
  facet_wrap(~ continent)

# color brewer: http://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3
# alternatywnie library(RColorBrewer)

p + scale_fill_manual(values = c("red", "grey", "black", "navyblue", "green"))
# gradienty: przykladowo scale_fill_gradient()

# koordynaty --------------------------------------------------------------

p <- ggplot(data = countries, aes(x = continent)) +
  geom_bar()

p + coord_flip()

p + coord_polar()

ggplot(countries, aes(x = death.rate, y = birth.rate)) +
  geom_point() +
  facet_wrap(~ continent) + 
  coord_polar()

p <- ggplot(data = countries, aes(x = birth.rate, y = death.rate, color = continent)) +
  geom_point() +
  geom_smooth(se = FALSE)

p + coord_equal()

# coord_cartesian nie usuwa punktów
p + coord_cartesian(xlim = c(5, 10))
p + scale_x_continuous(limits = c(5, 10))

grid.arrange(p + coord_cartesian(xlim = c(5, 10)) + ggtitle("coord_cartesian"),
             p + scale_x_continuous(limits = c(5, 10)) + ggtitle("scale_x_continuous - limits"),
             ncol = 1)

# wiele wykresow na jednym rysunku ---------------------------------------------------

main_plot <- ggplot(data = countries, aes(x = birth.rate, y = death.rate, color = continent)) +
  geom_point()

density_death <- ggplot(data = na.omit(countries), aes(x = death.rate, fill = continent)) +
  geom_density(alpha = 0.2) +
  coord_flip() +
  theme(legend.position = "none")

density_birth <- ggplot(data = countries, aes(x = birth.rate, fill = continent)) +
  geom_density(alpha = 0.2) +
  theme(legend.position = "none")

library(gridExtra)
library(grid)

grid.arrange(density_death, main_plot, density_birth, 
             ncol = 2)

grid.arrange(density_death, main_plot, rectGrob(gp = gpar(fill = NA, col = NA)), density_birth, 
             ncol = 2, heights = c(0.7, 0.3), widths = c(0.3, 0.7))

grid.arrange(density_death, main_plot + theme(legend.position = "none"), rectGrob(gp = gpar(fill = NA, col = NA)), density_birth, 
             ncol = 2, heights = c(0.7, 0.3), widths = c(0.3, 0.7))

get_legend <- function(gg_plot) {
  grob_table <- ggplotGrob(gg_plot)
  grob_table[["grobs"]][[which(sapply(grob_table[["grobs"]], function(x) x[["name"]]) == "guide-box")]]
}

grid.arrange(density_death, main_plot + theme(legend.position = "none"), get_legend(main_plot), density_birth, 
             ncol = 2, heights = c(0.7, 0.3), widths = c(0.3, 0.7))

# alternatywy do patchwork
# library(cowplot)
# library(customLayout)

source("https://install-github.me/thomasp85/patchwork")
library(patchwork)

p1 <- ggplot(data = countries, aes(x = continent, y = death.rate)) +
  geom_boxplot()

set.seed(1410)
p2 <- ggplot(data = countries, aes(x = continent, y = death.rate)) +
  geom_point(position = "jitter")

p3 <- ggplot(data = countries, aes(x = continent)) +
  geom_bar()

(p1 + p2) / p3

((p1 + p2) / p3) * theme_bw()

((p1 + p2) / p3) & theme_bw()

# rozklady brzegowe w patchwork
density_death + main_plot + plot_spacer() + density_birth + 
  plot_layout(ncol = 2, heights = c(0.7, 0.3), widths = c(0.3, 0.7))
