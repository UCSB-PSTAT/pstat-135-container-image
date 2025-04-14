pipeline {
    agent none
    triggers{
        upstream(upstreamProjects: 'UCSB-PSTAT GitHub/all-spark-base/main', threshold: hudson.model.Result.SUCCESS)
    }
    environment {
        IMAGE_NAME = 'pstat135'
    }
    stages {
        stage('Build Test Deploy') {
            agent {
                kubernetes {
                    cloud 'rke-test'
                    inheritFrom 'podman'
                }
            }
            stages{
                stage('Build') {
                    steps {
                        script {
                            if (currentBuild.getBuildCauses('com.cloudbees.jenkins.GitHubPushCause').size() || currentBuild.getBuildCauses('jenkins.branch.BranchIndexingCause').size()) {
                               scmSkip(deleteBuild: true, skipPattern:'.*\\[ci skip\\].*')
                            }
                        }
                        container('podman') {
                            echo "NODE_NAME = ${env.NODE_NAME}"
                            sh 'podman build -t localhost/$IMAGE_NAME --pull --force-rm --no-cache .'
                        }
                     }
                    post {
                        unsuccessful {
                            container('podman') {
                                sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                            }
                        }
                    }
                }
                stage('Test') {
                    steps {
                        container('podman') {
                            //sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME python -c "import <library>;"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"arrow\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"aws.s3\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"bench\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"bookdown\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"data.table\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"dplyr\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"ff\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"ffbase\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"foreach\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"future\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"future.apply\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"gamlr\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"ggplot2\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"httr\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"jsonlite\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"keras\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"knitr\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"microbenchmark\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"pryr\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"RJDBC\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"rmarkdown\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"rvest\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"scattermore\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"sparklyr\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"SparkR\"); sparkR.session()"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"tensorflow\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"tfestimators\")"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME R -e "library(\"xml2\")"'
                            sh 'podman run -d --name=$IMAGE_NAME --rm --pull=never -p 8888:8888 localhost/$IMAGE_NAME start-notebook.sh --NotebookApp.token="jenkinstest"'
                            sh 'sleep 10 && curl -v http://localhost:8888/lab?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                        }
                    }
                    post {
                        always {
                            container('podman') {
                                sh 'podman rm -ifv $IMAGE_NAME'
                            }
                        }
                        unsuccessful {
                            container('podman') {
                                sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                            }
                        }
                    }
                }
                stage('Deploy') {
                    when { branch 'main' }
                    environment {
                        DOCKER_HUB_CREDS = credentials('DockerHubToken')
                    }
                    steps {
                        container('podman') {
                            sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://docker.io/ucsb/$IMAGE_NAME:latest --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                            sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://docker.io/ucsb/$IMAGE_NAME:v$(date "+%Y%m%d") --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                        }
                    }
                    post {
                        always {
                            container('podman') {
                                sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                            }
                        }
                    }
                }                
            }
            post {
                always {
                    container('podman') {
                        sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                    }
                }
            }
        }
    }
    post {
        success {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', color: 'good', message: "Build ${env.JOB_NAME} ${env.BUILD_NUMBER} just finished successfull! (<${env.BUILD_URL}|Details>)")
        }
        failure {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', color: 'danger', message: "Uh Oh! Build ${env.JOB_NAME} ${env.BUILD_NUMBER} had a failure! (<${env.BUILD_URL}|Find out why>).")
        }
    }
}
