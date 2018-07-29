# vault-init

Adapting Kelsey Hightower's vault on kubernetes to run in minikube for a PoC.

Also uses big chunks of the vault-init code in a sidecar container, but gets 
rid of the GCP dependencies and keeps everything in memory for demo purposes.

You'll need to follow the same cert creation steps in the parent repo to get
things working.

_Not_ prod worthy.
