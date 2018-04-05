# klms-docker
Dockerfile for Kaspersky Security 8.0 for Linux Mail Server

KSN off

Valid key required in etc/kas.key

Fix etc/klms_filters.conf to set proper socket-out
Adjust etc/8.0.2-16-as.xml as required

use *alias klms-control='docker exec -it klms /opt/kaspersky/klms/bin/klms-control'* for quick access to klms-control in container

Bugs:
 postgres hard killed on container stop and slow started on next start



