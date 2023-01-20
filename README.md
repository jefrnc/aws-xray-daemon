# aws-xray-daemon

Este proyecto es un demonio de X-Ray en ECS es poder visualizar las trazas de tu aplicación backend en el servicio X-Ray de la consola de AWS. El demonio de X-Ray actúa como intermediario entre tu aplicación backend y la API de X-Ray, permitiendo que las trazas sean enviadas y visualizadas de forma adecuada.



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


## Habilitar VPC

Para configurar una configuración de seguridad adecuada en tu VPC para permitir la comunicación entre el demonio de X-Ray y la consola de AWS X-Ray, debes seguir estos pasos:

1. Accede a la consola de AWS VPC en tu cuenta de AWS.
2. Selecciona tu VPC y haz clic en el botón "Security Groups" en el menú de navegación.
3. Crea un nuevo Security Group o selecciona uno existente para asociarlo con tu tarea de ECS que ejecuta el demonio de X-Ray.
4. Haz clic en el botón "Inbound Rules" y agrega una nueva regla para permitir el tráfico entrante desde el demonio de X-Ray al puerto UDP 2000.
5. Haz clic en "Save" para guardar los cambios.

Ten en cuenta que en caso de necesitar acceso a través de un firewall, debes abrir los puertos necesarios para que el demonio de X-Ray pueda comunicarse con los servicios de AWS X-Ray.

También es importante que la tarea del demonio de X-Ray y los contenedores de tu aplicación estén en el mismo grupo de seguridad, de esta forma se podrán comunicar entre si.
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


## Configuración del Servicio

Para enviar las trazas de un servicio de ECS al demonio de X-Ray, debes modificar la configuración de tu Task Definition para incluir la información del demonio de X-Ray.

Aquí te dejo un ejemplo de una Task Definition en formato JSON con los cambios necesarios para enviar las trazas al demonio de X-Ray:

```json
{
    "containerDefinitions": [
        {
            "name": "example-service",
            "image": "example-service-image",
            "environment": [
                {
                    "name": "AWS_XRAY_DAEMON_ADDRESS",
                    "value": "udp:<IP_ADDRESS>:2000"
                }
            ],
            "portMappings": [
                {
                    "containerPort": 80
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "example-service-logs",
                    "awslogs-region": "us-east-1"
                }
            }
        }
    ],
    "family": "example-service-task"
}
```

En este ejemplo se ha agregado una nueva entrada en el arreglo "environment" con el nombre "AWS_XRAY_DAEMON_ADDRESS" y el valor "udp:<IP_ADDRESS>:2000". Esto indica al SDK de AWS X-Ray en tu contenedor que envíe las trazas al demonio de X-Ray en lugar del endpoint predeterminado de AWS X-Ray.

Ten en cuenta que debes reemplazar <IP_ADDRESS> con la dirección IP del demonio de X-Ray en tu clúster.

Además, debes asegurarte de que tu servicio de ECS y el demonio de X-Ray estén en el mismo grupo de seguridad y que los puertos necesarios estén abiertos para permitir la comunicación entre el servicio y el demonio.

También es importante asegurarte de que tu demonio de X-Ray esté configurado correctamente y esté recibiendo trazas correctamente, de esta forma podrás visualizar las trazas en la consola de AWS X-Ray.