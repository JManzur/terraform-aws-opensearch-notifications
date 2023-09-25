import boto3
import urllib3, json, os, logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Event: {}".format(event))
    logger.info("Context: {}".format(context))