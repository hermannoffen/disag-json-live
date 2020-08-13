# disag-json-live

## udp-collector-service

This service is intended to listen on a configurable UDP-port. When it receives Disag-JSON-Live data, the data shall be inserted in some simple database for further usage.

## udp-testdata-generator

This application is intended to broadcast Disag-JSON-Live data via UDP. It may be used to feed data to a running instance of `udp-collector-service`.

### Usage

This application provides a simple UI consisting of
* a **listbox** containing several sample Disag-JSON-Live testdata,
* an **edit** for port selection and
* a **button** to UDP-broadcast the selected testdata to that port.

Alternatively, one can broadcast a testdata item per double click on it.