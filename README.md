# aws-xray-daemon

El siguiente documento describe las tareas necesarias para llevar a cabo la implementación del demonio de Xray en ECS. 
El demonio de X-Ray es un intermediario entre aplicaciones backend y la api de X-Ray. Hace posible visualizar las trazas del backend en el servicio X-Ray en la consola de AWS. 

## Pre-requisitos
- Una instancia de ECS en funcionamiento
- Una configuración de seguridad adecuada en tu VPC para permitir la comunicación entre el demonio y la consola de AWS X-Ray.
- Un rol de ejecución en AWS IAM con permisos para utilizar X-Ray.

## Pasos para implementar el demonio de X-Ray en ECS

1. Crea una Task Definition en formato JSON utilizando la imagen de Docker jsfrnc/x-ray-ecs-daemon. Puedes utilizar el siguiente ejemplo como referencia:

```json
{
  "executionRoleArn": "arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>",
  "containerDefinitions": [
    {
      "name": "xray-daemon",
      "image": "jsfrnc/x-ray-ecs-daemon",
      "environment": [
        {
          "name": "AWS_REGION",
          "value": "<REGION>"
        },
      ],
      "cpu": 256,
      "memory": 512,
      "essential": true
    }
  ],
  "family": "xray-daemon"
}
```

2. Crea una tarea utilizando la Task Definition creada en el paso anterior.

3. Asocia la tarea del demonio de X-Ray con tu grupo de contenedores de ECS para que pueda interceptar las trazas de las aplicaciones backend.

4. Verifica la configuración del demonio en la consola de AWS X-Ray para asegurarte de que está recibiendo y transmitiendo datos correctamente.

5. Inicia la tarea del demonio en ECS y verifica que está funcionando correctamente.

Nota: También puedes utilizar herramientas como pulumi o CloudFormation para crear la Task Definition y la tarea. El siguiente es un ejemplo de una definición de tarea en pulumi:

```ts
const taskDefinition = new ecs.TaskDefinition("xray-daemon-task", {
    executionRoleArn: "arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>",
    containerDefinitions: [{
        name: "xray-daemon",
        image: "jsfrnc/x-ray-ecs-daemon",
        environment: [{
            name: "AWS_REGION",
            value: "<REGION>"
        }],
        cpu: 256,
        memory: 512,
        essential: true
    }]
});

```

```yml
Resources:
  XRayDaemonTaskDefinition:
    Type: "AWS::ECS::TaskDefinition"
    Properties:
      Family: "xray-daemon"
      ContainerDefinitions:
      - Name: "xray-daemon"
        Image: "jsfrnc/x-ray-ecs-daemon"
        Environment:
        - Name: "AWS_REGION"
          Value: "<REGION>"
        Memory: 512
        Cpu: 256
        Essential: true
      ExecutionRoleArn: "arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>"

```

## Permisos necesarios para el role

Busca y selecciona el policy "AWSXRayDaemonWriteAccess" en la lista de policies. Si no lo encuentras, puedes crear uno nuevo.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords"
            ],
            "Resource": "*"
        }
    ]
}
```
Esta policy le da al rol acceso a los siguientes permisos de AWS X-Ray:

- xray:PutTraceSegments permite al rol enviar segmentos de trazas a AWS X-Ray.
- xray:PutTelemetryRecords permite al rol enviar registros de telemetría a AWS X-Ray.

Puedes agregar esta policy a un rol existente o crear un nuevo rol y asignarle esta policy.
Ten en cuenta que puedes ajustar los permisos a tus necesidades específicas, por ejemplo si vas a utilizar solo un servicio específico, puedes limitar los permisos a solo ese servicio.
