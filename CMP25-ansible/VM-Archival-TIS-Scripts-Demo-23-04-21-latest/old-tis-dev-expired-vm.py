import os
import json
import csv
import math
import subprocess
import datetime
from datetime import datetime

TODAYS_DATE = datetime.now().strftime("%d-%m-%Y")


#subprocess.run('morpheus remote use tis-unisys', shell = True)
#subprocess.run('morpheus logout', shell = True)

#Mention the user_name and password of the subtenant in quotes 
#subprocess.run('morpheus login -u "GuptaVi1" -p "Password"', shell = True)
#subprocess.run('morpheus instances list -m 100 --json > C:\TIS\instances_report-'+TODAYS_DATE+'.json', shell = True)


#with open('C:\TIS\instances_report-'+TODAYS_DATE+'.json') as f:
with open('C:\TIS\instances_report-old.json') as f:
    data = json.load(f)

with open('C:\TIS\shutdownVM_report-'+TODAYS_DATE+'.csv', 'w', newline='') as c:
    writer = csv.writer(c)
    writer.writerow(["VM Name","IP Address","Shutdown Date","Instance Spec","VM-State","Group","Owner"])

###########################################Travering in the JSON File###########################################
for i in data['instances']:
    try:       
        if 'resourcePoolId' in i['config']:
            resourcePoolVar=i['config']['resourcePoolId']
            print ("Resource Pool ID for ", i['name'] ,resourcePoolVar)

            if resourcePoolVar != 154:
                if i['shutdownDate'] is not None:        
                    shutdownDateVar=i['shutdownDate']
                    shutdown_date=datetime.strptime(shutdownDateVar, '%Y-%m-%dT%H:%M:%SZ')
                    print ("Shutdown Date for", i['name'], "-", shutdown_date.date())
                    print ("\n")
            
                    with open('C:\TIS\shutdownVM_Report-'+TODAYS_DATE+'.csv', 'a', newline='') as ca:
                        writer = csv.writer(ca)
                        if shutdown_date.date() <= datetime.today().date():
                            shutdown_date_value = i['shutdownDate']
                    
                            if not i['name']:
                                vmname_value = 'Empty'
                            else:
                                vmname_value = i['name']
                            
                            if not i['connectionInfo']:
                                info_value = 'Empty'
                            else:
                                info_value = i['connectionInfo'][0]['ip']
                            
                            if not i['plan']:
                                spec_value = 'Empty'
                            else:
                                spec_value = i['plan']['name']

                            if not i['status']:
                                vmstate_value = 'Empty'
                            else:
                                vmstate_value = i['status']

                            if not i['group']:
                                group_value = 'Empty'
                            else:
                                group_value = i['group']['name']
                            
                            if not i['owner']:
                                owner_value = 'Empty'
                            else:
                                owner_value = i['owner']['username']

                            
                            writer.writerow([vmname_value, info_value, shutdown_date_value, spec_value, vmstate_value, group_value,owner_value])
                        else:
                            pass               
                else:
                    print ("Shutdown Date for", i['name'], "not Set \n")
            else:
                print ("VM", i['name'], "lies in Archived Resource Pool \n") 
        else:
            print ("Resource Pool for VM: ", i['name'], "does not exist. So Not Checking the  Shutdown Date as well \n")
    except Exception as e:
        print (e)


#os.remove("C:\TIS\instances_report-"+TODAYS_DATE+".json")