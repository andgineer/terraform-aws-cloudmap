[
         {
            "name": "${NAME}",
            "image": "${IMAGE}",
            "cpu": 0,
            "portMappings": [
                {
                    "name": "web-80-tcp",
                    "containerPort": 80,
                    "hostPort": 80,
                    "protocol": "tcp",
                    "appProtocol": "http"
                },
                {
                    "name": "web-8000-tcp",
                    "containerPort": 8000,
                    "hostPort": 8000,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": false,
            "environment": [
            ],
            "environmentFiles": [],
            "mountPoints": [],
            "volumesFrom": [],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "${LOG_GROUP_NAME}",
                    "awslogs-create-group": "true",
                    "awslogs-region": "${AWS_REGION}",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }

]
