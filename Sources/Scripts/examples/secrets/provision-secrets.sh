
echo "############################################################################"
echo "# ENSURE THIS SCRIPT IS EXECUTED FROM THE ROOT DIRECTORY OF THE REPOSITORY #"
echo "############################################################################"  

#!/bin/bash
set -e

CDHelper aes encrypt --config="$PWD/Sources/Scripts/examples/secrets/example-secrets.config.json" --key="$PWD/Sources/Scripts/examples/secrets/example-demo-app-secret-key.aess" --override=true