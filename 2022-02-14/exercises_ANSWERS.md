#### 1. Exercises
1.  How many rows are in `hfr_mmd`?
count(hfr_mmd)

2.  Create a plot to explore the relationship between patient volume (`tx_curr`) and share on over 3 months of treatment dispensing (`share_tx_mmd.3mo`). Looking at the help file and the plot, what makes this plot not very useful to drawing insights from?

ggplot(data=hfr_mmd)+
  geom_point(mapping = aes(x=tx_curr,
                           y=share_tx_mmd.o3mo))

#### 2. Exercises
  1. What is wrong with the code below? Why are the points not green?
    ```
    ggplot(data = hfr_mmd) + geom_point(mapping = aes(x = date, y = share_tx_mmd.o3mo, color = "green"))
    ```
    color is inside the aesthetic. By applying an aesthetic outside of `aes()`, we are manually applying the same aesthetic to all the data values 
        ```
      ggplot(data = hfr_mmd) + geom_point(mapping = aes(x = date, y = share_tx_mmd.o3mo),
     colour = "green")
         ```

     
  2. Using a similar plot from the first exercise, change all the data points to size 6. Repeat this and change all the colors to of the points to purple.
        ```
      ggplot(data = hfr_mmd) + geom_point(mapping = aes(x = date, y = share_tx_mmd.o3mo),
     colour = "purple", 
     alpha=6)
         ```
  3. Use the `shape` aesthetic to change the shape based on `snu1`.
        ```
      ggplot(data = hfr_mmd) + geom_point(mapping = aes(x = date, y = share_tx_mmd.o3mo, shape=snu1),
     colour = "purple", 
     alpha=6)
         ```
#### 3. Exercises
  1. Read the help for `facet_wrap()` (`?facet_wrap`) and figure out how you would make the output from our PSNU small multiples above into 1 row? Would you you plot it in one column?
          ```
  ?facet_wrap

  ggplot(data = hfr_mmd) +
  geom_point(mapping = aes(x = date, y = share_tx_mmd.o3mo)) +
  facet_wrap(~fct_reorder(.f = psnu, #what are we ordering?
                          .x = tx_curr, #by what variable are we ordering it?
                          .fun = sum, #how are we ordering it/what function?
                          na.rm = TRUE, #should we remove NA values?
                          .desc = TRUE #should we reverse the direction
                          ),
               nrow = 1)

  ggplot(data = hfr_mmd) +
  geom_point(mapping = aes(x = date, y = share_tx_mmd.o3mo)) +
  facet_wrap(~fct_reorder(.f = psnu, #what are we ordering?
                          .x = tx_curr, #by what variable are we ordering it?
                          .fun = sum, #how are we ordering it/what function?
                          na.rm = TRUE, #should we remove NA values?
                          .desc = TRUE #should we reverse the direction
                          ),
               ncol = 1)
  
          ```
  
  2. How would you reorder `mech_code` order in the second small multiples graphic so that they were ordered by the partner who had the highest (max) TX_CURR to the lowest?
            ```
  ggplot(data = hfr_mmd) +
  geom_point(mapping = aes(x = date, y = share_tx_mmd.o3mo)) +
  facet_wrap(snu1~fct_reorder(.f= mech_code,
                        .x=tx_curr,
                        .fun=sum,
                        .na.rm=TRUE,
                        .desc=TRUE))
            ```

#### 4. Exercises
  1. Plot a bar graph of TX_CURR over time. Rather than using `fill = snu1`, use `color = snu1` in the aesthetics instead. What changes in your plot?
   ```
ggplot(data = hfr_mmd) +
  geom_col(mapping = aes(x = date, y = tx_curr, color = snu1))
   ```
   
  2. Change the following code to make a small multiples plot with a facet for region (`snu1`)
  ```
  ggplot(data = hfr_mmd) +
  geom_col(mapping = aes(x = date, y = tx_curr, fill = snu1),
           position = "dodge")
   ```
  ```
ggplot(data = hfr_mmd) +
  geom_col(mapping = aes(x = date, y = tx_curr))+
  facet_wrap(~snu1)
                          ```