# Setup cluster in EKS

## Setup
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

9. Deploy Helm (only used for Rabbit atm)  
```./7_deploy_helm.sh```

## To test autoscaling
1. Go through setup (above)


2. Deploy the test service
 ```./4_deploy_test_service.sh```
   

3. Deploy an autoscaler, one of:  
   ```./5a_deploy_v1_autoscale```  
   ```./5b_deploy_beta_autoscale.sh```
   

4. Make the service busy, check scale up:  
   ```./6a_start_busy.sh```


4. Make the service busy, check scale down:  
   ```./6b_stop_busy.sh```

## To test keda
1. Go through setup (above)
   

2. Deploy Keda  
```./8_deploy_keda.sh```

   
3. Either test with scheduled schema (cron)   
```./9a_deploy_keda_scheduled.sh```  
Or with Rabbit:  
```./9b_deploy_keda_rabbit.sh```   
```./9c_keda_rabbit_cleanup.sh```

### Some useful commands:
```
# View autoscaler:
kubectl describe hpa.v2beta2.autoscaling test-autoscale -n test-namespace

# Autoscaler v1 via command line
kubectl autoscale deployment test-deployment --cpu-percent=50 --min=1 --max=10  -n test-namespace

# Clean up
kubectl delete namespace test-namespace

# Set cluster to explicit size
REPLICAS=10 
kubectl get hpa.v2beta2.autoscaling test-autoscale -n test-namespace -o yaml > test.yaml
kubectl delete hpa test-autoscale -n test-namespace
kubectl scale deployment test-deployment --replicas $REPLICAS -n test-namespace
kubectl apply -f test.yaml


```
