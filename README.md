# Web App 2 Instructions

Create a web application that allows the user to create a new service based on an existing service (the “template”). The Python Flask framework is suggested, but individuals may use any technology or language that they can deploy to a public web server. Teams must receive special approval to use any technology other than Python Flask framework.

1. The initial page should display a table of all of the services in the database that includes, the service date, time, and theme. Each service should have a link or button that navigates to a detail page with information about the selected service.

2. The detail page should display details about the service selected on the initial page,
including the service date/time, theme/event, and songleader name, as well as a list of all of the service events. Below this information, display a form that prompts for the following info to create a new service (the user must enter items with an *; the other items may be left blank): (20 points)

    - *Date/time for new service – clearly indicate the format the user must follow when entering the date/time. Fill in the current date/time as the default value.

    - Theme (default to the theme of the selected service)

    - Songleader – Allow the user to select from a list of names of previous service songleaders. The list should be sorted by last name and contain no duplicates. It should default to no songleader.

3. When the user enters this information and clicks a “Create” button, call a stored procedure you have created named create_service that does the following, then display a page indicating either success or an appropriate error message:

    - Verify that there is no existing service at the datetime specified for the new service. Return an error code if there is already a service at that date. (10 points)

    - If there is no service at the specified date, insert a record into the Service table for the new service using the specified date/time, theme, and songleader. For values that the user left blank, use NULL. (10 points)

4. Enhance the create_service stored procedure to insert records into the ServiceEvent table for the new service based on the events in the selected template service, except that the specific songs, personnel, and ensembles should be left blank. For example, if the user selects 10/3/2010 10am for the date/time for the template service, the program should insert ServiceEvent records for the new service that have the same sequence numbers and event types as those for the 10/3/2010 10am service. (10 points)

    - `Tip: The creation of all of the ServiceEvent records for the new service can be done with a single, carefully constructed INSERT statement. Review the notes to find the form of the INSERT that can generate records using a SELECT.`

5. **Bonus:** In the final step of the application, allow the user to select songs to be assigned to the congregational song events in the new service. Create a view named SongUsageView that displays all of the colums in the Song table, plus one named LastUsedDate. The LastUsedDate column should contain the date of the most recent service that used that song. (Exclude choral songs, but be sure to include songs which have never been used). Using this view, display 20 of the least recently used songs, ordered by LastUsedDate, and then song title. Allow the user to select songs from this list, and assign them to the congregational song events. (10 points)