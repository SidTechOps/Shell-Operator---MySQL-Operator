# Shell-Operator - MySQL-Operator
Shell Operator using simple kubectl commands

The Shell Operator Framework introduces a novel approach to writing operators for Kubernetes, lowering the entry barrier by eliminating the necessity of proficiency in the Go programming language or Any Operator SDK, which is traditionally used for this purpose. This framework leverages shell scripting to encapsulate operational logic, enabling developers to construct operators using a more accessible and straightforward scripting approach.

As a Proof of Concept (PoC) demonstrating the viability and ease of this framework, we've created a MySQL Operator. This operator performs basic CRUD (Create, Read, Update, Delete) operations to manage MySQL instances within a Kubernetes cluster. By adhering to a native Kubernetes workflow, it monitors custom resource definitions (CRDs) and reacts to the cluster's state changes to ensure the desired state of MySQL instances is achieved and maintained.

Key Benefits:

Ease of Adoption: With no requirement for Go language knowledge, more developers can contribute to the operator ecosystem.
Simplified Operational Logic: Shell scripting provides a simplified way to encapsulate operational logic, making it easier to construct, understand, and modify operators.
Native Kubernetes Workflow: The framework aligns with native Kubernetes constructs, ensuring seamless integration and efficient orchestration.
Demonstrative PoC: The MySQL Operator serves as a practical example, showcasing the simplicity and effectiveness of the ShellCraft Operator Framework in real-world scenarios.
Expandable: This framework lays the foundation for the development of more complex operators, potentially expanding the ecosystem with a variety of shell-script-based operators.

## Building the Operator

1. Build the Docker image for the operator:

```
docker build -t yourusername/mysql-operator:latest .
```

