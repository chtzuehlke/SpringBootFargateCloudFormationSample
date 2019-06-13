#!/bin/bash

./mvnw -q -Dexec.executable=echo -Dexec.args='${project.version}' --non-recursive exec:exec

