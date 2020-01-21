import psycopg2
from collections import defaultdict
import os, sys

_user = "hrms"
_pass = "hrmspramati"
_host = "13.235.160.20"
_db   = "HRMS"
_port = "5432"

_dbpath = _user+"/"+_db
_funcpath = _dbpath+"/Functions"
_tblpath = _dbpath+"/Tables"
_trgpath  = _dbpath+"/Triggers"
_timeopt = "true"

conn = psycopg2.connect(database =_db, user = _user, password =_pass, host = _host, port =_port)
print("Opened database successfully")


if not os.path.isdir(_user):
   os.makedirs(_user)
if not os.path.isdir(_dbpath):
   os.makedirs(_dbpath)


if not os.path.isdir(_funcpath):
   os.makedirs(_funcpath)

cur = conn.cursor()
cur.execute("SELECT * FROM get_function_ddl('"+_user+"',"+_timeopt+")")
result = cur.fetchall()
for row in result:
    print(row[0])
    print(row[1])
    with open(_funcpath+"/"+row[0]+'.sql', 'w') as f:
        f.write(''.join(row[1]))



cur.execute("SELECT * FROM get_tables_ddl('"+_user+"',"+_timeopt+")")
rows = cur.fetchall()
d = defaultdict(list)
for col1, col2 in rows:
    d[col1].append(col2)

if not os.path.isdir(_tblpath):
   os.makedirs(_tblpath)

for _d in d.items():
    with open(_tblpath+"/"+_d[0]+'.sql', 'w') as f:
        for row in _d[1]:
            print(row)
            f.write("%s\n" % ''.join(row))

if not os.path.isdir(_trgpath):
   os.makedirs(_trgpath)

cur.execute("SELECT * FROM get_triggers_ddl('"+_user+"',"+_timeopt+")")
result = cur.fetchall()
for row in result:
    if row[1] is not None:
        print(row[0])
        print(row[1])
        with open(_trgpath+"/"+row[0]+'.sql', 'w') as f:
            f.write(''.join(row[1]))

print("Operation done successfully.!")
conn.close()




