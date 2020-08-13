# disag-json-live

## udp-collector-service

This service is intended to listen on a configurable UDP-port. When it receives Disag-JSON-Live data, the data shall be inserted in some simple database for further usage.

## udp-testdata-generator

This application is intended to broadcast Disag-JSON-Live data via UDP. It may be used to feed data to a running instance of `udp-collector-service`.