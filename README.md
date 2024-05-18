# Visualizing California Environmental Data using CalEnviroScreen4.0

## Description
With this project, I wanted to see how far I could get in replicating the dashboard created by the CalEnviroScreen4.0 researchers. Using Shiny and R, I was able to do a basic copy which includes filtering by county and city. Due to RAM limits placed by shinapps.io, the user can only select a certain number of columns before the app crashes. 

### CalEnviroScreen4.0 Site
>https://oehha.ca.gov/calenviroscreen/report/calenviroscreen-40

## Installation
If you would like to modify this project in your own way, here are the following steps for RStudio.
1. Clone the repository.
2. Create a new project in RStudio.
3. You should be met with a new project wizard with three options.
4. Select the version control option.
   -If you haven't set up Git and RStudio, please follow this guide:
   
     >https://rfortherestofus.com/2021/02/how-to-use-git-github-with-r
     
6. After doing so, the project should load and you should be met with a message at the consolse that says something like Project .... loading.
7. Type renv::init() in the console to initiate the library loading process.
8. Type renv::status() in the console to check that the packages needed for the project are all set.
9. You are now ready to play around with the project!

## Example
![image](https://github.com/Polymershot/Visualizing-California-Environmental-Data/assets/69413289/b7b6236f-22a3-4783-843d-ff8be0511533)

## Shiny App 
>https://polymershot72.shinyapps.io/California-Environment-Data/

## Remarks
The actual dashboard created by the CalEnviroScreen4.0 researchers is miles ahead but by trying to see how far I could get in trying to replicate it, I learned a lot about project management. At first, I didn't even create a R project and just created the folders and files all mixed up. This led to me getting confused and reconsidering just restarting it all. However, I ended up doing more research and finally learning the basics of Git/Github. I paid more attention to project structure in terms of naming and folder placement. I also was introducted to the idea of making sure you have a list of packages needed for others to run the project.

## Support
If someone happens to come across this project and wants to know more, please contact me at rdn9177@gmail.com.

