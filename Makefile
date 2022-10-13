PROJECT_ID:=rd-project-billing-portal
BUCKET_NAME:=bg-test-andy
REGION:=US-EAST1
ACCOUNT:=xxxxxx

env:
	export BUCKET_NAME=bg-test-andy && envsubst < import.yaml > test.yaml

checkaccount:
	gcloud auth list && gcloud config set ${ACCOUNT} && gcloud config set ${PROJECT_ID}

createiam:
	gcloud iam service-accounts create import-workflow

createrole:
	gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:import-workflow@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/cloudsql.admin" --condition=None && \
    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:import-workflow@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/storage.admin" --condition=None && \
    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:import-workflow@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/bigquery.dataViewer" --condition=None  && \
    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:import-workflow@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/bigquery.jobUser" --condition=None

createbucket:
	gsutil mb -l ${REGION} -b on gs://${BUCKET_NAME} && gsutil iam ch allUsers:objectViewer gs://${BUCKET_NAME}

deploy:
	gcloud workflows deploy import --source=import.yaml --service-account=import-workflow@${PROJECT_ID}.iam.gserviceaccount.com

run:
	gcloud workflows execute import
