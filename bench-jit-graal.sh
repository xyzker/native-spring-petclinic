#!/bin/bash
set -e

function print() {
    printf "\033[1;34m$1\033[0m\n"
}

print "Starting Spring Petclinic..."

java -Xmx512m -jar ./target/spring-petclinic-3.5.0-SNAPSHOT.jar &
export PID=$!
psrecord $PID --plot "$(date +%s)-jit-graal.png" --max-cpu 1600 --max-memory 800 --include-children &

sleep 10
print "Done waiting for Spring Petclinic to come up..."

print "Warming up Spring Petclinic..."
wrk -s mixed-requests.lua --duration 20s --connections 1 --threads 1 http://localhost:8080
print "Exercising Spring Petclinic..."
wrk -s mixed-requests.lua --duration 20s --connections 1 --threads 1 http://localhost:8080

print "Done!"
kill $PID
sleep 1
