pipeline{
    environment {
        WRKSP = "/usr/local/cmptest"
    }

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
                        ws(WRKSP)
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
                    ws(WRKSP)
                        {        
                            sh '''
                            mkdir Nexus
                            echo $WRKSP
                            cd $WRKSP/morpheus/auto_script/api/python   
                            cd $WRKSP/morpheus/auto_script/api/python                                   
                            python3 -m pip install --user --upgrade setuptools wheel
                            python3 setup.py bdist_wheel
                            cp WRKSP/morpheus/auto_script/api/python/dist/cmp_morpheus-3.1.0-py3-none-any.whl $WRKSP/Nexus/
                            cd  $WRKSP/morpheus/
							cp -r $WRKSP/morpheus/terraform_scripts/tf_landingzone_v2/ $WRKSP/Nexus/
                            cp -r $WRKSP/morpheus/terraform_scripts/Terraform-AWS-Patching-Monitoring/ $WRKSP/Nexus/
							cp -r $WRKSP/morpheus/terraform_scripts/azure_native_patching_monitoring_tf/ $WRKSP/Nexus/
                            cp -r $WRKSP/morpheus/ansible_scripts/ $WRKSP/Nexus/
                            cd $WRKSP/Nexus
                            rm -rf Release.zip
                            zip -r Release.zip *
                            '''
            

    
                        }    
                    }
                }
        }
		
		stage('Sonar-Scanner')
        {
            steps{
                    node ('USTR-MVM-1481'){
						ws(WRKSP)
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
						ws(WRKSP)
                                {
                                    sh '''
                                    cd Nexus
                                    '''
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
					ws(WRKSP)
					{ 
						echo 'Cleaning Up the package upload new Workspace!!'
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