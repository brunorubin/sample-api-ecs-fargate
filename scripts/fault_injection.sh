#!/bin/bash

# Step 1: Provide ECS Cluster and Service Names
read -p "Enter ECS cluster name: " ecs_cluster
read -p "Enter ECS service name: " ecs_service

# Step 2: Identify ECS Tasks
tasks=$(aws ecs list-tasks --cluster $ecs_cluster --service-name $ecs_service --query 'taskArns' --output text)

# Step 3: Simulate Failure
# For example, stop one of the ECS tasks
if [ -n "$tasks" ]; then
    task_to_stop=$(echo $tasks | awk '{print $1}')  # Choose the first task
    echo "Stopping ECS task: $task_to_stop"
    aws ecs stop-task --cluster $ecs_cluster --task $task_to_stop
fi

# Step 4: Observe Recovery
# Monitor the ECS service to observe how it recovers automatically