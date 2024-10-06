import csv
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
    s3 = boto3.client('s3')
    
    for record in event['Records']:
        # Mensagem da fila SQS
        message = json.loads(record['body'])
        
        # Processar a mensagem
        try:
            # Recupera informações do S3
            s3_bucket = message['Records'][0]['s3']['bucket']['name']
            s3_key = message['Records'][0]['s3']['object']['key']
            
            # Faz download do arquivo CSV
            csv_file = s3.get_object(Bucket=s3_bucket, Key=s3_key)
            csv_content = csv_file['Body'].read().decode('utf-8').splitlines()
            
            # Leitura do CSV
            csv_reader = csv.DictReader(csv_content)

            # Processamento do CSV
            for row in csv_reader:
                row['timestamp'] = datetime.now(saopaulo_tz).isoformat()
                # Converte valores numéricos para Decimal
                item = {k: Decimal(v) if k in ['amount', 'price'] else v for k, v in row.items()}

                # Inserir no DynamoDB
                response = table.put_item(Item=item)
                logger.info(f"Item inserido com sucesso: {response}")
        
        except Exception as e:
            logger.error(f"Erro ao processar a mensagem: {e}")
            raise e
            
    return {
        'statusCode': 200,
        'body': json.dumps('Mensagens processadas com sucesso!')
    }
