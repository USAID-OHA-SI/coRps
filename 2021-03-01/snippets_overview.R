
## R-studio Snippets

#Code snippets are text macros that can be used for quickly inserting chunks of code. If you start typing `fun` you'll see a pop-up that shows you options for a default function.

#If you select the auto-complete option you will see a function with several place holders returned.

#R-Studio comes bundled with many useful snippets. A full listing can be found [here](https://support.rstudio.com/hc/en-us/articles/204463668-Code-Snippets) or by navigating to **Tools** \>\> Global Options \>\> Code \>\> Edit Snippets.

## Installing Snippets

#As we have mentioned before one of the benefits of working with R is there is a vibrant community of folks who create and maintain packages to make our lives easier. With snippets, it's no different as the `snippr` [package](https://github.com/dgrtwo/snippr) allows you to manage and install snippets from public repos.

devtools::install_github("dgrtwo/snippr")
library(snippr)

#While you do have the option to install snippets from a github repo users, you can also install them from a private gist. For this example, I have loaded my snippets to a private [gist](https://gist.github.com/tessam30/d4098c1b0cbd09c616bd924fd1a208c8) (a gist is a Git repo that can be public or private and can be forked and cloned).

snippets_install_gist("tessam30/d4098c1b0cbd09c616bd924fd1a208c8", language = "r")

### 

# You can learn a fair bit about snippets by reviewing the existing ones or searching the web for examples.

# <https://jozef.io/r906-rstudio-snippets/>
#   
# <https://dcl-workflow.stanford.edu/rstudio-snippets.html>
#   
# <https://maraaverick.rbind.io/2017/09/custom-snippets-in-rstudio-faster-tweet-chunks-for-all/>
#   
# <https://www.youtube.com/watch?v=h_i__VTSurU&list=PL7D2RMSmRO9JOvPC1gbA8Mc3azvSfm8Vv&index=28&t=141s>

## Where do I find the examples presented above?
  
tim_snippets <- "https://gist.github.com/tessam30/d4098c1b0cbd09c616bd924fd1a208c8"
