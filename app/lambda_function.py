import json
import os
from datetime import datetime
from decimal import Decimal

import boto3
import pytz
from aws_lambda_powertools import Logger, Tracer

# Configurando Logger e Tracer
logger = Logger()
tracer = Tracer()

# Configurando DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = os.getenv('DYNAMODB_TABLE_NAME')
table = dynamodb.Table(table_name)

# Definindo timezone
saopaulo_tz = pytz.timezone('America/Sao_Paulo')

@logger.inject_lambda_context
@tracer.capture_lambda_handler
def lambda_handler(event, context):
    for record in event['Records']:
        # Mensagem da fila SQS
        message = json.loads(record['body'])
        
        # Processar a mensagem
        try:
            user_data = json.loads(message['Message'], parse_float=Decimal)
            
            # Adicionar timestamp em horário local
            user_data['timestamp'] = datetime.now(saopaulo_tz).isoformat()

            # Inserir no DynamoDB
            response = table.put_item(Item=user_data)
            logger.info(f"Item inserido com sucesso: {response}")
        
        except Exception as e:
            logger.error(f"Erro ao processar a mensagem: {e}")
            raise e
            
    return {
        'statusCode': 200,
        'body': json.dumps('Mensagens processadas com sucesso!')
    }
