#!/usr/bin/env python3
import psycopg2
current_userid = None

#####################################################
##  Database Connection
#####################################################



'''
Connect to the database using the connection string
'''
def openConnection():
    # connection parameters - ENTER YOUR LOGIN AND PASSWORD HERE

    myHost = ""
    userid = ""
    passwd = ""
    
    # Create a connection to the database
    conn = None
    try:
        # Parses the config file and connects using the connect string
        conn = psycopg2.connect(database=userid,
                                    user=userid,
                                    password=passwd,
                                    host=myHost)

    except psycopg2.Error as sqle:
        print("psycopg2.Error : " + sqle.pgerror)
    
    # return the connection to use
    return conn

'''
Validate salesperson based on username and password
'''
def checkLogin(login, password, conn = None):
    global current_userid
    if conn is None:
        conn = openConnection()
    try:
        curs = conn.cursor()
        curs.execute(
            "SELECT username, firstname, lastname FROM salesperson WHERE  username ILIKE %s and password = %s", 
            (login,password)
        )
        row = curs.fetchone()
        if row is not None:
            current_userid = row[0]  # mark down current userid
            curs.close()
            conn.close()
            return row  # return (username, firstname, lastname)
        else:
            curs.close()
            conn.close()
            return None
    except psycopg2.Error as sqle:
        print(sqle.pgerror)
        if conn:
            conn.close()
        return None

"""
    Retrieves the summary of car sales.

    This method fetches the summary of car sales from the database and returns it 
    as a collection of summary objects. Each summary contains key information 
    about a particular car sale.

    :return: A list of car sale summaries.
"""
def getCarSalesSummary():
    conn = openConnection()
    try:
        curs = conn.cursor()
        curs.execute("SELECT * FROM get_sales_summary();")

        ls = []
        row = curs.fetchone()
        if row is not None:
            while row is not None:
                if row[5] == None:
                    temp_dict = {'make':row[0],'model':row[1],'availableUnits':row[2],'soldUnits':row[3],'soldTotalPrices':row[4],'lastPurchaseAt':''}
                else:
                    temp_dict = {'make':row[0],'model':row[1],'availableUnits':row[2],'soldUnits':row[3],'soldTotalPrices':row[4],'lastPurchaseAt':row[5]}
                ls.append(temp_dict)
                row = curs.fetchone()
            curs.close()
            conn.close()
            return ls
        else:
            curs.close()
            conn.close()
            return
    except psycopg2.Error as sqle:
        print("psycopg2.Error : " + sqle.pgerror)


"""
    Finds car sales based on the provided search string.

    This method searches the database for car sales that match the provided search 
    string. See assignment description for search specification

    :param search_string: The search string to use for finding car sales in the database.
    :return: A list of car sales matching the search string.
"""
def findCarSales(searchString, conn=None):
    global current_userid
    if conn is None:
        conn = openConnection()
    curs = conn.cursor()
    
    if not searchString or searchString.strip() == '':
        curs.execute("SELECT * FROM find_car_sales(%s)", (current_userid,))
    else:
        curs.execute("SELECT * FROM find_car_sales(%s)", (searchString,))
    results = curs.fetchall()
    columns = [desc[0] for desc in curs.description]
    curs.close()
    conn.close()
    dict_results = []
    for row in results:
        row_dict = dict(zip(columns, row))
        if 'builtyear' in row_dict:
            row_dict['builtYear'] = row_dict.pop('builtyear')
        if 'issold' in row_dict:
            row_dict['isSold'] = row_dict.pop('issold')
        for k, v in row_dict.items():
            if v is None and k not in ['isSold', 'builtYear']:
                row_dict[k] = ''
        dict_results.append(row_dict)
    if dict_results:
        print(dict_results[0])
    return dict_results

"""
    Adds a new car sale to the database.

    This method accepts a CarSale object, which contains all the necessary details 
    for a new car sale. It inserts the data into the database and returns a confirmation 
    of the operation.

    :param car_sale: The CarSale object to be added to the database.
    :return: A boolean indicating if the operation was successful or not.
"""
def addCarSale(make, model, builtYear, odometer, price,conn=None):
    if conn is None:
        conn = openConnection()
    try:
        curs = conn.cursor()
        curs.execute("SELECT addcarsale(%s, %s, %s, %s, %s)", 
                     (make, model, builtYear, odometer, price))
        result = curs.fetchone()
        conn.commit()
        return result[0] if result else False
    except Exception as e:
        print("Error:", e)
        conn.rollback()
        return False
    finally:
        curs.close()
        conn.close()


"""
    Updates an existing car sale in the database.

    This method updates the details of a specific car sale in the database, ensuring
    that all fields of the CarSale object are modified correctly. It assumes that 
    the car sale to be updated already exists.

    :param car_sale: The CarSale object containing updated details for the car sale.
    :return: A boolean indicating whether the update was successful or not.
    更新数据库中现有的汽车销售。

    此方法更新数据库中特定汽车销售的详细信息，确保
    确保CarSale对象的所有字段都被正确修改。它假设
    要更新的汽车销售已经存在。

    car_sale: CarSale对象,包含汽车销售的更新细节。
    返回：一个布尔值，指示更新是否成功。
"""
def updateCarSale(carsaleid, buyerid, salespersonid, saledate, conn=None):
    global current_userid
    if conn is None:
        conn = openConnection()
    curs = conn.cursor()
    try:
        # 使用SQL函数进行大小写不敏感的比较
        curs.execute("SELECT LOWER(%s) = LOWER(%s)", (salespersonid, current_userid))
        if not curs.fetchone()[0]:
            return False  # 不是本人，直接拒绝
        curs.execute("SELECT update_car_sale(%s, %s, %s, %s)", (carsaleid, buyerid, salespersonid, saledate))
        conn.commit()
        result = True
    except Exception as e:
        result = False
    finally:
        curs.close()
        conn.close()
    return result



