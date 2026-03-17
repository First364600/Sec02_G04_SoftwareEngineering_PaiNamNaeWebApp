##### Prerequisites
* Docker Desktop
* Port 3001

##### Running
1. Run PaiNamNae Container

2. Go to http://localhost:3001

3. Running Load Test (k6 via Docker)
Windows (CMD)
```Bash
cd tests/Sprint3/loadTest
docker run --rm -i --name k6 -v %cd%:/scripts grafana/k6 run /scripts/dos.js