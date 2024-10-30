
import boto3
import os
import logging
from flask import Flask, request, jsonify

# Initialize logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# AWS configuration
AWS_REGION = os.getenv('AWS_REGION', 'us-west-1')
S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')
SQS_QUEUE_URL = os.getenv('SQS_QUEUE_URL')

# AWS clients
s3_client = boto3.client('s3', region_name=AWS_REGION)
sqs_client = boto3.client('sqs', region_name=AWS_REGION)

# Initialize Flask application
app = Flask(__name__)

@app.route('/process', methods=['POST'])
def process_request():
    try:
        # Extract data from the request
        data = request.json
        logger.info(f"Received data: {data}")

        # Log the request data to S3
        s3_object_key = f"logs/{request.remote_addr}-{request.headers['X-Request-Id']}.json"
        s3_client.put_object(Bucket=S3_BUCKET_NAME, Key=s3_object_key, Body=str(data))
        logger.info(f"Logged data to S3: s3://{S3_BUCKET_NAME}/{s3_object_key}")

        # Optionally send a message to SQS
        if SQS_QUEUE_URL:
            sqs_client.send_message(QueueUrl=SQS_QUEUE_URL, MessageBody=str(data))
            logger.info(f"Sent message to SQS: {SQS_QUEUE_URL}")

        return jsonify({"status": "success"}), 200

    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
