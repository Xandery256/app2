# Project Notes

## Python Notes

Make sure to make a dbconfig.py file so you can connect the server to your MySQL server properly. Doing this will allow us to use our databases without having the same login and without changing the code everytime we need to try it on our end.

For our connections we need:

### GUI Side

- Homepage
  - Display table of services
  - Receive content requests
  - Return appropriate details page
- details
  - Display table with service data
  - Receive creation requests

### DB side

All we really need atm is a procedure call and a place to store that data to give it back to the GUI

## Database Notes

Make sure you create a wsoapp2 database using Schaub's script and then use the [create_views.sql](create_views.sql) script to get the views built.


## Time Log

11/11 - Alexander - 25 min
11/12 - Alexander - 1 hr