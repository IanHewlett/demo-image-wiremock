#!/usr/bin/env just --justfile
set dotenv-load
repo := "ghcr.io/ianhewlett"
image := "wiremock"

@_default:
  just --list

build tag:
  just _build {{repo}} {{image}} {{tag}}

scan tag:
  just _scan {{repo}} {{image}} {{tag}}

login:
  just _login {{repo}}

push tag:
  just _push {{repo}} {{image}} {{tag}}

sign tag:
  just _sign {{repo}} {{image}} {{tag}}

ci-on-git-push tag: (build tag) (scan tag)

ci-on-git-tag tag: (build tag) (scan tag) login (push tag) (sign tag)

_build repo image tag:
  docker build . --tag {{repo}}/{{image}}:{{tag}}

_scan repo image tag allow_scan_fail="true":
  snyk test \
    --docker {{repo}}/{{image}}:{{tag}} \
    --severity-threshold=high \
    --policy-path=.snyk \
    || {{allow_scan_fail}}

_login repo:
  docker login -u username -p "$GITHUB_TOKEN" {{repo}}

_push repo image tag:
  docker push {{repo}}/{{image}}:{{tag}}

_sign repo image tag:
  VAULT_NAMESPACE=admin \
    cosign sign --key hashivault://image_signing_key {{repo}}/{{image}}:{{tag}}
