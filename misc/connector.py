import mysql.connector
from mysql.connector import (connection)

import re
import pandas as pd

import csv

#establishing the connection
conn = connection.MySQLConnection(user='root', password='123', host='127.0.0.1', database='resources')

#Creating a cursor object using the cursor() method
cursor = conn.cursor()

#Executing an MYSQL function using the execute() method
cursor.execute("SELECT DATABASE()")

# Fetch a single row using fetchone() method.
data = cursor.fetchone()
print("Connection established to: ",data)

# Random number above 2
numline = 3

with open('utilization_hier.rpt', 'r') as file:
    line = file.readline()
    
    for line in file:
        #print(line.rstrip())
        m = re.search(r"Instance.*", line.rstrip())
        numline += 1

        if m:
            m.group()
            m=str(m.group())
            m = " ".join(m.split())
            m = ''.join(m)
            print(m)       
            # Reset counter
            numline = 0
        if numline == 2:
            data = line.rstrip()
            data = " ".join(data.split())
            #data = str(data)
            data = ''.join(data)
            print(data)

mydata = data.split('|')

for item in mydata:
    print(item)


#Dropping EMPLOYEE table if already exists.
cursor.execute("DROP TABLE IF EXISTS FPGA_RESOURCES")

sql ='''CREATE TABLE FPGA_RESOURCES(
   BITSTREAM_ID CHAR(20) NOT NULL,
   NAME CHAR(20) NOT NULL,
   DATE CHAR(20) NOT NULL,
   LUT INT,
   FF INT,
   DSP INT,
   BRAM INT,
   POWER FLOAT
)'''

cursor.execute(sql)

#sql = """INSERT INTO FPGA_RESOURCES(
#    BITSTREAM_ID, NAME, DATE)
#    VALUES ('olakase', 'ariane', '04.12.23')"""

insert_data = (
    "INSERT INTO FPGA_RESOURCES(BITSTREAM_ID, NAME, DATE)"
    "VALUES (%s, %s, %s)"
)
data = ('olakase', 'ariane', '04.12.23')


 #Preparing SQL query to INSERT a record into the database.
#insert_stmt = (
#   "INSERT INTO EMPLOYEE(FIRST_NAME, LAST_NAME, AGE, SEX, INCOME)"
#   "VALUES (%s, %s, %s, %s, %s)"
#)
#data = ('Ramya', 'Ramapriya', 25, 'F', 5000)

try:
    # Executing the SQL command
    # No dynamic data:
    # cursor.execute(insert_data)
    # Dynamic data:
    cursor.execute(insert_data, data)

    # Commit changes in the database
    conn.commit()

except:
    # Roll back in case of error
    conn.rollback()

print("Data inserted")

sql = """SELECT * from FPGA_RESOURCES"""

cursor.execute(sql)

result = cursor.fetchall();
print(result)



#Retrieving the list of databases
#print("List of databases: ")
#cursor.execute("SHOW DATABASES;")
#print(cursor.fetchall())

#Closing the connection
conn.close()