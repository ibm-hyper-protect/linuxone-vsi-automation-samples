## Dynamic Registry Sample

This sample deploys the [hello-world](https://hub.docker.com/_/hello-world) example as a [IBM Cloud Hyper Protect Virtual Server for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-about-se).

### Prerequisite

Prepare your environment according to [these steps](../README.md)

## Usecase

This sample demonstrates how to use a dynamic registry reference.

### Explict Registry Reference

Typically the docker registry is referenced via the full docker URL in the compose file, e.g. like so:

```yaml
services:
  helloworld:
    image: docker.io/library/hello-world@sha256:53f1bbee2f52c39e41682ee1d388285290c5c8a76cc92b42687eecf38e0af3f0
```

Note that `docker.io/library/` is the registry prefix, `hello-world` the identifier of the OCI image in that registry and `sha256:53f1bbee2f52c39e41682ee1d388285290c5c8a76cc92b42687eecf38e0af3f0` is the unique identifier of the version of the image.

In such a case the role deciding about the registry (and the associated pull credentials) is the workload provider, since both the registry reference as well as the pull credentials are part of the workload section.

### Dynamic Registry Reference

There exist usecases in which the registry is **not know** when the workload section is pre-encrypted, e.g. when the workload provider wants to allow the deployer to use a registry mirror or a private container registry. 

In such a case it is possible to dynamically override the registry as well as the pull credentials. This is an coordinated effort between the workload provider and the deployer.

#### Workload Provider

The workload provider marks the registry as dynamic by using a replacement variable in the docker compose file:

```yaml
services:
  helloworld:
    image: ${REGISTRY}/hpse-docker-hello-world-s390x@sha256:43c500c5f85fc450060b804851992314778e35cadff03cb63042f593687b7347
    
```

Note that the digest of the image is identical across registries, so the workload provider can lock down the desired version of the image by setting the key, independent of what registry is actually being used. The feature to uses tokens in the compose file is a native feature of the [compose specification](https://docs.docker.com/compose/compose-file/#interpolation).

Now the workload provider can prepare (encrypt) the workload section **without** specifying the pull secrets for that registry.

#### Env Provider

The env provider fills in the missing information about the registry and the associated pull secrets.

The registry is set as an environment variable. Both the env provider as well as the workload provider can provided pieces to the overall environment and these are overlayed (with workload taking precedence)

The pull credentials are passed in via an `auth` section in the environment part of the contract. Just as environment variables these sections are overlayer with the workload section taking precedence.

```yaml
---
env:
  type: env
  auths:
    de.icr.io:
      username: xxx
      password: yyy
  env:
    REGISTRY: de.icr.io
```

