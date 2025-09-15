# Quick How-to
1. Make sure that you have set the proper git account in your git config. Test this by running
`git config user.email`

2. Parametrize the arguments and Run the following script.
```bash
bash pull-tag-push.sh --from ghcr.io/cdxi-solutions/muddy-service:bin --to ghcr.io/hellenicspacecenter/water-monitoring-integration-tests/muddy-service:latest
```
- The `--from ghcr.io/cdxi-solutions/muddy-service:bin` represents the docker image that is uploaded in your organization's ghcr.io where you're doing the actual development.  
- The `--to ghcr.io/hellenicspacecenter/water-monitoring-integration-tests/muddy-service:latest` represents the new tag of the above docker image which will need to be pushed to the HSC repo. **NOTE**: The tag of this image MUST be `latest`

3. Parametrize, Rename and Run the following script to update the CWL and YAML files in the HSC's repo.
```bash
bash pull-push-runfiles-muddy.sh
```
Short desscription: What this script does is 1) Retrieve the CWL and YAML from your organization's development/test repo, 2) modify the CWL (dockerPull lines), 3) rename the CWL, 4) Copy the renamed CWL, and the YAML to the existing destination repo that is already cloned locally, 5) add, commit and push from the local destination repo to the equivalent remote (i.e., the HSC)

The parameters that need to be changed are:
```bash
SRC_REPO # The repository you want to retrieve the CWL and YAML from (i.e., your organization's dev/test repo)
SRC_BRANCH # The desired branch of you SRC_REPO that you want to retrieve the CWL and YAML from
DEST_REPO_LOCAL # The local directory that shows to the `water-monitoring-integration-tests` local repo. This must pre-exist in your machine
DEST_SUBPATH # The sub-directory inside the local destination repo that you want the CWL and YAML to be copied into
COMMIT_MSG # the desired commit message
REWRITE_FROM # This is the development/test docker image NAME and TAG that exist in your organization's repository for the development/test. This line exists inside the CWL. So when you push this docker image to the destination (HSC) repo you also need to change the docker image name and tag lines inside the CWL, as well.
REWRITE_TO # This is the production docker image NAME and TAG that will exist in the production (i.e., HSC destination) repo
SRC_MUDDY # the name of the CWL file which you want to retrieve > modify > rename > copy to the destination repo
SRC_INPUTS # the name of the yaml file which you want to retrieve and copy to the destination repo
Line 125,142,143,146 # The names of the cwl and yaml that will be copied to the destination remote repo. These may need adaptation (e.g., the muddy.cwl)

```