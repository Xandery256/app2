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


#homepage handler
@app.route('/')
def get_home():
    with open("homepage.html") as home:
        page = home.read()
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






def get_service_details(serviceID) -> cursor:
    cursor = create_cursor()
    cursor.execute("""
        select seq_num, event, title, name, notes
        from service_view

    """)



def get_services():
    cursor = create_cursor()
    cursor.execute("""
        select Svc_Datetime, Theme_Event
        from service    
    """)
    
    return cursor.fetchall()



def make_details_table(result: cursor) -> str: 
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





def create_cursor():
    con = connect(user=dbconfig.USERNAME, password=dbconfig.PASSWORD, database='wsoapp2', host=dbconfig.HOST)
    return con.cursor()


if __name__ == "__main__":
    app.run(host='localhost', port='8080', debug=True)