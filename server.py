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
    with open("homepage.html") as home:
        page = home.read()
        pageTop, pageBottom = page.split(delim)
        result = get_services()
        pageTable = make_services_table(result)

        page = pageTop + pageTable + pageBottom
        return page

#details page handler
@app.route('/details')
def get_details():
    serviceNo = request.args.get('serviceNo')
    result = get_service_details(serviceNo)
    make_details_table(result)   


    with open("details.html") as details:
        page = details.read()
        return page



#this part is just for aesthetic to make the app a bit nicer
#it adds an icon to the browser tab
#works with Chrome. Opera seemed to be having trouble
@app.route('/favicon.ico')
def favicon():
    return send_file('favicon.ico')





#utility functions for abstration

#get_service_details
#this function takes an integer representing the serviceID
#and returns a tuple with the results of select statement
def get_service_details(serviceID: int):
    cursor = create_cursor()

    #this select statement runs against the service_view used to generate
    #service documents in the last wsoapp. it matches information on the 
    #serviceID provided in the function call
    cursor.execute("""
        select seq_num, event, title, name, notes
        from service_view
        where service.service_id = %s
    """, (serviceID,))

    return cursor.fetchall()


#get_services
#takes no arguments
#returns a tuple with the results of a select statement
def get_services():
    curcon = create_cursor()
    curcon.execute("""
        select Svc_Datetime, Theme_Event
        from service
    """)
    
    return cursor.fetchall()




#make_details_table
#takes a tuple with the results of a select statement
#returns a string to insert into the html
#used when producing the details page
def make_details_table(result):  
    table = ""
    for row in result:
        sequence, event, title, name, notes = row

        table_row = f"""
        <tr>
            <td>{sequence}</td>
            <td>{event}</td>
            <td>{title}</td>
            <td>{name}</td>
            <td>{notes}</td>
        </tr>
        """
    
        table += table_row

    return table    


#make_services_table
#takes a tuple with the results of a select statment
#returns a string to insert into the html
#used to produce the homepage with the list of services
def make_services_table(result):
    table = ""
    for row in result:
        (datetime, theme) = row
        date, time = datetime.split(' ')

        table_row = f"""
        <tr>
            <td>{date}</td>
            <td>{time}</td>
            <td>{theme}</td>
            <td>
                <a href="/details?date={date}&time={time}">Detail</a>
            </td>
        </tr>
        """
    
        table += table_row

    return table 


#create_cursor
#takes no arguments
#returns a cursor for the database
def create_cursor():
    con = connect(user=dbconfig.USERNAME, password=dbconfig.PASSWORD, database='wsoapp2', host=dbconfig.HOST)
    return con.cursor()


if __name__ == "__main__":
    app.run(host='localhost', port='8080', debug=True)