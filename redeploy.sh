#!/usr/bin/env bash
set -euo pipefail

export AWS_PROFILE=idp-workload
REGION=us-east-1
ECR_URL=119233636824.dkr.ecr.us-east-1.amazonaws.com/backstage
CLUSTER=backstage-demo
SERVICE=backstage-demo
TF_DIR="$HOME/projects/aws_idp_backstage/backstage/terraform"

echo "==> Building and pushing image"
docker image build . -f packages/backend/Dockerfile --tag backstage:local
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$ECR_URL"
docker tag backstage:local "$ECR_URL:latest"
docker push "$ECR_URL:latest"

echo "==> Forcing deployment to get a task + IP"
aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" \
  --force-new-deployment --region "$REGION" >/dev/null
aws ecs wait services-stable --cluster "$CLUSTER" --services "$SERVICE" --region "$REGION"

TASK_ARN=$(aws ecs list-tasks --cluster "$CLUSTER" --region "$REGION" --query 'taskArns[0]' --output text)
ENI_ID=$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASK_ARN" --region "$REGION" \
  --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)
PUBLIC_IP=$(aws ec2 describe-network-interfaces --network-interface-ids "$ENI_ID" --region "$REGION" \
  --query 'NetworkInterfaces[0].Association.PublicIp' --output text)
BASE_URL="http://$PUBLIC_IP:7007"

echo "==> Task IP is $PUBLIC_IP. Re-applying with APP_BASE_URL=$BASE_URL"
( cd "$TF_DIR" && terraform apply -auto-approve -var "app_base_url=$BASE_URL" >/dev/null )

echo "==> Forcing one more deployment so the new APP_BASE_URL takes effect"
aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" \
  --force-new-deployment --region "$REGION" >/dev/null
aws ecs wait services-stable --cluster "$CLUSTER" --services "$SERVICE" --region "$REGION"

# the IP can change on this second cycle, so re-fetch
TASK_ARN=$(aws ecs list-tasks --cluster "$CLUSTER" --region "$REGION" --query 'taskArns[0]' --output text)
ENI_ID=$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASK_ARN" --region "$REGION" \
  --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)
FINAL_IP=$(aws ec2 describe-network-interfaces --network-interface-ids "$ENI_ID" --region "$REGION" \
  --query 'NetworkInterfaces[0].Association.PublicIp' --output text)

echo ""
echo "============================================"
echo " Backstage:    http://$FINAL_IP:7007"
echo " OAuth callback to register in GitHub:"
echo "   http://$FINAL_IP:7007/api/auth/github/handler/frame"
echo "============================================"