# Create an AWS sandbox in a cloud guru:
https://learn.acloud.guru/cloud-playground/cloud-sandboxes

# Build and containerize the service if it's changed
gradle build
./build_docker.sh

cd iac

# If this is the first time in this sandbox, clean up
./0_clean_up.sh

# Run terraform to deploy the cluster etc.
#  If this is the first time in a new cluster, enter Access Key, Secret Access key from your a cloud guru sandbox
#  If the very first time, enter 'us-east-1' for region
#  (If the values have not changed since the previous run, just hit enter)
./1_deploy_cluster.sh

# Deploy the dashboard (follow instructions to use it)
./2_deploy_dashboard.sh

# Switch to another terminal (we leave kubectl proxy running in order to use the dashboard)

# Deploy the autoscaler
./3_deploy_autoscaler.sh

# Deploy the service
./4_deploy_test_service.sh

# Some useful commands:
# kubectl get all -A
# kubectl get all -n test-namespace
# kubectl scale deployment test-deployment --replicas 40 -n test-namespace
# kubectl logs <pod-name> -n test-namespace
# kubectl autoscale deployment test-deployment --cpu-percent=50 --min=1 --max=10  -n test-namespace
# kubectl describe hpa -n test-namespace