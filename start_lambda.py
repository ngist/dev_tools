# This is a helper lambda to allow a tagged instance to be restarted by tag name and api call.
# I use this in conjunction with my cloud dev machine that is set to auto shutdown. Then I use
# a widget on my smart phone to send the API request to start it up again.

import json
import boto3

# Initialize the EC2 client
ec2 = boto3.client('ec2', region_name='us-east-1') 
ssm = boto3.client('ssm', region_name='us-east-1')

def lambda_handler(event, context):
    try:
        if 'tag' in event:
            tag = event.get('tag')
            api_key = event.get('api_key')
        elif 'body' in event and event['body']:
            body = json.loads(event['body'])
            tag = body.get('tag')
            api_key = body.get('api_key')

        true_api_key = ssm.get_parameter(
            Name='InstanceStartApiKey',
            WithDecryption=True
        )["Parameter"]["Value"]
        if not api_key or api_key != true_api_key:
            return {
                'statusCode': 501,
                'body': json.dumps({'error': 'Permission Denied'})
            }

        if not tag:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Missing tag parameter'})
            }
        
        filter_on_tag = [{
            'Name':'tag:Type', 
            'Values': [tag],
        }]
            
        reservations = ec2.describe_instances(Filters=filter_on_tag)["Reservations"]
        if len(reservations) < 1:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'No reservations found with the same tag.'})
            }
        if len(reservations) > 1:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Multiple reservations found with the same tag. Please ensure unique tagging.'})
            }

        
        instances = reservations[0]["Instances"]
        if len(instances) > 1:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Multiple instances found with the same tag. Please ensure unique tagging.'})
            }
        instance_id = instances[0]["InstanceId"]
        print(instance_id)
        # Call the AWS EC2 API to start the instance
        response = ec2.start_instances(InstanceIds=[instance_id])
        
        # Extract current state information
        starting_instances = response['StartingInstances'][0]
        current_state = starting_instances['CurrentState']['Name']
        previous_state = starting_instances['PreviousState']['Name']
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Successfully requested start for {instance_id}',
                'previous_state': previous_state,
                'current_state': current_state
            })
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
