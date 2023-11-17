Publisher : Brett Howells
Date : 17/11/2023
Function : This is a test application with IAC written in terraform. The IAC will deploy an azure
           Function app, along with a static web page to call a function within
Details : The components for this application are as follows...

-------------General Infrastructure-------------
An Azure resource group : rg-fortune-handler
An Azure Storage account : fortunestorageaccount
A container within the storage account : errorcontainer 
A storage blob : errorcontainer : This will house all errors logged from both applications
An application insights instance : ai-fortune-handler
An app service plan : asp-fortune-handler
    This is a linux ASP on the S1 SKU, hosted in the EastUS reagion

-------------Application Infrastructure-------------
An azure function app: func-fortune-handler
    This app uses the above storage account (required for all azure functions)
    The app has a healthcheck URL of /api/healthcheck - Azure will ping this URL every 5 minutes and report metrics
A function within the function app : fortune
    This has a HTTP trigger that will respond to GET/POST on the url API/Fortune
A function within the function app : healthcheck
    This has a HTTP trigger that will respond to GET/POST on the url API/HealthCheck
    This trigger will always return a 200, if available, and is intended for the above mentioned health check ping from azure
A satic web page : web-fortune-handler
    This is hosted in an azure web app, with a PHP application stack (recommended by azure for static HTML)
    The website is logging all errors to blob storage
    This website has a Health Check trigger that will check the index.html page every 5 minutes

-------------Scaling Infrastructure-------------
The app service plan asp-fortune-handler scales based on two metrics :
    CPU > 80% - The ASP will scale instances up to 4
    HTTPQueueLength > 70 - The ASP will scale instances up to 4

    The ASP will then scale back down should the above metrics fall below the percentages

-------------Monitoring Infrastructure-------------
A notification channel is created : CriticalAlertsAction
    This will notify the email stated in variables.tf
A CPU metric alert : cpu-metric-alert
    This will fire if the CPU of the ASP is > 80%
A HealthCheck alert : func-healthcheck-metric-alert
    This will fire if the /api/healthcheck URL does not return a 200 OK response
A Healthcheck alert : web-healthcheck-metric-alert
    This will fire if the website does not return a 200 OK response on the index.html page

-------------Setting up the Application-------------
The following steps are required to set up application in a new azure instance
1. Install terraform and all required CLI tools for terraform
2. Run the terraform with : terraform plan
                            terraform apply
3. Connect to azure in powershell. First install azure module : Install-Module -Name Az -Repository PSGallery -Force
4. There are two powershell scripts within the /deploy folder 
    FunctionAppDeploy.ps1 - This will zip up the function app code and upload to azure
    WebAppDeploy.ps1 - This will zip up the website and deploy to azure
