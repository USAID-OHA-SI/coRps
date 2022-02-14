#### 1. Exercises
1.  How many rows are in `hfr_mmd`?
2.  Create a plot to explore the relationship between patient volume (`tx_curr`) and share on over 3 months of treatment dispensing (`share_tx_mmd.3mo`). Looking at the help file and the plot, what makes this plot not very useful to drawing insights from?


#### 2. Exercises
  1. What is wrong with the code below? Why are the points not green?
    ```
    ggplot(data = hfr_mmd) + geom_point(mapping = aes(x = date, y = share_tx_mmd.o3mo, color = "green"))
    ```
  2. Using a similar plot from the first exercise, change all the data points to size 6. Repeat this and change all the colors to of the points to purple.
  3. Use the `shape` aesthetic to change the shape based on `snu1`.

#### 3. Exercises
  1. Read the help for `facet_wrap()` (`?facet_wrap`) and figure out how you would make the output from our PSNU small multiples above into 1 row? Would you you plot it in one column?
  2. How would you reorder `mech_code` order in the second small multiples graphic so that they were ordered by the partner who had the highest (max) TX_CURR to the lowest?
  
#### 4. Exercises
  1. Using `geom_bar` graph the number of observations for each period (`date`).
  2. Plot a bar graph of TX_CURR over time. Rather than using `fill = snu1`, use `color = snu1` in the aesthetics instead. What changes in your plot?