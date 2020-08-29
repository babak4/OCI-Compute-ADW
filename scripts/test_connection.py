import configparser
import cx_Oracle as cx

def get_db_credentails():
    config = configparser.ConfigParser()
    config.read('always_free.ini')
    db_config = config['database']
    return db_config['username'], db_config['password'], db_config['connection_name']

def main():
    print("Testing the connection to ADW01")
    db_username, db_password, db_connection_name = get_db_credentails()
    with cx.connect(db_username, db_password, db_connection_name) as conn:
        cursor = conn.cursor()
        rs = cursor.execute("select banner_full from v$version")
        print(rs.fetchall()[0][0])

if __name__ == '__main__':
    main()
