NonCPS
def revisionByBuildNumber(def jobName, def buildNumber) {
    revisionNo = ""
    try {
        def instance = Hudson.instance
        def job = instance.getItemByFullName(jobName)
        def build = job.getBuild("${buildNumber}")
        println('Job Name :: '+ jobName + ' :::: Build Number :: ' + buildNumber)
        println('Build status :: '+ build)
        def buildInfo = build.getActions(hudson.plugins.git.util.BuildData.class)[0]
        if (!buildInfo) {
            println("No build data available for given build number : " + buildNumber +
                    " Please rebuild or provide valid build number")
            throw new RuntimeException(" Invalid Build number ")
        }
        revisionNo = buildInfo.getLastBuiltRevision().sha1String.substring(0, 7)
    }
    catch (Exception e) {
        errorMessage = "revisionByBuildNumber failed for  following parameters  " +
                "Job Name : " + jobName + " Build No : " + buildNumber
        throw new Exception(errorMessage, e)
    }
    return revisionNo
}


@NonCPS
def checkBuildWasSucessfull(def jobName, def buildNumber) {

    buildStatus = false
    try {
        def instance = Hudson.instance
        def job = instance.getItemByFullName(jobName)
        def build = job.getBuild("${buildNumber}")
        if (!build) {
            println(" No build data available for given build number : " + buildNumber +
                    " Please rebuild or provide valid build number")
            throw new RuntimeException(" Invalid Build number " + buildNumber)
        }
        if (build.result.toString() == "SUCCESS") {
            buildStatus = true
        } else {
            println("FAILED !!!! The build number being used had not build successfully")
        }
    }
    catch (Exception e) {
        errorMessage = " checkBuildWasSucessfull failed for  following parameters  " +
                "Job Name : " + jobName + " Build No : " + buildNumber
        throw new Exception(errorMessage, e)
    }
    return buildStatus
}


@NonCPS
def checkBuildWasNotUsedForDeployment(def jobName, def buildNumber) {
    goodToDeploy = false
    try {
        def instance = Hudson.instance
        def job = instance.getItemByFullName(jobName)
        def build = job.getBuild("${buildNumber}")
        if (!build) {
            println(" No build data available for given build number : " + buildNumber +
                    " Please rebuild or provide valid build number")
            throw new RuntimeException(" Invalid Build number " + buildNumber)
        }
        def build_params = build.getActions(hudson.model.ParametersAction.class)[0]
        def build_no_build_param = build_params.parameters.find { it.name == "BUILD_NUMBER" }
        if (build_no_build_param.value.length() == 0 && build.result.toString() == "SUCCESS") {
            goodToDeploy = true
        }

        if (goodToDeploy) {
            println("The build number is linked to a build .")
        } else {
            println("FAILED !!!! The build number was used for deployment")
        }
    }
    catch (Exception e) {
        errorMessage = "checkBuildWasNotUsedForDeployment failed for  following parameters  " +
                "Job Name : " + jobName + " Build No : " + buildNumber
        throw new Exception(errorMessage, e)
    }
    return goodToDeploy
}


@NonCPS
def checkDeploymentOccurredInEnv(def jobName, def commitId, def env) {
    goodToDeploy = false
    try {
        def instance = Hudson.instance
        def job = instance.getItemByFullName(jobName)
        def searchStringDeploy = env + "_" + "DEPLOY" + "_" + commitId
        def searchStringBuildAndDeploy = env + "_" + "BUILD_AND_DEPLOY" + "_" + commitId
        def filtered_builds = []
        def builds = job.builds.each {
            def build = job.getBuild("${it.number}")
            if ((build.description.toString() == searchStringDeploy)
                    || (build.description.toString() == searchStringBuildAndDeploy)) {
                filtered_builds.add(it)
            }
        }
        def sorted_builds = filtered_builds.sort { -it.number }
        println(" Build number being checked " + sorted_builds[0].number)
        if (sorted_builds[0].result.toString() == "SUCCESS") {
            goodToDeploy = true
        }

    }
    catch (Exception e) {
        errorMessage = " checkDeploymentOccurredInEnv failed for  following parameters  Job Name : "
        +jobName + " Commit Id : " + commitId + " Environment : " + env
        throw new Exception(errorMessage, e)
    }
    return goodToDeploy
}


pipeline {
    agent {
        docker {
            image 'python:3.7-buster'
            label 'jenkins-slave'
            args '-v /var/run/docker.sock:/var/run/docker.sock -e http_proxy=$http_proxy ' +
                    '-e HTTPS_PROXY=$http_proxy -e no_proxy=$no_proxy -e APP_ENV=$ENV_NAME'
        }

    }
    environment {
        CI = 'true'
    }
    stages {
        stage("Setup") {
            steps {
                git branch: params.BRANCH_NAME, url: 'https://bitbucket.bip.uk.fid-intl.com/scm/beh/bf-nlp-keyword-extraction.git'
                script {
                    currentBuild.description = params.ENV_NAME

                    if (params.ACTION == "build") {
                        currentBuild.description += "_" + "BUILD"
                    } else if (params.ACTION == "build_and_deploy") {
                        currentBuild.description += "_" + "BUILD_AND_DEPLOY"
                    } else if (params.ACTION == "deploy") {
                        currentBuild.description += "_" + "DEPLOY"
                    }
                    println('Setup Build number :: '+ params.BUILD_NUMBER)
                    println('Setup Job name :: '+ "${JOB_NAME}")
                    if (params.BUILD_NUMBER) {
                        COMMIT_ID = revisionByBuildNumber("${JOB_NAME}", params.BUILD_NUMBER)
                        currentBuild.description += "_" + COMMIT_ID
                    } else {
                        COMMIT_ID = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                        currentBuild.description += "_" + COMMIT_ID
                    }
                    println COMMIT_ID
                }
                sh "echo ****************************************"
                sh "echo install python dependencies for infra"
                sh "echo ****************************************"
                sh "GIT_COMMIT_SHORT=$COMMIT_ID make install-python-dependencies"
                sh "GIT_COMMIT_SHORT=$COMMIT_ID make deploy-infra"
            }
        }
        stage('Build') {
            when {
                allOf {
                    expression { return (params.ACTION == "build" || params.ACTION == "build_and_deploy") }
                }
            }
            steps {
                script {
                    if (params.ENV_NAME != "dev") {
                        println " Stage : Build . Status : FAILED . " +
                                "Reason : Build cannot be done on beta or prod environment "
                        throw new RuntimeException("Build cannot be done on " + params.ENV_NAME + " environment")
                    }
                }

                sh 'echo ****************************************'
                sh 'echo build and push docker image'
                sh 'echo ****************************************'
                sh "GIT_COMMIT_SHORT=$COMMIT_ID make build-and-push-images-to-ecr"
            }
        }

    }
}
