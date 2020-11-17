#server.py

#gui import
import os
from flask import Flask, request, send_file


#db import
from mysql.connector import connect, cursor
import dbconfig

#global variables
delim = "<!--{0}-->"
app = Flask(__name__)



#Main Code
#homepage handler
@app.route('/')
def get_home():
    #makes a call to the database to get the services
    result = get_services()

    #produce an html table from the results
    pageTable = make_services_table(result)
    
    #concatenate the html table with the homepage document 
    #and return to the browser
    with open("homepage.html") as home:
        page = home.read()
        pageTop, pageBottom = page.split(delim)
        
        page = pageTop + pageTable + pageBottom
        return page



#details page handler
@app.route('/details')
def get_details():
    #/details?datetime=datetime%20string
    serviceDateTime = request.args.get('datetime')

    # theme, songleader, 
    theme, songleader, result = get_service_details(serviceDateTime)
    
    if theme == None: theme = "None"
    if songleader == None: songleader = "None"

    pageTable = make_details_table(result)  

    previousLeaders = get_songleaders() 

    leadersTable = make_songleaders_combo(previousLeaders)

    with open("details.html") as details:
        page = details.read()

        
        pages = page.split(delim)
        page  = pages[0] + serviceDateTime 
        page += pages[1] + theme 
        page += pages[2] + songleader 
        page += pages[3] + pageTable 
        page += pages[4] + leadersTable
        page += pages[5] + serviceDateTime
        page += pages[6]

        #page = pages[0] + pageTable + pages[1]
        return page





#now we need a thing to call his procedure
#so i think i'll define another route for the bottle framework
@app.route('/create')
def createService():
    con = connect(user=dbconfig.USERNAME, password=dbconfig.PASSWORD, database='wsoapp2', host=dbconfig.HOST)
    curcon =  con.cursor()
    
    #general pattern for getting a piece of information from the webpage
    # var = request.args.get('var')
    #get template datetime
    template = request.args.get('template')
    #get datetime
    datetime = request.args.get('datetime')
    #get theme
    theme = request.args.get('theme')
    #get songleader id
    songleader = request.args.get('songleader')

    #call stored procedure
    result = curcon.callproc("create_service", (template, datetime, theme, songleader))
    #get results of xander's procedure
    # result[5] code
    # result[4] message

    theme, songleader, result = get_service_details(datetime)
    
    if theme == None: theme = "None"
    if songleader == None: songleader = "None"


    with open('service_creation.html') as creation:
        page = creation.read()
        # pageTop, pageBottom = page.split(delim)

        pages = page.split(delim)
        page  = pages[0] + result[5] 
        page += pages[1] + result[4]
        page += pages[2]


        return page



@app.route("/add-songs")
def add_songs():
    page = ''

    return page



#this part is just for aesthetic to make the app a bit nicer
#it adds an icon to the browser tab
#works with Chrome. Opera seemed to be having trouble
@app.route('/favicon.ico')
def favicon():
    return send_file('favicon.ico')



#utility functions for abstration

#get_services
#takes no arguments
#returns a tuple with the results of a select statement
def get_services():
    #create connection here because the connection lifetime is 
    #only to the end of the function
    con = connect(user=dbconfig.USERNAME, password=dbconfig.PASSWORD, database='wsoapp2', host=dbconfig.HOST)
    curcon =  con.cursor()
    curcon.execute("""
    select Svc_Datetime, Theme_Event
    from service
    """)

    result = curcon.fetchall()
    return result

#get_service_details
#this function takes an integer representing the serviceID
#and returns a tuple with the results of select statement
def get_service_details(serviceDate: int):
    con = connect(user=dbconfig.USERNAME, password=dbconfig.PASSWORD, database='wsoapp2', host=dbconfig.HOST)
    curcon =  con.cursor()
    

    #get the theme
    curcon.execute("""
    select theme
    from service_view
    where service_view.svc_DateTime = %s
    group by theme 
    """, (serviceDate,))
    theme = curcon.fetchall()

    
    #get the song leader
    curcon.execute("""
    select songleader
    from service_view
    where service_view.svc_DateTime = %s
    group by songleader
    """, (serviceDate,))
    songleader = curcon.fetchall()

    
    #this select statement runs against the service_view used to generate
    #service documents in the last wsoapp. it matches information on the 
    #serviceID provided in the function call
    curcon.execute("""
    select seq_num, event, title, name, notes
    from service_view
    where service_view.svc_DateTime = %s
    """, (serviceDate,))

    result = curcon.fetchall()
    return  theme[0][0], songleader[0][0], result


