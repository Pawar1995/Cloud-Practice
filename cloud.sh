#!/bin/bash

# Exit on error
set -e

# === 1. Install AWS CLI (v2) ===
echo "Installing AWS CLI..."

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install

# Confirm installation
if ! command -v aws &> /dev/null; then
    echo "AWS CLI installation failed."
    exit 1
fi

echo "AWS CLI installed successfully."

# === 2. Set AWS credentials and config (optional if already configured) ===
# You can uncomment and edit below if you're automating:
# aws configure set aws_access_key_id YOUR_ACCESS_KEY
# aws configure set aws_secret_access_key YOUR_SECRET_KEY
# aws configure set default.region us-east-1
# aws configure set output json

# === 3. Launch EC2 Instance ===
AMI_ID="ami-0abcdef1234567890"    # Replace with a valid AMI ID
INSTANCE_TYPE="t2.micro"
KEY_NAME="my-key-pair"            # Replace with your actual key pair name
SECURITY_GROUP="default"
REGION="us-east-1"
TAG_NAME="MyEC2Instance"

echo "Launching EC2 instance..."

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --count 1 \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-groups "$SECURITY_GROUP" \
  --region "$REGION" \
  --query "Instances[0].InstanceId" \
  --output text)

if [ -z "$INSTANCE_ID" ]; then
  echo "Failed to launch EC2 instance."
  exit 1
fi

echo "Launched EC2 Instance with ID: $INSTANCE_ID"

# === 4. Tag the instance ===
aws ec2 create-tags \
  --resources "$INSTANCE_ID" \
  --tags Key=Name,Value="$TAG_NAME" \
  --region "$REGION"

echo "Tagged EC2 Instance with Name: $TAG_NAME"
