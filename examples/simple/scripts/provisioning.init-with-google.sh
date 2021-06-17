#!/usr/bin/zsh

readonly BUCKET_NAME_FOR_PROVISIONING="${PROJECT_UNIQUE_ID}-${CURRENT_ENV_NAME}-provisioning"

# Auth gcloud
gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}
gcloud auth configure-docker gcr.io --quiet
# Eenable Cloud Resource Manager API because that time out in terraform.
# https://cloud.google.com/resource-manager/reference/rest
gcloud services enable cloudresourcemanager.googleapis.com

# Create the GCS bucket to save tfstate

gsutil ls gs://${BUCKET_NAME_FOR_PROVISIONING}/ > /dev/null 2>&1 || {
  gsutil mb -b on gs://${BUCKET_NAME_FOR_PROVISIONING}/
}
# for exist buckets
gsutil uniformbucketlevelaccess set on gs://${BUCKET_NAME_FOR_PROVISIONING}/
gsutil versioning set on gs://${BUCKET_NAME_FOR_PROVISIONING}/

# Detect terraform version
rm -f .terraform-version
sudo tfenv install min-required
sudo tfenv use min-required
terraform version -json | jq -r '.terraform_version' | tee -a /tmp/.terraform-version
mv /tmp/.terraform-version .
# Init terraform
sudo chmod a+rwx ${TF_DATA_DIR}
terraform init -backend-config="bucket=${BUCKET_NAME_FOR_PROVISIONING}"