#get_songleaders
#takes no input
#returns a list of songleaders
def get_songleaders():
    #create cursor
    con = connect(user=dbconfig.USERNAME, password=dbconfig.PASSWORD, database='wsoapp2', host=dbconfig.HOST)
    curcon =  con.cursor()

    #get the songleaders
    curcon.execute("""
        select Person_ID, songleader_name
        from songleader    
        group by Person_ID
    """)

    result = curcon.fetchall()
    return result



#make_services_table
#takes a tuple with the results of a select statment
#returns a string to insert into the html
#used to produce the homepage with the list of services
def make_services_table(result):
    table = ""
    for row in result:
        (datetime, theme) = row

        table_row = f"""
        <tr>
            <td class="table_cell">{datetime}</td>
            <td class="table_cell">{theme}</td>
            <td class="table_cell">
                <a href="/details?datetime={datetime}">Detail</a>
            </td>
        </tr>
        """
    
        table += table_row

    return table 


#make_details_table
#takes a tuple with the results of a select statement
#returns a string to insert into the html
#used when producing the details page
def make_details_table(result):  
    table = ""
    for row in result:
        sequence, event, title, name, notes = row
        
        if title == None: title = ""
        if notes == None: notes = ""
        if name == None: name = ""

        table_row = f"""
        <tr>
            <td class="table_cell">{sequence}</td>
            <td class="table_cell">{event}</td>
            <td class="table_cell">{title}</td>
            <td class="table_cell">{name}</td>
            <td class="table_cell">{notes}</td>
        </tr>
        """
    
        table += table_row

    return table    



#make_songleaders_combo
#takes the results of a select statement executed by a cursor
#returns a string of html
def make_songleaders_combo(result):
    comboString = ""

    for row in result:
        person_id, name = row
        comboString += f"""
        <option value="{person_id}">{name}</option>
        """


    return comboString


#create_songs_table
#takes result as a set of service items
#returns a string with the table with options available to select
def create_songs_table(result):
    songsDetails = ""

    numSongs = 0
    for row in result:
        sequence, event, title, name, notes = row
        

        # this if statement checks affects the title based on the 
        # event type and current title 

        # if the event is a congregational song  
        if event == "Cong. Song": 
        # we want the user to select a title from the dropdown
            titleList = select_title()
            title = f"""
            <select id="songNumber{numSongs}" name="songNmber{numSongs}">
                {titleList}
            </select>
            """
            numSongs += 1
        # otherwise, we want to know if title is None
        # if the title is None and we're not dealing with a congregational
        # then we want the title to be blank
        elif title == None: title = ""

        if notes == None: notes = ""
        if name == None: name = ""

        table_row = f"""
        <tr>
            <td class="table_cell">{sequence}</td>
            <td class="table_cell">{event}</td>
            <td class="table_cell">{title}</td>
            <td class="table_cell">{name}</td>
            <td class="table_cell">{notes}</td>
        </tr>
        """
    
        songsDetails += table_row



        

    return songsDetails


#select_title
#takes no arguments
#returns a string representing a list of recently used song options
def select_title():
    con = connect(user=dbconfig.USERNAME, password=dbconfig.PASSWORD, database='wsoapp2', host=dbconfig.HOST)
    curcon =  con.cursor()

    curcon.execute("select Song_ID, Title, LastUsedDate from songusageview")

    result = curcon.fetchall()

    #take the result and make an html drop down from it

    comboString = ""

    # this loop breaks if it runs out of results or it grabs 20 results
    # whichever comes first
    i = 0
    for row in result:
        song, name, date = row
        comboString += f"""
        <option value="{song}">{name} (Last used on {date})</option>
        """

        if i >= 20: break
        else: i += 1



    return comboString




if __name__ == "__main__":
    app.run(host='localhost', port='8080', debug=True)
