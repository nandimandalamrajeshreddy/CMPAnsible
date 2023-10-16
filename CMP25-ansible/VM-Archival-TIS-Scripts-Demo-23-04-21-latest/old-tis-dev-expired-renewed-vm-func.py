import os
import json
import csv
import math
import subprocess
import datetime
from datetime import datetime
from datetime import timedelta  


###################################################################### Function Block ######################################################################
def value_func():
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
    
    if not i['cloud']:
        cloud_value = 'Empty'
    else:
        cloud_value = i['cloud']['name']
    
    return vmname_value, info_value, spec_value, vmstate_value, group_value,owner_value,cloud_value

def dedicatedRPoolShutdownVM():
    #print ("Shutdown Date for", i['name'], "-", shutdown_date.date(),"\n")                      
    vmname_value, info_value, spec_value, vmstate_value, group_value,owner_value,cloud_value = value_func()
    with open(FILEPATH+'\shutdownVM_Report-'+TODAYS_DATE+'.csv', 'a', newline='') as ca:
        writer = csv.writer(ca)
        writer.writerow([vmname_value, info_value, shutdown_date_value, spec_value, vmstate_value, group_value,owner_value,cloud_value])

def shutdownDateGreaterThanToday():
    #print ("Shutdown Date for", i['name'], "-", shutdown_date.date())
    #print (i['name']," VM is Renewed and in Running/Stopped State \n") 
    vmname_value, info_value, spec_value, vmstate_value, group_value,owner_value,cloud_value = value_func()                    
    with open(FILEPATH+'\RenewedVM_Report-'+TODAYS_DATE+'.csv', 'a', newline='') as ca:
        writer = csv.writer(ca)
        writer.writerow([vmname_value, info_value, shutdown_date_value, spec_value, vmstate_value, group_value,owner_value,cloud_value])

def shutdownDateEqualToToday(): 
    #print ("Shutdown Date for", i['name'], "-", shutdown_date.date())
    # print (i['owner']['username'], "has 7 days Grace Period to Renew or expire \n")
    vmname_value, info_value, spec_value, vmstate_value, group_value,owner_value,cloud_value = value_func() 
    with open(FILEPATH+'\GracePeriod7DaysVM_report-'+TODAYS_DATE+'.csv', 'a', newline='') as ca:
        writer = csv.writer(ca)
        writer.writerow([vmname_value, info_value, shutdown_date_value, spec_value, vmstate_value, group_value,owner_value,cloud_value]) 

def shutdownDateLessThanToday():
    #print ("Shutdown Date for", i['name'], "-", shutdown_date.date())
    #print (i['name']," will expire on", shutdown_date.date() + timedelta(days=7), "\n")
    expireDate_value=shutdown_date.date() + timedelta(days=7)
    vmname_value, info_value, spec_value, vmstate_value, group_value,owner_value,cloud_value = value_func() 
    with open(FILEPATH+'\ExpiredVM_report-'+TODAYS_DATE+'.csv', 'a', newline='') as ca:
        writer = csv.writer(ca)
        writer.writerow([vmname_value, info_value, shutdown_date_value, spec_value, vmstate_value, group_value,owner_value,cloud_value,expireDate_value])         


###################################################################### Main Block ######################################################################

TODAYS_DATE = datetime.now().strftime("%d-%m-%Y")
FILEPATH = "C:\TIS"
#subprocess.run('morpheus remote use tis-unisys', shell = True)
#subprocess.run('morpheus logout', shell = True)

#Mention the user_name and password of the subtenant in quotes 
#subprocess.run('morpheus login -u "GuptaVi1" -p "Password"', shell = True)
#subprocess.run('morpheus instances list -m 100 --json > '+FILEPATH+'\instances_report-'+TODAYS_DATE+'.json', shell = True)


#with open(FILEPATH+'\instances_report-'+TODAYS_DATE+'.json') as f:
with open(FILEPATH+'\instances_report-old.json') as f:
    data = json.load(f)

with open(FILEPATH+'\shutdownVM_report-'+TODAYS_DATE+'.csv', 'w', newline='') as c:
    writer = csv.writer(c)
    writer.writerow(["VM Name","IP Address","Shutdown Date","Instance Spec","VM-State","Group","Owner","Cloud"])

with open(FILEPATH+'\RenewedVM_report-'+TODAYS_DATE+'.csv', 'w', newline='') as c:
    writer = csv.writer(c)
    writer.writerow(["VM Name","IP Address","Shutdown Date","Instance Spec","VM-State","Group","Owner","Cloud"])

with open(FILEPATH+'\GracePeriod7DaysVM_report-'+TODAYS_DATE+'.csv', 'w', newline='') as c:
    writer = csv.writer(c)
    writer.writerow(["VM Name","IP Address","Shutdown Date","Instance Spec","VM-State","Group","Owner","Cloud"])

with open(FILEPATH+'\ExpiredVM_report-'+TODAYS_DATE+'.csv', 'w', newline='') as c:
    writer = csv.writer(c)
    writer.writerow(["VM Name","IP Address","Shutdown Date","Instance Spec","VM-State","Group","Owner","Cloud","ExpireDate"])

###########################################Travering in the JSON File###########################################
for i in data['instances']:
    try: 

        if 'resourcePoolId' in i['config']:
            resourcePoolVar=i['config']['resourcePoolId']
            #print ("Resource Pool ID for ", i['name'] ,resourcePoolVar)

            if resourcePoolVar != 154:
                if i['shutdownDate'] is not None:        
                    shutdown_date_value=i['shutdownDate']
                    shutdown_date=datetime.strptime(shutdown_date_value, '%Y-%m-%dT%H:%M:%SZ')
                    
                    if shutdown_date.date() <= datetime.today().date():
                        dedicatedRPoolShutdownVM()
                    else:
                        pass               
                else:
                    #print ("Shutdown Date for", i['name'], "not Set \n")
                    pass
            
            elif resourcePoolVar == 154:
                #print ("VM", i['name'], "lies in Archived Resource Pool") 
                if i['shutdownDate'] is not None:        
                    shutdown_date_value=i['shutdownDate']
                    shutdown_date=datetime.strptime(shutdown_date_value, '%Y-%m-%dT%H:%M:%SZ')
                             
                    vmstate_value=i['status']               
                    if shutdown_date.date() > datetime.today().date() and vmstate_value == 'running':
                        shutdownDateGreaterThanToday()
                             
                    elif shutdown_date.date() > datetime.today().date() and vmstate_value == 'stopped': 
                        shutdownDateGreaterThanToday()
                    
                    elif shutdown_date.date() == datetime.today().date(): 
                        shutdownDateEqualToToday()
                    
                    elif shutdown_date.date() < datetime.today().date():
                        shutdownDateLessThanToday()

                    else:
                        pass
                else:
                    #print ("Shutdown Date for", i['name'], "not Set \n")
                    pass
            else:
                pass
        else:
            #print ("Resource Pool for VM: ", i['name'], "does not exist. So Not Checking the  Shutdown Date as well \n")
            pass
    except Exception as e:
        print (e)


#os.remove("C:\TIS\instances_report-"+TODAYS_DATE+".json")