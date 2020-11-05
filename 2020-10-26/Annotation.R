# title: Annotating Plots!
# author: G. Sarfaty + T. Essam
# date: 2020-10-26


# Libraries
library(extrafont)
library(tidyverse)
library(glitr)
library(here)
library(scales)
library(ICPIutilities)


# Training Data
dataset_url<-"https://raw.githubusercontent.com/USAID-OHA-SI/coRps/master/2020-05-29/FY20Q1_Jupiter_POS.csv"

df<-read_csv(dataset_url)




# Basic Plot
plot <- df %>%
  ggplot2::ggplot(
    aes(x = reorder(mech_code, desc(val)),
        y = val
    )) +
  geom_bar(stat = "identity", fill=USAID_mgrey, alpha=.8, width=.4)+
  xlab("mechanism")+
  ylab("")+
  si_style_nolines()

print(plot)




#Plot w annotation 
plot_annotate <- df %>%
  ggplot2::ggplot(
    aes(x = reorder(mech_code, desc(val)),
        y = val
    )) +
  geom_bar(stat = "identity", fill=USAID_mgrey, alpha=.8, width=.4)+
  xlab("mechanism")+
  ylab("")+
  annotate(
    geom = "curve", x = 3.5, y = 1000, xend = 3, yend = 650, #determine arrow placement on coordinate plane
    curvature = .3, #control intensity of curve# 
    arrow = arrow(length = unit(4, "mm")), #determine size of arrow's point
    color=grey50k
  ) +
  annotate(geom = "text", x = 3.55, y = 1000, #determine text placement on coordinate plane
           label = "Mechanism Ended FY20Q1", #what you want your text to say
           hjust="left", size=4, color=grey50k, family="Gill Sans MT")+
  si_style_nolines()

print(plot_annotate)



## Use Annotate to make a Rectangle
# here is a snippet to get a rectangle behind a share line graph
# 
# annotate("rect", xmin = as.Date("2020-01-01"), xmax = as.Date("2020-04-01"), ymin = 0, ymax = 1, 
#          fill = grey10k, alpha = 0.5) +
# For this example in practice, please see:
# https://github.com/USAID-OHA-SI/pump_up_the_jam/blob/715fce13bfc385aa0363527c879d648c1be42681/Scripts/100_completeness_covid_viz.R#L213-L217
# Courtesty of T. Essam!


