#!/usr/bin/env bash
set -euo pipefail

# Live-cluster operation. `start` suspends Flux reconciliation for model
# Kustomizations, scales every InferenceService in the namespace to zero, then
# starts the selected model. `resume` re-enables Flux reconciliation.
NAMESPACE="${NAMESPACE:-ai}"
TARGET="${TARGET:-swift-qwen3-8-27b-iq3-s-mtp}"

usage() {
  printf 'Usage: %s [start|resume]\n\n' "$0"
  printf '  start   Discover all InferenceServices in %s, suspend model Flux\n' "$NAMESPACE"
  printf '          Kustomizations, stop every service, then start %s. (default)\n' "$TARGET"
  printf '  resume  Resume model Flux Kustomizations; Git-managed settings will\n'
  printf '          be reconciled again.\n'
}

ACTION="${1:-start}"
if [[ $# -gt 1 || "$ACTION" == "--help" || "$ACTION" == "-h" ]]; then
  usage
  [[ "$ACTION" == "--help" || "$ACTION" == "-h" ]] && exit 0
  exit 2
fi

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    printf 'Error: jq is required to discover model resources.\n' >&2
    exit 1
  fi
}

# Discover the parent Flux Kustomization plus every child whose path is one of
# this repo's reusable model-serving templates. These cover llama.cpp and
# audio-cpp model services without hardcoding individual model names.
discover_flux_kustomizations() {
  kube kubectl get kustomizations.kustomize.toolkit.fluxcd.io -n "$NAMESPACE" -o json |
    jq -r '.items[]
      | select(.metadata.name == "models" or
          ((.spec.path // "") | test("^\\./components/[^/]+-inference-template$")))
      | .metadata.name'
}

discover_inferenceservices() {
  kube kubectl get inferenceservices.serving.kserve.io -n "$NAMESPACE" -o json |
    jq -r '.items[].metadata.name'
}

require_jq
case "$ACTION" in
  resume)
    mapfile -t FLUX_KUSTOMIZATIONS < <(discover_flux_kustomizations)
    if [[ ${#FLUX_KUSTOMIZATIONS[@]} -eq 0 ]]; then
      printf 'No model Flux Kustomizations found in namespace %s.\n' "$NAMESPACE" >&2
      exit 1
    fi
    # Resume children before the parent so the parent cannot race and reset
    # their suspend state while they are being resumed.
    for kustomization in "${FLUX_KUSTOMIZATIONS[@]}"; do
      [[ "$kustomization" == "models" ]] && continue
      kube flux resume kustomization "$kustomization" --namespace "$NAMESPACE"
    done
    for kustomization in "${FLUX_KUSTOMIZATIONS[@]}"; do
      if [[ "$kustomization" == "models" ]]; then
        kube flux resume kustomization "$kustomization" --namespace "$NAMESPACE"
        break
      fi
    done
    printf 'Resumed model Flux Kustomizations. Git-managed settings will be reconciled.\n'
    ;;
  start)
    mapfile -t MODELS < <(discover_inferenceservices)
    mapfile -t FLUX_KUSTOMIZATIONS < <(discover_flux_kustomizations)
    if [[ ${#MODELS[@]} -eq 0 ]]; then
      printf 'No InferenceServices found in namespace %s.\n' "$NAMESPACE" >&2
      exit 1
    fi
    if [[ ! " ${MODELS[*]} " =~ [[:space:]]${TARGET}[[:space:]] ]]; then
      printf 'Target InferenceService %s was not found in namespace %s.\n' "$TARGET" "$NAMESPACE" >&2
      exit 1
    fi
    if [[ ${#FLUX_KUSTOMIZATIONS[@]} -eq 0 ]]; then
      printf 'No model Flux Kustomizations found in namespace %s.\n' "$NAMESPACE" >&2
      exit 1
    fi

    printf 'Discovered %d InferenceServices: %s\n' "${#MODELS[@]}" "${MODELS[*]}"
    printf 'Suspending %d model Flux Kustomizations...\n' "${#FLUX_KUSTOMIZATIONS[@]}"
    # Suspend the parent first so it cannot change the child Kustomizations
    # while we suspend them and patch the live InferenceServices.
    for kustomization in "${FLUX_KUSTOMIZATIONS[@]}"; do
      [[ "$kustomization" == "models" ]] &&
        kube flux suspend kustomization "$kustomization" --namespace "$NAMESPACE"
    done
    for kustomization in "${FLUX_KUSTOMIZATIONS[@]}"; do
      [[ "$kustomization" == "models" ]] && continue
      kube flux suspend kustomization "$kustomization" --namespace "$NAMESPACE"
    done

    printf 'Scaling all discovered InferenceServices to zero...\n'
    for model in "${MODELS[@]}"; do
      kube kubectl patch inferenceservice "$model" -n "$NAMESPACE" --type=merge \
        -p '{"metadata":{"annotations":{"serving.kserve.io/autoscalerClass":"none"}},"spec":{"predictor":{"minReplicas":0}}}' >/dev/null
    done

    printf 'Waiting for all model predictor deployments to stop...\n'
    for attempt in $(seq 1 120); do
      remaining=0
      for model in "${MODELS[@]}"; do
        replicas="$(kube kubectl get deployment "${model}-predictor" -n "$NAMESPACE" \
          -o 'jsonpath={.status.replicas}' 2>/dev/null || true)"
        if [[ -n "$replicas" && "$replicas" != "0" ]]; then
          remaining=$((remaining + 1))
        fi
      done
      if [[ "$remaining" -eq 0 ]]; then
        break
      fi
      if [[ "$attempt" -eq 120 ]]; then
        printf 'Timed out waiting for %s deployment(s) to scale down. Target was not enabled.\n' "$remaining" >&2
        exit 1
      fi
      sleep 5
    done

    printf 'Starting %s...\n' "$TARGET"
    kube kubectl patch inferenceservice "$TARGET" -n "$NAMESPACE" --type=merge \
      -p '{"metadata":{"annotations":{"serving.kserve.io/autoscalerClass":"none"}},"spec":{"predictor":{"minReplicas":1}}}' >/dev/null
    printf 'Requested one replica of %s. Model Flux reconciliation is suspended.\n' "$TARGET"
    printf 'When finished, run: %s resume\n' "$0"
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
