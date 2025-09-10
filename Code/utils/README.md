# Quick How-to
1. Make sure that you have set the proper git account in your git config. Test this by running
`git config user.email`
2. Parametrize and Run the following script. The following example concerns the muddy water service.
```bash
bash pull-tag-push.sh --from ghcr.io/cdxi-solutions/muddy-service:bin --to ghcr.io/hellenicspacecenter/water-monitoring-integration-tests/muddy-service:latest
```

3. Parametrize and Run the following script to update the CWL and YAML files. The default hardcoded values concern the muddy water service.
```bash
bash pull-push-runfiles.sh
```