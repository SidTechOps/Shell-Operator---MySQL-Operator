#!/bin/bash


log() {
    local level=$1
    local message=$2
    local date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"date\": \"$date\", \"level\": \"$level\", \"message\": \"$message\"}"
}


while true; do
    # Get all MySqlDatabase resources
    dbs=$(kubectl get mysqldatabase -o json)

    # Process each MySqlDatabase resource
    echo "$dbs" | jq -c '.items[]' | while read -r db; do
        # Extract values from the MySqlDatabase resource
        MYSQL_NAME=$(echo "$db" | jq -r '.metadata.name')
        MYSQL_VERSION=$(echo "$db" | jq -r '.spec.mysqlVersion')
        MYSQL_DATABASE=$(echo "$db" | jq -r '.spec.databaseName')
        MYSQL_USER=$(echo "$db" | jq -r '.spec.user')
        MYSQL_PASSWORD=$(echo "$db" | jq -r '.spec.password')

        # Substitute values into the template file using yq
        yq eval \
           ".metadata.name = \"mysql-$MYSQL_NAME\" |
            .metadata.labels.\"mysql-instance\" = \"$MYSQL_NAME\" |
            .spec.selector.matchLabels.mysql-instance = \"$MYSQL_NAME\" |
            .spec.template.metadata.labels.mysql-instance = \"$MYSQL_NAME\" |
            .spec.template.spec.containers[0].image = \"mysql:$MYSQL_VERSION\" |
            .spec.template.spec.containers[0].env[0].value = \"$MYSQL_PASSWORD\" |
            .spec.template.spec.containers[0].env[1].value = \"$MYSQL_DATABASE\" |
            .spec.template.spec.containers[0].env[2].value = \"$MYSQL_USER\"" \
           mysql-deployment-template.yaml > mysql-deployment.yaml

        # Apply the MySQL deployment YAML
        kubectl apply -f mysql-deployment.yaml
        log "info" "Applied MySQL deployment YAML for $MYSQL_NAME."
        # cat mysql-deployment.yaml
    done

        # Check for orphaned deployments and delete them

    deployments=$(kubectl get deployments -o json | jq -c '.items[] | select(.metadata.labels.app == "mysql")')
    deployment_count=$(kubectl get deployments -o json | jq '[.items[] | select(.metadata.labels.app == "mysql")] | length')

    if [ "$deployment_count" -eq 0 ]; then
       log "info" "No deployments with label mysql found, skipping deletion loop."
    else
      echo "$deployments" | while read -r deployment; do
        DEPLOYMENT_NAME=$(echo "$deployment" | jq -r '.metadata.name')
        MYSQL_NAME=${DEPLOYMENT_NAME#mysql-}
        if ! echo "$dbs" | jq -e --arg MYSQL_NAME "$MYSQL_NAME" '.items[] | select(.metadata.name == $MYSQL_NAME)' > /dev/null; then
            # No corresponding MySqlDatabase resource found, delete the deployment
            kubectl delete deployment "$DEPLOYMENT_NAME"
            log "info" "Deleted deployment $DEPLOYMENT_NAME as no corresponding MySqlDatabase resource was found."
        fi
      done
     fi
    # Sleep for a while before checking again
    sleep 30
done

