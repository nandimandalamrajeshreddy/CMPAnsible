pipeline
{   
  agent any
  stages 
  { 
    stage('Clone in Windows')
		{   
			// Cloning the latest code from Bitbucket testing
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
            withCredentials([string(credentialsId: 'subscription_id', variable: 'subscription_id'), string(credentialsId: 'client_id', variable: 'client_id'), string(credentialsId: 'client_secret', variable: 'client_secret'), string(credentialsId: 'tenant_id', variable: 'tenant_id'),string(credentialsId: 'awsSecretKey', variable: 'awsSecretKey'),string(credentialsId: 'awsaccessKey', variable: 'awsaccessKey'),string(credentialsId: 'LICENSE_TEXT', variable: 'LICENSE_TEXT'),string(credentialsId: 'azclientId', variable: 'azclientId'),string(credentialsId: 'azclientSecret', variable: 'azclientSecret'),string(credentialsId: 'admin_username', variable: 'admin_username'),string(credentialsId: 'admin_password', variable: 'admin_password'),string(credentialsId: 'appliance_url', variable: 'appliance_url') ]) 
            {    
                powershell  returnStatus: true, script: '''                                
                Write-Output "********************************** Modifying the Values in Browser Config and Test Data Json **********************************"
                
                Write-Output "Appliance URL : $env:appliance_url"
                $app_url_content = Get-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\utils\\browser_config.py'
                $app_url_newContent = $app_url_content -replace '<<--appliance_url-->>', "https://$env:appliance_url"
                $app_url_newContent | Set-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\utils\\browser_config.py'


                $admin_username_content = Get-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Resources\\Testdata.json'
                $admin_username_newContent = $admin_username_content -replace '<<--admin_username-->>', "$env:admin_username"
                $admin_username_newContent | Set-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Resources\\Testdata.json'

                $admin_password_content = Get-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Resources\\Testdata.json'
                $admin_password_newContent = $admin_password_content -replace '<<--admin_password-->>', "$env:admin_password"
                $admin_password_newContent | Set-Content -Path 'C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Resources\\Testdata.json'
                '''

                bat '''
                echo "********************************** Start Pytest Execution **********************************"
                DIR
                XCOPY /s C:\\jenkins\\sanitytest C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation
                CD C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\Driver
                pip install -r requirements.txt
                CD C:\\jenkins\\workspace\\CMP\\morpheus\\qa_automation\\tests\\test_sanity
                python -m sanity.py

                echo "********************************** End of Pytest Execution **********************************"
                '''
            }  
         
          }         
        }
      }
    }  
  }
  
  	post {
										success {
 
											script {
          
												  def mailRecipients = 'naga.jyothi@unisys.com'
													def jobName = currentBuild.fullDisplayName
													emailext body: '''${SCRIPT, template="groovy-html.template"}''',
													mimeType: 'text/html',
													subject: "SUCCESS: ${currentBuild.fullDisplayName}",
													to: "${mailRecipients}",
													replyTo: "${mailRecipients}",
													recipientProviders: [[$class: 'CulpritsRecipientProvider']]
													}
											}
										}
}