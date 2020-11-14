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
    
    #general pattern for getting a piece of information from the webpage
    # var = request.args.get('var')

    #get datetime
    #get theme
    #get songleader
    #get template

    #call stored procedure

    #get results of xander's procedure

    with open('service_creation.html') as creation:
        page = creation.read()
        # pageTop, pageBottom = page.split(delim)




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



if __name__ == "__main__":
    app.run(host='localhost', port='8080', debug=True)
