[
    {
        "name": "${NAME}",
        "image": "${IMAGE}",
        "cpu": 0,
        "portMappings": [
            {
                "name": "${NAME}-tcp",
                "containerPort": ${CONTAINER_PORT},
                "hostPort": ${CONTAINER_PORT},
                "protocol": "tcp",
                "appProtocol": "http"
            }
        ],
        "essential": true,
        "environment": [
        ],
        "mountPoints": [],
        "volumesFrom": [],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-create-group": "true",
                "awslogs-group": "${LOG_GROUP_NAME}",
                "awslogs-region": "${AWS_REGION}",
                "awslogs-stream-prefix": "ecs"
            }
        }
    }
]
