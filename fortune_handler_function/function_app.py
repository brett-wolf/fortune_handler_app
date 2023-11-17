import azure.functions as func
import logging
import requests
import json
import os

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="fortune")
def Fortune(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    try:
        fortuneResponse = requests.get("http://yerkee.com/api/fortune/computers").json()
    except requests.RequestException as e:
        logging.error(str(e.strerror))

        return func.HttpResponse(
            status_code=503,
            body= json.dumps({"error": "3rd party fortune API is down. Check server logs for more information.",}),
            headers={
                'Content-Type': 'application/json',
            }
        )
        
    logging.info(fortuneResponse["fortune"])

        # If no prefix is provided, the app will not supply a default.
    prefix = ''

    # If the MSG_PREFIX is set as an environment variable, set the prefix to it.
    if("MSG_PREFIX" in os.environ):
        prefix = os.environ["MSG_PREFIX"].strip() + " "

    fullFortune = prefix + fortuneResponse["fortune"]

    logging.info("Sending back the fortune \"%s\"" % fullFortune)

    return func.HttpResponse(
        body= json.dumps({"fortune": fullFortune}),
        status_code=200,
        headers={'Content-Type': 'application/json', }
    )

@app.function_name(name="HealthCheck")
@app.route(route="healthcheck", auth_level=func.AuthLevel.ANONYMOUS)
def health(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse("", status_code=200)
    