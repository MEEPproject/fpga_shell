import mysql.connector
from mysql.connector import (connection)

import re
import pandas as pd

import csv
import sys

def connect2db(bitstreamid_sha, name, date, filename):
    #establishing the connection
    conn = connection.MySQLConnection(user='root', password='123', host='127.0.0.1', database='MEEP_FPGA')

    #Creating a cursor object using the cursor() method
    cursor = conn.cursor()

    #Executing an MYSQL function using the execute() method
    cursor.execute("SELECT DATABASE()")

    # Fetch a single row using fetchone() method.
    data = cursor.fetchone()
    print("Connection established to: ",data)

    #Dropping RESOURCES table if already exists.
    # cursor.execute("DROP TABLE IF EXISTS RESOURCES")

    with open(filename, 'r') as file:

        # Create a CSV reader object
        reader = csv.reader(file)

        # Read the rows of the CSV file
        rows = list(reader)

        # Extract the values from the rows
        header = rows[0]
        values = rows[1]

        # Create two lists of values
        numbers = [int(value) for value in values]
        resources = [header[index] for index, value in enumerate(values)]

        # Print the lists
        print(resources)
        print(numbers)

    cursor.execute("USE MEEP_FPGA")
    #cursor.execute("DROP TABLE IF EXISTS RESOURCES")
    #cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='RESOURCES';")
    # Fetch the results of the query
    result = cursor.fetchone()

    # Execute a query to check if the table exists
    table_name = "RESOURCES"
    query = "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = %s"
    cursor.execute(query, (table_name,))

    # Get the result
    result = cursor.fetchone()[0]
    print(f"Result is {result}")

    # Prepare the data
    sql_table   = ""
    ins_columns = ""

    if result == 0:
        # Creates the table
        sql_table ='''CREATE TABLE RESOURCES(
        BITSTREAM_ID CHAR(80) NOT NULL UNIQUE,
        NAME CHAR(20) NOT NULL,
        DATE CHAR(20) NOT NULL'''

    # Concatenates the resources than have been collected by Vivado
    for field in resources:
        if field:
            sql_table  += ",\n{} INT".format(field)
            # Create a copy of the above, without the type. It will be used later when inserting.
            ins_columns += ", {}".format(field)

    # End the lists
    sql_table   += "\n   )"
    ins_columns += ")"

    
    ins_fields = '''INSERT INTO RESOURCES( BITSTREAM_ID, NAME, DATE''' + ins_columns

    sha1 = "'" + bitstreamid_sha + "'"
    BitName = "'" + name + "'"
    date = "'" + date + "'"

    res_values = "\rVALUES (" + sha1 + ", " + BitName + ", " + date + ", "

    for one_value in numbers:  

        res_values += " {},".format(one_value)

    # Remove the last semicolon and close parenthesis
    if res_values.endswith(","):
        res_values = res_values[:-1]

    res_values = res_values + ")"

    # Compose the data
    insert_data = ' '.join([ins_fields.strip(), res_values.strip()])
 

    if result:
        print("Table already exist, inserting data")
                
    else:
        print("Table doesn't exist, creating one ...")

        print("SQL_TABLE:")
        print(sql_table)
        try:
            cursor.execute(sql_table)  
            conn.commit()
        except:
            print("No table created")

    try:
        # Executing the SQL command
        # No dynamic data:
        cursor.execute(insert_data)

        # Commit changes in the database
        conn.commit()
        print("Data inserted")

    except:
        # Roll back in case of error
        conn.rollback()
        print("Data NOT inserted")


    # Debug check
    sql = """SELECT * from RESOURCES"""

    cursor.execute(sql)

    result = cursor.fetchall();
    print(result)

    conn.close()

def main(bitstreamid_sha, name, date, filename):

    print(f"bitstreamid_sha: {bitstreamid_sha}")
    print(f"name: {name}")
    print(f"date: {date}")
    print(f"filename: {filename}")

    connect2db(bitstreamid_sha, name, date, filename)

if __name__ == "__main__":
    bitstreamid_sha = sys.argv[1]
    name = sys.argv[2]
    date = sys.argv[3]
    filename = sys.argv[4]
    main(bitstreamid_sha, name, date, filename)
