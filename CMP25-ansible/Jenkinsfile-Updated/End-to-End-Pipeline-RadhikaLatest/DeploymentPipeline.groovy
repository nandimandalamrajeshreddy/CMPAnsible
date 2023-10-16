appliance_url = 'initial_value'
pipeline
{
    options 
	{
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
  	agent any
    stages 
	{ 
		stage('Clone')
		{   
			// Cloning the latest code from Bitbucket 
            steps
			{
                    
				node ('USTR-MVM-1481')
				{
					ws('/usr/local/cmp')
					{                            
						retry(2) 
						{
							checkout([$class: 'GitSCM', branches: [[name: '*/dev']], doGenerateSubmoduleConfigurations: false, extensions: [], gitTool: 'jgit', submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'c8d7c81a-e81c-4fe8-b492-af774f07d0ca', url: 'https://ustr-bitbucket-1.na.uis.unisys.com:8443/scm/cmp/cmp_main.git']]])
						}
						
						withCredentials([usernamePassword(credentialsId: 'c8d7c81a-e81c-4fe8-b492-af774f07d0ca', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
							   sh '''
                                   cd /usr/local/cmp
                                   '''
                               sh '''git config http.sslverify false'''
                               sh '''git config user.name "CMP"'''
                               sh '''git config user.email "CMP@Unisys.com"'''
                               sh ''' echo git CMP_BUILD_3.1.$BUILD_NUMBER tag applying ------- '''
							   sh '''
                                    cd /usr/local/cmp
                                     git tag -a CMP_BUILD_3.1.$BUILD_NUMBER -m "CMP_BUILD_3.1.$BUILD_NUMBER"
                                   '''
                               sh '''
                                      git push https://$USERNAME:$PASSWORD@ustr-bitbucket-1.na.uis.unisys.com:8443/scm/cmp/cmp_main.git CMP_BUILD_3.1.$BUILD_NUMBER '''
						}
						
					}    
				}
            }
        }
		
		stage('Build Artifact')
        {    
            steps
			{
                    
				node ('USTR-MVM-1481')
				{
					ws('/usr/local/cmp')
					{        
						sh '''
						echo "**********************************$(date "+%m%d%Y %T") : Building the CMP Package**********************************"   
						mkdir Nexus
						cd /usr/local/cmp/morpheus/auto_script/api/python   
						echo "**********************************$(date "+%m%d%Y %T") : Creating whl file from the latest python scripts**********************************"                           
						python3 -m pip install --user --upgrade setuptools wheel
						python3 setup.py bdist_wheel
						cp /usr/local/cmp/morpheus/auto_script/api/python/dist/cmp_morpheus-3.1.0-py3-none-any.whl /usr/local/cmp/Nexus/
						cd  /usr/local/cmp/morpheus/

						echo "**********************************$(date "+%m%d%Y %T") : Copying the terraform scripts, monitoring scrtips to the cmp package**********************************"  
						cp -r /usr/local/cmp/morpheus/terraform_scripts/tf_landingzone_v2/ /usr/local/cmp/Nexus/
						cp -r /usr/local/cmp/morpheus/terraform_scripts/Terraform-AWS-Patching-Monitoring/ /usr/local/cmp/Nexus/
						cp -r /usr/local/cmp/morpheus/ansible_scripts/ /usr/local/cmp/Nexus/
						cd /usr/local/cmp/Nexus
						'''
					}    
				}
            }
        }       
		
		stage('Run-terraform-Script')
		{	
			steps
			{
				node ('USTR-MVM-1481')
				{
					ws('/usr/local/cmp/Nexus')
					{
						withCredentials([string(credentialsId: 'subscription_id', variable: 'subscription_id'), string(credentialsId: 'client_id', variable: 'client_id'), string(credentialsId: 'client_secret', variable: 'client_secret'), string(credentialsId: 'tenant_id', variable: 'tenant_id'),string(credentialsId: 'awsSecretKey', variable: 'awsSecretKey'),string(credentialsId: 'awsaccessKey', variable: 'awsaccessKey'),string(credentialsId: 'LICENSE_TEXT', variable: 'LICENSE_TEXT'),string(credentialsId: 'azclientId', variable: 'azclientId'),string(credentialsId: 'azclientSecret', variable: 'azclientSecret'),string(credentialsId: 'admin_username', variable: 'admin_username'),string(credentialsId: 'admin_password', variable: 'admin_password') ,string(credentialsId: 'public_key', variable: 'public_key') ,string(credentialsId: 'private_key', variable: 'private_key'),string(credentialsId: 'ad_cred', variable: 'ad_cred'),string(credentialsId: 'cmdb_cred', variable: 'cmdb_cred'),string(credentialsId: 'vanda_cred', variable: 'vanda_cred') ])
						{

							sh '''			

							echo "**********************************$(date "+%m%d%Y %T") : Modifying the values in terraform.tfvars file**********************************"

							sed -i '/subscription_id/d' ./tf_landingzone_v2/terraform.tfvars
							sed -i '/client_id/d' ./tf_landingzone_v2/terraform.tfvars
							sed -i '/client_secret/d' ./tf_landingzone_v2/terraform.tfvars
							sed -i '/tenant_id/d' ./tf_landingzone_v2/terraform.tfvars
							sed -i "s/<<--admin_username-->>/$admin_username/g" ./tf_landingzone_v2/terraform.tfvars
							sed -i "s/<<--admin_password-->>/$admin_password/g" ./tf_landingzone_v2/terraform.tfvars
							sed -i "s/TF_PIPELINE_V3/TF_PIPELINE_V3_newtest2/g" ./tf_landingzone_v2/terraform.tfvars
							sed -i "s/cvd176xsd/cvd176xsdnewtest2/g" ./tf_landingzone_v2/terraform.tfvars
							cd /usr/local/cmp/Nexus/tf_landingzone_v2
							set +x

							echo "**********************************$(date "+%m%d%Y %T") : Provisioning terraform resources**********************************" 

							terraform init
							terraform plan -var "subscription_id=${subscription_id}" -var "client_id=${client_id}" -var "client_secret=${client_secret}" -var "tenant_id=${tenant_id}" 
							terraform apply --auto-approve -var "subscription_id=${subscription_id}" -var "client_id=${client_id}" -var "client_secret=${client_secret}" -var "tenant_id=${tenant_id}" 
							
							appliance_url=$(terraform output public_ip_address)
							terraform output public_ip_address > /usr/local/cmp/appliance-url.txt
							echo "**********************************$(date "+%m%d%Y %T") : Morpheus will be accessible at the following URL: $appliance_url	**********************************"  
							cd /usr/local/cmp/Nexus

							echo "**********************************$(date "+%m%d%Y %T") : Terraform resources successfully created**********************************" 
                            sleep 1200
							echo "**********************************$(date "+%m%d%Y %T") : Execution of Enrichment scripts**********************************"
                        
							python3 -m venv StagingEnv
							. ./StagingEnv/bin/activate
							ls
							pip3 install requests
							pip3 install tqdm
							pip3 install getpwd			

							pip3 install cmp_morpheus-3.1.0-py3-none-any.whl
			
							echo "**********************************$(date "+%m%d%Y %T") : Modifying the values in configuration.ini file**********************************"
							sed -i "s|appliance_url|https://$appliance_url|g"  /usr/local/cmp/Nexus/StagingEnv/lib/python3.6/site-packages/cmp/configuration.ini
							
							echo "**********************************$(date "+%m%d%Y %T") : Modifying the values in zones_data.json file**********************************"
							sed -i "s/<<--awsaccessKey-->>/$awsaccessKey/g" /usr/local/cmp/Nexus/StagingEnv/lib/python3.6/site-packages/cmp/manifests/zones_data.json
							sed -i "s/<<--awsSecretKey-->>/$awsSecretKey/g" /usr/local/cmp/Nexus/StagingEnv/lib/python3.6/site-packages/cmp/manifests/zones_data.json
							sed -i "s/<<--subscription_id-->>/$subscription_id/g" /usr/local/cmp/Nexus/StagingEnv/lib/python3.6/site-packages/cmp/manifests/zones_data.json
							sed -i "s/<<--tenant_id-->>/$tenant_id/g" /usr/local/cmp/Nexus/StagingEnv/lib/python3.6/site-packages/cmp/manifests/zones_data.json
							sed -i "s/<<--client_id-->>/$azclientId/g" /usr/local/cmp/Nexus/StagingEnv/lib/python3.6/site-packages/cmp/manifests/zones_data.json
							sed -i "s/<<--client_secret-->>/$azclientSecret/g" /usr/local/cmp/Nexus/StagingEnv/lib/python3.6/site-packages/cmp/manifests/zones_data.json

							sed -i "s/<<--admin_username-->>/$admin_username/g" /usr/local/cmp/Nexus/StagingEnv/lib/python3.6/site-packages/cmp/manifests/zones_data.json
							sed -i "s/<<--admin_password-->>/$admin_password/g" /usr/local/cmp/Nexus/StagingEnv/lib/python3.6/site-packages/cmp/manifests/zones_data.json
							
							echo "**********************************$(date "+%m%d%Y %T") : Modifying the values in license_data.json file**********************************"
							sed -i "s/<<--LICENSE_TEXT-->>/$LICENSE_TEXT/g" /usr/local/cmp/Nexus/StagingEnv/lib/python3.6/site-packages/cmp/manifests/license_data.json
							echo $ad_cred 
							echo $cmdb_cred 
							echo $vanda_cred
							echo "**********************************$(date "+%m%d%Y %T") : Importing the CMP configurations**********************************"
							python3 -m cmp.cmp_main newSetup -c "$admin_username/$admin_password"  $ad_cred $cmdb_cred $vanda_cred
							'''
						}						
					}	
				}				
			}
		}

		stage('Passing Appliance URL to Other Stages')
		{	
			steps
			{
				node ('USTR-MVM-1481')
				{
					ws('/usr/local/cmp/')
					{
						script 
						{
							appliance_url = readFile('/usr/local/cmp/appliance-url.txt').trim()
						}
						echo "${appliance_url}"
						sleep 1200
					}
				}
			}
		}		

		stage('Clone in Windows')
		{   
			// Cloning the latest code from Bitbucket 
      		steps
			{
  				node ('INBLR-UVM-8000')
				{
					ws('C:\\jenkins\\workspace\\CMP')
					{    
						
						retry(2) {
						checkout([$class: 'GitSCM', branches: [[name: '*/dev']], doGenerateSubmoduleConfigurations: false, extensions: [], gitTool: 'jgit', submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'c8d7c81a-e81c-4fe8-b492-af774f07d0ca', url: 'https://ustr-bitbucket-1.na.uis.unisys.com:8443/scm/cmp/cmp_main.git']]])
						}
					}    
				}
      		}	
		}

		stage('Sanity Test Run')
		{		   
			steps
			{
				cleanWs()
				node ('INBLR-UVM-8000')
				{
					ws('C:\\jenkins\\workspace\\CMP')
					{
						withCredentials([string(credentialsId: 'subscription_id', variable: 'subscription_id'), string(credentialsId: 'client_id', variable: 'client_id'), string(credentialsId: 'client_secret', variable: 'client_secret'), string(credentialsId: 'tenant_id', variable: 'tenant_id'),string(credentialsId: 'awsSecretKey', variable: 'awsSecretKey'),string(credentialsId: 'awsaccessKey', variable: 'awsaccessKey'),string(credentialsId: 'LICENSE_TEXT', variable: 'LICENSE_TEXT'),string(credentialsId: 'azclientId', variable: 'azclientId'),string(credentialsId: 'azclientSecret', variable: 'azclientSecret'),string(credentialsId: 'admin_username', variable: 'admin_username'),string(credentialsId: 'admin_password', variable: 'admin_password') ]) 
						{  
							echo appliance_url 
							withEnv(["appliance_url=$appliance_url"]) 
							{
								echo "Appliance URL : $appliance_url"
								powershell  returnStatus: true, script: '''                                
								Write-Output "********************************** Modifying the Values in Browser Config **********************************"
								
								Write-Output "Appliance URL : $env:appliance_url"
								$app_url_content = Get-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\utils\\browser_config.py'
								$app_url_newContent = $app_url_content -replace '<<--appliance_url-->>', "https://$env:appliance_url"
								$app_url_newContent | Set-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\utils\\browser_config.py'

								Write-Output "********************************** Modifying the Values in Test Data Json **********************************"

								$admin_username_content = Get-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Resources\\Testdata.json'
								$admin_username_newContent = $admin_username_content -replace '<<--admin_username-->>', "$env:admin_username"
								$admin_username_newContent | Set-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Resources\\Testdata.json'

								$admin_password_content = Get-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Resources\\Testdata.json'
								$admin_password_newContent = $admin_password_content -replace '<<--admin_password-->>', "$env:admin_password"
								$admin_password_newContent | Set-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Resources\\Testdata.json'

								$public_key_content = Get-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Resources\\Testdata.json'
								$public_key_newContent = $public_key_content -replace '<<--public_key-->>', "$env:public_key"
								$public_key_newContent | Set-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Resources\\Testdata.json'
								
								$private_key_content = Get-Content -Path'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Resources\\Testdata.json'
								$private_key_newContent = $private_key_content -replace '<<--private_key-->>', "$env:private_key"
								$private_key_newContent | Set-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Resources\\Testdata.json'
								'''

								bat '''
								echo "********************************** Start Pytest Execution **********************************"
								DIR
								XCOPY /s C:\\jenkins\\sanitytest C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation
								CD C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Driver
								pip install -r requirements.txt
								CD C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\tests\\test_sanity
								python -m integration.py					
								echo "********************************** End of Pytest Execution **********************************"
								'''
							}
						} 
					    echo 'Cleaning Up Windows Workspace!!'
					    cleanWs()   
					}         
				}     
			}
		}  

		stage('Approval for destroying terraform resources and cleaning workspace')
        {
			steps
			{
				node ('USTR-MVM-1481')
				{
					ws('/usr/local/cmp/Nexus/tf_landingzone_v2')
					{ 
						script
						{ 
							def mailRecipients = 'k.dandapath@unisys.com,vishal.gupta2@unisys.com,radhika.bhardwaj2@in.unisys.com'
							def approversList = 'DandapK1,GuptaVi1,bhardwr2'
							def jobName = currentBuild.fullDisplayName
							def userAborted = false
							emailext body: '''
							Please go to console output of ${BUILD_URL}input to approve or Reject.<br>
							''',    
							mimeType: 'text/html',
							subject: "[Jenkins] ${jobName} Build Approval Request",
							to: "${mailRecipients}",
							replyTo: "${mailRecipients}",
							recipientProviders: [[$class: 'CulpritsRecipientProvider']]

							echo "Email Triggered for approval of pipeline"
							try 
							{ 
								userInput = input submitter: "${approversList}", message: 'Do you approve?'
							} 
							catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException e) 
							{
								cause = e.causes.get(0)
								echo "Aborted by " + cause.getUser().toString()
								userAborted = true
								echo "SYSTEM aborted, but looks like timeout period didn't complete. Aborting."
							}
							if (userAborted) 
							{
								currentBuild.result = 'ABORTED'
								echo "Build aborted by user/Unauthorized Access"
							} 
							else 
							{
								withCredentials([string(credentialsId: 'subscription_id', variable: 'subscription_id'), string(credentialsId: 'client_id', variable: 'client_id'), string(credentialsId: 'client_secret', variable: 'client_secret'), string(credentialsId: 'tenant_id', variable: 'tenant_id'),string(credentialsId: 'awsSecretKey', variable: 'awsSecretKey'),string(credentialsId: 'awsaccessKey', variable: 'awsaccessKey'),string(credentialsId: 'LICENSE_TEXT', variable: 'LICENSE_TEXT'),string(credentialsId: 'azclientId', variable: 'azclientId'),string(credentialsId: 'azclientSecret', variable: 'azclientSecret'),string(credentialsId: 'admin_username', variable: 'admin_username'),string(credentialsId: 'admin_password', variable: 'admin_password')  ]) 
								{
								// some block
								sh '''
								echo "**********************************$(date "+%m%d%Y %T") : Yes is selected, hence destroying the terraform resources**********************************"

								set +x

								terraform destroy --auto-approve -var "subscription_id=${subscription_id}" -var "client_id=${client_id}" -var "client_secret=${client_secret}" -var "tenant_id=${tenant_id}" 
								echo "**********************************$(date "+%m%d%Y %T") : Terraform Destroy executed successfully**********************************"
								sleep 480
								echo "**********************************$(date "+%m%d%Y %T") :Cleaning workspace - Start **********************************"
								cd /usr/local/
							
								echo "**********************************$(date "+%m%d%Y %T") :Cleaning workspace - End**********************************"
								'''
								}
							}
						}
					}
				}
			}
        }

		stage('Cleaning workspace')
		{
			steps
			{
				node ('USTR-MVM-1481')
				{
					ws('/usr/local/cmp')
					{ 
						echo 'Cleaning Up Windows Workspace!!'
						cleanWs()   
					}
				}
			}
		}
	}
}																
