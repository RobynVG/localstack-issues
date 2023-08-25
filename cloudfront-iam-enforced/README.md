# IAM Enforcement breaks Cloudfront

When using Cloudfront on Localstack with IAM Enforcement enabled, the following error is logged in the Localstack Logs:

```
2023-08-17T18:42:43.798 ERROR --- [   asgi_gw_4] l.aws.handlers.logging     : exception during call chain
Traceback (most recent call last):
  File "/opt/code/localstack/.venv/lib/python3.10/site-packages/localstack/aws/chain.py", line 90, in handle
    handler(self, self.context, response)
  File "/opt/code/localstack/.venv/lib/python3.10/site-packages/localstack/aws/chain.py", line 212, in __call__
    handler(chain, context, response)
  File "/opt/code/localstack/.venv/lib/python3.10/site-packages/localstack_ext/services/iam/policy_engine/handler.py.enc", line 15, in __call__
    A=C.policy_engine.is_request_allowed(B)
  File "/opt/code/localstack/.venv/lib/python3.10/site-packages/localstack_ext/services/iam/policy_engine/engine.py.enc", line 447, in is_request_allowed
    F=B.action_extractor.get_required_iam_actions_for_request(context=A);D=B.check_actions_allowed_for_principal(required_actions=F,source_principal=C,context=A);B.process_callbacks(D,A);return D
  File "/opt/code/localstack/.venv/lib/python3.10/site-packages/localstack_ext/services/iam/policy_engine/engine.py.enc", line 215, in get_required_iam_actions_for_request
    I=C['action'];B=[];M,R,N=I.partition(':');J=D.definitions[M];O=J['privileges'][N];P=J['resources'];F=ResourceRenderer(C,O,P,region=A.region,account=H)
KeyError: 'CreateDistributionWithTags'
2023-08-17T18:42:43.800  INFO --- [   asgi_gw_4] localstack.request.aws     : AWS cloudfront.CreateDistributionWithTags => 500 (InternalError)
```

## Prerequisites

- terraform
- Localstack's Terraform Local: `pip install terraform-local`
- Docker with Docker Compose

## Run This Reproduction

You can run `./run.sh` to run the full thing in one go, or use the steps below (which are the ones used in the `run.sh` file):

1. Remove any existing terraform state file using `rm -rf terraform.tfstate`
2. Start localstack using `docker compose up -d --wait`
3. Initialize Terraform using `tflocal init`
4. Run terraform using `tflocal apply --auto-approve`

The Terraform configuration simply creates the following:

- A S3 Bucket
- A Cloudfront Distribution (using [Cloudfront Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest)) exposing that S3 Bucket

You should see that Terraform will try to create the Cloudfront Distribution for a long duration, while the Localstack Container will be logging errors as such:

```
2023-08-17T18:42:43.800  INFO --- [   asgi_gw_4] localstack.request.aws     : AWS cloudfront.CreateDistributionWithTags => 500 (InternalError)
```

Now, if you stop the Localstack container and change the environment variable `LOCALSTACK_ENFORCE_IAM` to have a value of `0` instead of `1`, you'll see that the steps above work just fine.
