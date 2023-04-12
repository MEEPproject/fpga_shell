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

# Parse the file. It looks for the line where the resources are shown from the "top" point of view
with open('utilization_hier.rpt', 'r') as file:
    line = file.readline()
    
    for line in file:
        # Regular expresion to search for the instance word. It marks the beginning of the relevant data
        m = re.search(r"Instance.*", line.rstrip())
        numline += 1

        # When there is a match, get the whole line.
        if m:
            # Grab the whole line
            m.group()
            # Cast to string
            m=str(m.group())
            # Remove spaces
            m = " ".join(m.split())
            resources = ''.join(m)
            
            print(resources)       
            # Reset counter
            numline = 0
        # Two lines after, there is the actual data we are looking for. 
        if numline == 2:
            # Remove the spaces at the end of the line
            data = line.rstrip()
            # Remove all the remaining spaces
            data = " ".join(data.split())
            # Concatena into a single string
            data = ''.join(data)
            print(data)

resources = resources.split('|')
values = data.split('|')

# Debuggins, shows data
print("olakase")
del values[0:3]
for amount in values:
    print(amount)

# Remove the spaces
print("olakase1")
del resources[0:2]
for field in resources:
    field = field.replace(" ","")  
    print(field)


#Dropping EMPLOYEE table if already exists.
cursor.execute("DROP TABLE IF EXISTS FPGA_RESOURCES")

# Creates the table creatin template
sql_table ='''CREATE TABLE FPGA_RESOURCES(
   BITSTREAM_ID CHAR(20) NOT NULL,
   NAME CHAR(20) NOT NULL,
   DATE CHAR(20) NOT NULL'''

ins_values = ""

# Concatenates the resources than have been collected by Vivado
for field in resources:
    field = field.replace(" ","")
    # This if discards empty values
    if field:
        sql_table  += ",\n   {} INT".format(field)
        ins_values += ", {}".format(field)

sql_table  += "\n   )"
ins_values += ")"

print("SQL_TABLE:\r\n")
print(sql_table)

cursor.execute(sql_table)

print("INSERT!!\r\n")
ins_values = '''INSERT INTO FPGA_RESOURCES( BITSTREAM_ID, NAME, DATE''' + ins_values
print(ins_values)

sha1 = "'olakase'"
BitName = "'ConPronoc'"
date = "'12.04.23'"

res_values = "\rVALUES (" + sha1 + ", " + BitName + ", " + date + ", "

for one_value in values:  
     if one_value:
        one_value = one_value.replace(" ","")    
        if one_value.isdigit():
            res_values += " {},".format(one_value)
        else:
            res_values += " '{}',".format(one_value)

if res_values.endswith(","):
    res_values = res_values[:-1]

res_values = res_values + ")"

print(res_values)


insert_data = ins_values + res_values

print("")
print(insert_data)

try:
    # Executing the SQL command
    # No dynamic data:
    cursor.execute(insert_data)
    # Dynamic data:
    #cursor.execute(insert_data, data)

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


conn.close()