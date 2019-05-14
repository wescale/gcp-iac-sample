import mysql.connector
from mysql.connector import Error
import os
 
""" Connect to MySQL database """
conn = ''
cursor = ''
try:
    conn = mysql.connector.connect(host=os.environ['MYSQL_HOST'],
                                    user=os.environ['MYSQL_USER'],
                                    password=os.environ['MYSQL_PASSWORD'])
    if conn.is_connected():
        print('Connected to MySQL database')


    query_db = "CREATE DATABASE " + os.environ['CREATE_DATABASE']
    query_user = "GRANT ALL PRIVILEGES ON "+os.environ['CREATE_DATABASE']+".* TO '"+os.environ['CREATE_USER']+"'@'%' IDENTIFIED BY '"+os.environ['CREATE_PASSWORD']+"'"
    
    cursor = conn.cursor()

    print("DB create..." + query_db)
    cursor.execute(query_db)
    print("User create..." + query_user)
    cursor.execute(query_user)

except Error as e:
    print(e)

finally:
    cursor.close()
    conn.close()
 