2.Load the Docker image into your Kubernetes cluster (assuming you're using KinD):
```
kind load docker-image yourusername/mysql-operator:latest
```

## Deploying the Operator

1. Create the MySqlDatabase custom resource definition:
```
kubectl apply -f /src/crd/mysqldatabase-crd.yaml
```

2. Deploy the operator:
```
kubectl apply -f /src/operator/mysql-operator.yaml
```

output:
```
siddarth@ubuntu22-NAB6:~/Shell-Operator-Project/MySql-Operator$ kp
NAMESPACE            NAME                                             READY   STATUS    RESTARTS   AGE
default              mysql-operator-656c9d96f8-kd8lb                  1/1     Running   0           5s
kube-system          coredns-787d4945fb-bxxrp                         1/1     Running   0          6h39m
kube-system          coredns-787d4945fb-d6kjs                         1/1     Running   0          6h39m
kube-system          etcd-operator-control-plane                      1/1     Running   0          6h39m
kube-system          kindnet-g96fc                                    1/1     Running   0          6h39m
kube-system          kube-apiserver-operator-control-plane            1/1     Running   0          6h39m
kube-system          kube-controller-manager-operator-control-plane   1/1     Running   0          6h39m
kube-system          kube-proxy-2d7vj                                 1/1     Running   0          6h39m
kube-system          kube-scheduler-operator-control-plane            1/1     Running   0          6h39m
local-path-storage   local-path-provisioner-75f5b54ffd-hwrxk          1/1     Running   0          6h39m
----------------
siddarth@ubuntu22-NAB6:~/Shell-Operator-Project/MySql-Operator$ kcrds
NAME                         CREATED AT
mysqldatabases.example.com   2023-11-05T15:47:16Z
```
## Usage

1. To create a MySQL database, apply a mysql-request.yaml manifest:
```
kubectl apply -f /tests/mysql-request.yaml
```
output:
```
siddarth@ubuntu22-NAB6:~/Shell-Operator-Project/MySql-Operator$ k get mysqldatabase
NAME          AGE
my-database   29s

siddarth@ubuntu22-NAB6:~/Shell-Operator-Project/MySql-Operator$ kp -w
NAMESPACE            NAME                                             READY   STATUS    RESTARTS   AGE
default              mysql-operator-656c9d96f8-kd8lb                  1/1     Running   0          40m
kube-system          coredns-787d4945fb-bxxrp                         1/1     Running   0          6h39m
kube-system          coredns-787d4945fb-d6kjs                         1/1     Running   0          6h39m
kube-system          etcd-operator-control-plane                      1/1     Running   0          6h40m
kube-system          kindnet-g96fc                                    1/1     Running   0          6h39m
kube-system          kube-apiserver-operator-control-plane            1/1     Running   0          6h40m
kube-system          kube-controller-manager-operator-control-plane   1/1     Running   0          6h40m
kube-system          kube-proxy-2d7vj                                 1/1     Running   0          6h39m
kube-system          kube-scheduler-operator-control-plane            1/1     Running   0          6h40m
local-path-storage   local-path-provisioner-75f5b54ffd-hwrxk          1/1     Running   0          6h39m
default              mysql-my-database-ccd4bc56b-9fbw4                0/1     Pending   0          0s
default              mysql-my-database-ccd4bc56b-9fbw4                0/1     Pending   0          0s
default              mysql-my-database-ccd4bc56b-9fbw4                0/1     ContainerCreating   0          0s
default              mysql-my-database-ccd4bc56b-9fbw4                1/1     Running             0          1s
```
2. To delete a MySQL database, delete the corresponding MySqlDatabase custom resource:
```
kubectl delete -f /tests/mysql-request.yaml
#or 
kubectl delete mysqldatabase my-database
```
output:
```
NAMESPACE            NAME                                             READY   STATUS    RESTARTS   AGE
default              mysql-my-database-ccd4bc56b-9fbw4                1/1     Running   0          5m19s
default              mysql-operator-656c9d96f8-kd8lb                  1/1     Running   0          46m
kube-system          coredns-787d4945fb-bxxrp                         1/1     Running   0          6h45m
kube-system          coredns-787d4945fb-d6kjs                         1/1     Running   0          6h45m
kube-system          etcd-operator-control-plane                      1/1     Running   0          6h45m
kube-system          kindnet-g96fc                                    1/1     Running   0          6h45m
kube-system          kube-apiserver-operator-control-plane            1/1     Running   0          6h45m
kube-system          kube-controller-manager-operator-control-plane   1/1     Running   0          6h45m
kube-system          kube-proxy-2d7vj                                 1/1     Running   0          6h45m
kube-system          kube-scheduler-operator-control-plane            1/1     Running   0          6h45m
local-path-storage   local-path-provisioner-75f5b54ffd-hwrxk          1/1     Running   0          6h45m
default              mysql-my-database-ccd4bc56b-9fbw4                1/1     Terminating   0          5m34s
default              mysql-my-database-ccd4bc56b-9fbw4                0/1     Terminating   0          5m38s
default              mysql-my-database-ccd4bc56b-9fbw4                0/1     Terminating   0          5m38s
default              mysql-my-database-ccd4bc56b-9fbw4                0/1     Terminating   0          5m38s
```

## Logging

You can view the operator's logs to see the actions it's performing:

```
kubectl logs -l app=mysql-operator -f
```

```
siddarth@siddarth-NAB6:~/Shell-Operator-Project/MySql-Operator$ kubectl logs -l app=mysql-operator -f
{"date": "2023-11-05T19:54:54Z", "level": "info", "message": "Applied MySQL deployment YAML for my-database."}
deployment.apps/mysql-my-database unchanged
{"date": "2023-11-05T19:55:24Z", "level": "info", "message": "Applied MySQL deployment YAML for my-database."}
deployment.apps/mysql-my-database unchanged
{"date": "2023-11-05T19:55:54Z", "level": "info", "message": "Applied MySQL deployment YAML for my-database."}
deployment.apps/mysql-my-database unchanged
{"date": "2023-11-05T19:56:25Z", "level": "info", "message": "Applied MySQL deployment YAML for my-database."}
deployment.apps "mysql-my-database" deleted
{"date": "2023-11-05T19:56:55Z", "level": "info", "message": "Deleted deployment mysql-my-database as no corresponding MySqlDatabase resource was found."}
{"date": "2023-11-05T19:57:25Z", "level": "info", "message": "No deployments with label mysql found, skipping deletion loop."}
{"date": "2023-11-05T19:57:55Z", "level": "info", "message": "No deployments with label mysql found, skipping deletion loop."}
```

## Clean up
To remove the operator and the MySqlDatabase CRD:
```
kubectl delete -f /src/operator/mysql-operator.yaml
kubectl delete crd mysqldatabases.example.com
```


This `README.md` provides a general overview of your project, instructions for building and deploying the operator, usage examples, and cleanup instructions. Adjustments can be made to better fit the project as it evolves.


## Drawbacks and Possible Solutions

### Drawbacks
- **Performance**: Shell scripts may not perform as efficiently as programs written in compiled languages.
- **Error Handling**: Bash lacks advanced error handling mechanisms, which can lead to silent failures.
- **Maintenance**: Script-based operators require rigorous maintenance to stay up-to-date with Kubernetes API changes.
- **Scalability**: Shell scripts might not be the best fit for large-scale operations.

### Possible Solutions
- Optimize scripts for better performance and introduce external processing where appropriate.
- Implement detailed logging and utilize tools like `trap` to catch errors in bash.
- Establish a routine for updating and testing scripts against new Kubernetes releases.
- Leverage Kubernetes features to manage load and resource efficiency effectively.
- Engage with the community to improve documentation, gather feedback, and enhance security practices.


