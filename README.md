# Setup cluster in EKS

1. Create an AWS sandbox in a cloud guru  
  https://learn.acloud.guru/cloud-playground/cloud-sandboxes

2. Build and containerize the service if it's changed  
```./build_service.sh```

3. Change into iac dir  
```cd iac```

4. Clean up from the previous run (only when using a new sandbox for the first time)  
```./0_clean_up.sh```

5. Run terraform to deploy the cluster etc.  
```./1_deploy_cluster.sh```  
*If this is the first time in a new cluster, enter Access Key, Secret Access key from your a cloud guru sandbox  
If the very first time, enter 'us-east-1' for region  
(If the values have not changed since the previous run, just hit enter)*  

6. Deploy the dashboard  
```./2_deploy_dashboard.sh```  
*Hit http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login to load it  
Paste in the token from token.txt*

7. Switch to another terminal  
*We leave kubectl proxy running in the previous script; it's required for the dashboard.*

8. Deploy the autoscaler  
```./3_deploy_autoscaler.sh```

9. Deploy the service  
```./4_deploy_test_service.sh```

### Some useful commands:
```
kubectl get all -A
kubectl get all -n test-namespace
kubectl scale deployment test-deployment --replicas 1 -n test-namespace
kubectl logs <pod-name> -n test-namespace'''
kubectl autoscale deployment test-deployment --cpu-percent=50 --min=1 --max=10  -n test-namespace
kubectl describe hpa -n test-namespace
kubectl describe deploy -n test-namespace
kubectl api-versions
kubectl get hpa test-autoscale -o yaml
kubectl describe hpa.v2beta2.autoscaling test-autoscale
```
