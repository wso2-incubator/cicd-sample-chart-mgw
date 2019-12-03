#!/usr/bin/env bash

set -e

TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik5UQXhabU14TkRNeVpEZzNNVFUxWkdNME16RXpPREpoWldJNE5ETmxaRFUxT0dGa05qRmlNUSJ9.eyJhdWQiOiJodHRwOlwvXC9vcmcud3NvMi5hcGltZ3RcL2dhdGV3YXkiLCJzdWIiOiJhZG1pbiIsImFwcGxpY2F0aW9uIjp7ImlkIjoyLCJuYW1lIjoiSldUX0FQUCIsInRpZXIiOiJVbmxpbWl0ZWQiLCJvd25lciI6ImFkbWluIn0sInNjb3BlIjoiYW1fYXBwbGljYXRpb25fc2NvcGUgZGVmYXVsdCIsImlzcyI6Imh0dHBzOlwvXC9sb2NhbGhvc3Q6OTQ0M1wvb2F1dGgyXC90b2tlbiIsImtleXR5cGUiOiJQUk9EVUNUSU9OIiwic3Vic2NyaWJlZEFQSXMiOltdLCJjb25zdW1lcktleSI6Ilg5TGJ1bm9oODNLcDhLUFAxbFNfcXF5QnRjY2EiLCJleHAiOjM3MDMzOTIzNTMsImlhdCI6MTU1NTkwODcwNjk2MSwianRpIjoiMjI0MTMxYzQtM2Q2MS00MjZkLTgyNzktOWYyYzg5MWI4MmEzIn0=.b_0E0ohoWpmX5C-M1fSYTkT9X4FN--_n7-bEdhC3YoEEk6v8So6gVsTe3gxC0VjdkwVyNPSFX6FFvJavsUvzTkq528mserS3ch-TFLYiquuzeaKAPrnsFMh0Hop6CFMOOiYGInWKSKPgI-VOBtKb1pJLEa3HvIxT-69X9CyAkwajJVssmo0rvn95IJLoiNiqzH8r7PRRgV_iu305WAT3cymtejVWH9dhaXqENwu879EVNFF9udMRlG4l57qa2AaeyrEguAyVtibAsO0Hd-DFy5MW14S6XSkZsis8aHHYBlcBhpy2RqcP51xRog12zOb-WcROy6uvhuCsv-hje_41WQ==
isAlive=0

health_check() {
    # Check if health check endpoint is alive
    if curl -X GET -H "accept: application/json" -H "Authorization:Bearer $TOKEN" --output /dev/null --silent --fail -k "$1"
    then
        status_code=$(curl -X GET -H "accept: application/json" -H "Authorization:Bearer $TOKEN" --write-out %{http_code} --silent --output /dev/null -k ${1})

        # Check if requests to the health check endpoint produces the expected response
        if [[ "$status_code" -ne 200 ]] ; then
            >&2 echo "Endpoint $1 produces an invalid response: $status_code"
            exit 1
        else
            echo "Endpoint $1 is alive!"
            isAlive=1
        fi
    else
        >&2 echo "Endpoint $1 is not alive. Retrying in 10s..."
        isAlive=0
    fi
}

declare -a healthcheckEndpoints=(
#   "https://wso2micro-gw-service.wso2mgw-staging.svc.cluster.local:9095/petstore/v1/pet/findByStatus?status=available"
#   "Endpoint 2"
#   "Endpoint 3"
)

for endpoint in "${healthcheckEndpoints[@]}"
do
    COUNTER=0
    while [ ${isAlive} -eq 0 ]&&[ ${COUNTER} -lt 18 ]; do
        sleep 10s
        health_check ${endpoint}
        let COUNTER=COUNTER+1
    done

    if [ ${isAlive} -eq 0 ]; then
        >&2 echo "Could not connect to $endpoint. Exiting..."
        exit 1
    fi
done

exit 0
