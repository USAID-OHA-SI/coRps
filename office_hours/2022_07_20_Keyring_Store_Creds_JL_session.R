# AUTHOR:   K. Srikanth | USAID
# PURPOSE:  Demonstrate how to save credentials using the keyring package
# REF ID:   4c6df040 
# LICENSE:  MIT
# DATE:     2022-07-20
# UPDATED: 

# DEPENDENCIES ------------------------------------------------------------
  
library(keyring)

# GLOBAL VARIABLES --------------------------------------------------------
  
  ref_id <- "4c6df040"

# KEYRING PACKAGE 101 -----------------------------------------------------
  
  #The keyring packae can help store passwords and keys in a secure manner to call on in R.
  #You only need to store your keys once using keyring::key_set()
  
  keyring::key_set(service = "test") #this will prompt you to enter a password to set your key
  
  keyring::key_get(service = "test") #this will allow you to query the key you set
  
# FUNCTION TO STORE MULTIPLE CREDS ---------------------------------------
  
  #We can write a helper function that calls on keyring::key_set_with_value() to save credentials by a service and username.
  

  #function to set up a key using keyring
  set_key <- function(service, name) {
    
    msg <- glue::glue("Please enter value for {service}/{name} key:")
    
    value <- rstudioapi::askForPassword(prompt = msg)
    value <- stringr::str_trim(value, side = "both")
    
    if (base::nchar(value) == 0)
      base::stop("ERROR - Invalid value entered")
    
    keyring::key_set_with_value(service = service,
                                username = name,
                                password = value)
  }
  
  #Function to get the key value (to check pwd)
  get_key <- function(service, name) {
    keyring::key_get(service, name)
  }
  
  
# TEST FUNCTION ------------------------------------------------------
  
  #Save service and username as local vars
  service <- "test-function"
  user_name <- "coRps-user"
  
  #set up the key adding params for service and username
  #(only have to set this up once)
  set_key(service = service, name = user_name)
  
  #return stored credentials
  get_key(service = service, name = user_name)
