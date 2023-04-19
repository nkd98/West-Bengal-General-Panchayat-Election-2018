library(dplyr)
library(stringr)
library(purrr)
library(rvest)
library(RSelenium)
library(tidyr)
library(netstat) # gives free port

# set working directory
setwd("\path")

free_port() # gives free port
rD <- RSelenium::rsDriver(remoteServerAddr = "localhost",
                          port = 14416L, # replace this with the free port
                          browser = "firefox",
                          chromever = NULL
)

# Assign the client to an object
remDr <- rD[["client"]]

# naviagte to the website
remDr$navigate("https://pgems2018.wbsec.org/PublicPages/VotingResult2018.aspx")
# Give some time load
Sys.sleep(4)
# Increase the window size to find elements
remDr$maxWindowSize()

remDr$screenshot(display = TRUE) #This will take a screenshot and display it in the RStudio viewer

# Read page source
source <- remDr$getPageSource()[[1]]

# Election type
list_type <- read_html(source) |>
  html_nodes(css = "#ContentPlaceHolder1_cmbCandidateFor") |>
  html_nodes("option") |>
  html_text()

list_type <- list_type[-1]

# Zilla Parishad Name 
list_district <- read_html(source) |>
  html_nodes(css = "#ContentPlaceHolder1_cmbZillaParisadName") |>
  html_nodes("option") |>
  html_text()



list_district_length <- length(list_district)
# Preallocate districts
data_district <- vector("list", length(list_district))


#click search button
remDr$refresh()
remDr$findElement(using = "css", value = "#ContentPlaceHolder1_btnSearch")$clickElement()
Sys.sleep(2)


# Select election type
GP <- remDr$findElement(using = "css selector", value = "#ContentPlaceHolder1_cmbCandidateFor > option:nth-child(4)" )
GP$clickElement() # selected Gram Panchayat
Sys.sleep(4)



# Iterate over districts
for (k in 13:list_district_length){
  
  #click corresponding zilla
  remDr$findElement(using = "css", value = "#ContentPlaceHolder1_cmbZillaParisadName" )$clickElement() 
  remDr$findElement(using = "css", value = paste0("#ContentPlaceHolder1_cmbZillaParisadName > option:nth-child(", k, ")"))$clickElement()
  
  Sys.sleep(4)
  
  ## Panchayat Samity Name
  #list panchayata Samity Names
  list_PS <- read_html(remDr$getPageSource()[[1]]) |>
    html_nodes(css = "#ContentPlaceHolder1_cmbPanchayatSamity") |>
    html_nodes("option") |>
    html_text()
  
  list_PS_length <- length(list_PS)
  data_PS <- vector("list", length(list_PS))
  
  # iterate over PS 
  for (m in 2:list_PS_length){
    # click corresponding PS
    remDr$findElement(using = "css", value = "#ContentPlaceHolder1_cmbPanchayatSamity")$clickElement()
    remDr$findElement(using = "css", value = paste0("#ContentPlaceHolder1_cmbPanchayatSamity > option:nth-child(", m, ")"))$clickElement()
    Sys.sleep(2)
    
    ## Gram Panchyat name
    # list GP names
    list_GP <- read_html(remDr$getPageSource()[[1]]) |>
      html_nodes(css = "#ContentPlaceHolder1_cmbGramPanchayat") |>
      html_nodes("option") |>
      html_text()
    
    list_GP_length <- length(list_GP)
    
    # Preallocate GP
    data_GP <- vector("list", length(list_GP))
    
    #iterate over GPs
    for (n in 2:list_GP_length){
      #click corresponding GP
      remDr$findElement(using = "css", value = "#ContentPlaceHolder1_cmbGramPanchayat")$clickElement()
      temp1 <- remDr$findElement(using = "css", value = paste0("#ContentPlaceHolder1_cmbGramPanchayat > option:nth-child(", n, ")"))
      temp1$clickElement()
      Sys.sleep(2)
      
      # click on the search button
      remDr$findElement(using = "css", value = "#ContentPlaceHolder1_btnSearch")$clickElement()
      Sys.sleep(2)
      
      # gp table
      table_n <- remDr$getPageSource()[[1]] |>
        read_html() |>
        html_table()
      
      table_n <- table_n[[2]] # we want only second tibble. 
      
      #clean the table 
      # create a new column for gp ward  names
      table_n$ward <- ""
      
      # coerce the first column to be numeric
      table_n$X1 <- as.numeric(table_n$X1) # this gives NA for previously character values
      
      # loop over the rows and fill in the ward name for each observation
      # current_group 
      current_ward <- "" 
      for (i in 1:nrow(table_n)) {    
        if (is.na(table_n[i, "X1"])) {    # checks if the current row contains a ward name.
          # this is a group name row
          current_ward <- table_n[i, "X2"] #sets the value of current ward to the value of second column in that row.
        } else {
          # this is an observation row
          table_n[i, "ward"] <- current_ward #sets the value of current ward to the ward variable
        }
      }
      
      # remove the rows containing ward names
      table_n <- table_n[!is.na(table_n$X1), ]
      
      # add column which contains the GP name
      table_n$GP_name <- list_GP[n]
      
      data_GP[[n]] <- table_n
      
    }
    data_GP <- data_GP[-1] # remove the first element 
    data_PS[[m]] <- reduce(data_GP, bind_rows) # bind the data
    
    # add a column which contains PS name
    data_PS[[m]]$PS_name <- list_PS[m]
    
    
    
    
  }
  data_PS <- data_PS[-1]
  data_district[[k]] <- reduce(data_PS, bind_rows )
  
  # add a column which contains district name

  data_district[[k]]$district_name <- list_district[k]
  
  
  
}

final_data <- reduce(data_district, bind_rows)
colnames(final_data) <- c("sl_no", "cand_name", "father_husband", "gender", "caste", 
                          "party", "votes", "ward", "gp_name", "ps_name", "zp_name" )

final_data$zp_name[final_data$zp_name == "ALIPURDUAR "] <- "ALIPURDUAR"

# add an id variable
final_data <- final_data |> mutate(id = 1:n())
final_data <- final_data |> select(id, everything())

final_data <- as.data.frame(final_data)

# save as csv file
writexl::write_xlsx(final_data, "WB_2018_gp.xlsx" )


