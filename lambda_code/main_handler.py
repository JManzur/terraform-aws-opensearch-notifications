import boto3
import urllib3, json, os, logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Event: {}".format(event))

    try:
        NotificationType = event["Records"][0]["Sns"]["Type"]
        Subject = event["Records"][0]["Sns"]["Subject"]
        Message = event["Records"][0]["Sns"]["Message"]
        Timestamp = event["Records"][0]["Sns"]["Timestamp"]
        AWSAccountId = event["Records"][0]["Sns"]["TopicArn"].split(":")[4]
        AWSRegion = event["Records"][0]["Sns"]["TopicArn"].split(":")[3]

        message = {
            "type": "message",
            "attachments": [
                {
                    "contentType": "application/vnd.microsoft.card.adaptive",
                    "contentUrl": None,
                    "content": {
                        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                        "type": "AdaptiveCard",
                        "version": "1.3",
                        "body": [
                            {
                                "type": "Container",
                                "padding": None,
                                "items": [
                                    {
                                        "type": "TextBlock",
                                        "wrap": True,
                                        "size": "Large",
                                        "color": "{}".format(get_color(NotificationType)),
                                        "text": "{0} OpenSearch {1}: {2}".format(get_emoji(NotificationType), NotificationType, Subject)
                                    }
                                ]
                            },
                            {
                                "type": "Container",
                                "items": [
                                    {
                                        "type": "TextBlock",
                                        "text": "{}".format(Message),
                                        "wrap": True
                                    }
                                ],
                                "isVisible": False,
                                "id": "alarm-details"
                            },
                            {
                                "type": "Container",
                                "padding": "None",
                                "items": [
                                    {
                                        "type": "ColumnSet",
                                        "columns": [
                                            {
                                                "type": "Column",
                                                "width": "stretch",
                                                "items": [
                                                    {
                                                        "type": "TextBlock",
                                                        "text": "Account",
                                                        "wrap": True,
                                                        "isSubtle": True,
                                                        "weight": "Bolder"
                                                    },
                                                    {
                                                        "type": "TextBlock",
                                                        "wrap": True,
                                                        "spacing": "Small",
                                                        "text": "{}".format(AWSAccountId)
                                                    }
                                                ]
                                            },
                                            {
                                                "type": "Column",
                                                "width": "stretch",
                                                "items": [
                                                {
                                                    "type": "TextBlock",
                                                    "text": "Region",
                                                    "wrap": True,
                                                    "isSubtle": True,
                                                    "weight": "Bolder"
                                                },
                                                {
                                                    "type": "TextBlock",
                                                    "text": "{}".format(AWSRegion),
                                                    "wrap": True,
                                                    "spacing": "Small"
                                                }
                                                ]
                                            },
                                            {
                                                "type": "Column",
                                                "width": "stretch",
                                                "items": [
                                                {
                                                    "type": "TextBlock",
                                                    "text": "UTC Time",
                                                    "wrap": True,
                                                    "weight": "Bolder",
                                                    "isSubtle": True
                                                },
                                                {
                                                    "type": "TextBlock",
                                                    "text": "{}".format(get_date(Timestamp)),
                                                    "wrap": True,
                                                    "spacing": "Small"
                                                }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ],
                        "padding": "None",
                        "actions": [
                            {
                                "type": "Action.ToggleVisibility",
                                "title": "Show Message",
                                "targetElements": [
                                "alarm-details"
                                ]
                            }
                        ]
                    }
                }
            ]
        }
        
        post_message(message)

    except Exception as error:
        #Log the Error:
        logger.error(error)

        #Lambda error response:
        return {
            'statusCode': 400,
            'message': 'An error has occurred',
            'moreInfo': {
                'Lambda Request ID': '{}'.format(context.aws_request_id),
                'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                'CloudWatch log group name': '{}'.format(context.log_group_name)
                }
            }

def get_color(NotificationType):
    logger.info("Executing function: " + get_color.__name__)

    if NotificationType == "Notification":
        return "Accent" # blue
    else:
        return "Warning" # yellow

def get_emoji(NotificationType):
    logger.info("Executing function: " + get_emoji.__name__)

    information = "\U00002139"
    warning = "\U000026A0"

    if NotificationType == "Notification":
        return information
    else:
        return warning
    
def get_date(Timestamp):
    logger.info("Executing function: " + get_date.__name__)

    time_aws = Timestamp.split(".")[0]
    utc_time = datetime.strptime(time_aws, "%Y-%m-%dT%H:%M:%S")
    formated_date = utc_time.strftime("%m/%d/%Y %H:%M:%S")

    return formated_date

def post_message(message):
    logger.info("Executing function: " + post_message.__name__)
    
    http = urllib3.PoolManager()
    url = get_parameter()
    encoded_msg = json.dumps(message).encode("utf-8")
    response = http.request("POST", url, body=encoded_msg)
    
    return {
        "Message": message,
		"StatusCode": response.status,
		"Response": response.data
		}

def get_parameter():
    logger.info("Executing function: " + get_parameter.__name__)

    client = boto3.client('ssm')
    response = client.get_parameter(
        Name='{}'.format(os.environ.get("ms_teams_webhook_url")),
        WithDecryption=True
        )

    return response['Parameter']['Value']