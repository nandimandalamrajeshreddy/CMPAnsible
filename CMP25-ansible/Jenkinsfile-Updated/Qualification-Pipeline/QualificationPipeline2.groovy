pipeline{
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    
  agent {label 'USTR-MVM-1481'}
  
    stages { 
     
    
        stage('Clone')
        {    
            steps{
                    
                    node ('USTR-MVM-1481')
                    {
                        ws('/usr/local/cmptest')
                        {                            
                            retry(2) {
                            checkout([$class: 'GitSCM', branches: [[name: '*/dev']], doGenerateSubmoduleConfigurations: false, extensions: [], gitTool: 'jgit', submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'c8d7c81a-e81c-4fe8-b492-af774f07d0ca', url: 'https://ustr-bitbucket-1.na.uis.unisys.com:8443/scm/cmp/cmp_main.git']]])
                            }
							
                        }    
                    }
                }
        }
        stage('Build Artifacts')
        {    
            steps{
                    
                    node ('USTR-MVM-1481')
                    {
                    ws('/usr/local/cmptest')
                        {        
                            sh '''
                            mkdir Nexus
                            cd /usr/local/cmptest/morpheus/auto_script/api/python                                   
                            python3 -m pip install --user --upgrade setuptools wheel
                            python3 setup.py bdist_wheel
                            cp /usr/local/cmptest/morpheus/auto_script/api/python/dist/cmp_morpheus-3.1.0-py3-none-any.whl /usr/local/cmptest/Nexus/
                            cd  /usr/local/cmptest/morpheus/
							cp -r /usr/local/cmptest/morpheus/terraform_scripts/tf_landingzone_v2/ /usr/local/cmptest/Nexus/
                            cp -r /usr/local/cmptest/morpheus/terraform_scripts/Terraform-AWS-Patching-Monitoring/ /usr/local/cmptest/Nexus/
							cp -r /usr/local/cmptest/morpheus/terraform_scripts/azure_native_patching_monitoring_tf/ /usr/local/cmptest/Nexus/
                            cp -r /usr/local/cmptest/morpheus/ansible_scripts/ /usr/local/cmptest/Nexus/
                            cd /usr/local/cmptest/Nexus
                            rm -rf Release.zip
                            zip -r Release.zip *
                            '''
            

    
                        }    
                    }
                }
        }
		
		stage('Sonar-Scanner execute')
        {
            steps{
                    node ('USTR-MVM-1481'){
						ws('/usr/local/cmptest/')
                                {
									sh '''
										cd  /root/sonar-scanner-4.5.0.2216-linux/bin
										./sonar-scanner
										
									'''
								
									
									
								}
                            
                    }
            }
        }
        stage('NexusUpload')
        {
            steps{
                    node ('USTR-MVM-1481'){
						ws('/usr/local/cmptest/Nexus')
                                {
									configFileProvider([configFile(fileId: "01153b47-9411-4b10-9d0f-2e2a6d54e2e4", variable: 'USER_SETTINGS_XML')]) {
								sh ''' /root/apache-maven-3.3.1/bin/mvn -B -s ${USER_SETTINGS_XML} deploy:deploy-file -DrepositoryId=ustr-nexus-2 -Durl=https://ustr-nexus-2.na.uis.unisys.com/content/repositories/snapshots/ -Dfile=Release.zip -DgroupId=com.unisys.cmp -DartifactId=cmp -Dversion=3.1-$BUILD_NUMBER-SNAPSHOT -DgeneratePom=true -Dpackaging=zip '''
			                     }
									
									sh '''rm -rf *'''
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
					ws('/usr/local/cmptest/')
					{ 
						echo 'Cleaning Up the package upload Workspace!!'
						cleanWs()   
					}
				}
			}
		}
		
		
		
		
        
}
							post {
										success {
 
											script {
          
												   def buildmailRecipients = 'Radhika.Bhardwaj2@unisys.com'
													def jobName = currentBuild.fullDisplayName
													emailext body: '''${SCRIPT, template="groovy-html.template"}''',
													mimeType: 'text/html',
													subject: "SUCCESS: ${currentBuild.fullDisplayName}",
													to: "${buildmailRecipients}",
													replyTo: "${buildmailRecipients}",
													recipientProviders: [[$class: 'CulpritsRecipientProvider']]
													}
											}
										}

								
}