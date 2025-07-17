# Testing Guide for Homeserver Helm Chart

This document explains the comprehensive testing strategy for the homeserver Helm chart.

## Overview

The testing strategy includes:
- **YAML Linting**: Syntax and style validation
- **JSON Schema Validation**: Values file validation
- **Helm Unit Tests**: Template logic and service rendering tests
- **Helm Lint**: Chart best practices validation
- **Template Rendering**: All services template generation
- **Security Scanning**: Security policy validation
- **Chart Testing**: Integration testing with Kubernetes

## Test Structure

```
tests/
├── template-helpers_test.yaml    # Tests for _*.tpl helper functions
├── services_test.yaml           # Tests for individual service logic
└── advanced-features_test.yaml  # Tests for VPN, CronJobs, etc.

ci-values.yaml                   # CI configuration enabling all services
ct.yaml                         # Chart testing configuration
.helmlintrc.yaml                # Helm lint configuration
```

## Running Tests Locally

### Prerequisites

```bash
# Install required tools
helm plugin install https://github.com/helm-unittest/helm-unittest
pip install yamllint
npm install -g ajv-cli

# Add Helm repositories
helm repo add cert-manager https://charts.jetstack.io
helm repo add authentik https://charts.goauthentik.io
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### Individual Test Commands

```bash
# YAML linting
yamllint .

# JSON Schema validation
ajv validate -s values.schema.json -d values.template.yaml
ajv validate -s values.schema.json -d ci-values.yaml

# Helm linting
helm lint .
helm lint . --values values.template.yaml
helm lint . --values ci-values.yaml

# Helm unit tests
helm unittest tests/template-helpers_test.yaml
helm unittest tests/services_test.yaml
helm unittest tests/advanced-features_test.yaml

# Template rendering (all services)
helm template homeserver . --values ci-values.yaml > rendered-manifests.yaml

# Template rendering (individual service)
helm template homeserver . --set services.homepage.enabled=true > homepage-manifest.yaml
```

### Security Testing

```bash
# Install security tools
wget https://github.com/controlplaneio/kubesec/releases/latest/download/kubesec_linux_amd64.tar.gz
tar -xzf kubesec_linux_amd64.tar.gz
sudo mv kubesec /usr/local/bin/

wget https://github.com/FairwindsOps/polaris/releases/latest/download/polaris_linux_amd64.tar.gz
tar -xzf polaris_linux_amd64.tar.gz
sudo mv polaris /usr/local/bin/

# Run security scans
helm template homeserver . --values ci-values.yaml > all-manifests.yaml
kubesec scan all-manifests.yaml
polaris audit --audit-path=all-manifests.yaml
```

### Chart Testing (requires Kubernetes cluster)

```bash
# Install chart-testing
curl -LO https://github.com/helm/chart-testing/releases/latest/download/chart-testing_linux_amd64.tar.gz
tar -xzf chart-testing_linux_amd64.tar.gz
sudo mv ct /usr/local/bin/

# Run chart tests
ct lint --config ct.yaml
ct install --config ct.yaml
```

## Test Configuration Files

### ci-values.yaml

Comprehensive values file that enables **all 40+ services** for testing:
- Minimal but valid configuration for each service
- Disabled secrets/persistence for CI environment
- Staging certificates to avoid rate limits
- All required subchart configurations

### Test Coverage

**Template Helpers** (15+ tests):
- Name generation and truncation
- Label generation with VPN flags
- Chart metadata handling
- Namespace handling

**Service Logic** (20+ tests):
- Service enablement/disablement
- VPN sidecar injection
- Persistence volume mounting
- Security context application
- Resource preset handling
- Environment variable injection
- Port configuration

**Advanced Features** (15+ tests):
- Conditional VPN sidecar injection
- CronJob rendering
- NodePort service creation
- Ingress route generation
- Environment variable templating
- Priority class assignment

**Security Scans**:
- kubesec: Security scanning of all rendered Kubernetes manifests
- Polaris: Best practices validation for all services
- Comprehensive manifest validation

## GitHub Actions CI/CD

The `.github/workflows/test.yaml` workflow includes:

1. **YAML Linting**: Validates all YAML files
2. **Schema Validation**: Validates values files against JSON schema
3. **Helm Linting**: Validates chart structure and templates
4. **Unit Testing**: Runs all helm unit tests
5. **Template Testing**: Tests rendering of all 40+ services individually and collectively
6. **Security Scanning**: Scans all generated manifests
7. **Chart Testing**: Full integration test with Kubernetes cluster

### Matrix Testing

Individual services are tested in parallel using GitHub Actions matrix strategy for faster feedback.

### Artifact Collection

- Rendered manifests are uploaded as artifacts
- Security scan results are preserved for review
- Test results are available for 30 days

## Test Philosophy

### Comprehensive Coverage

- **All Services**: Every service is tested individually and collectively
- **All Features**: VPN, persistence, security contexts, ingress, etc.
- **Edge Cases**: Minimal configs, disabled features, error conditions

### Fast Feedback

- Matrix parallelization for service testing
- Fail-fast strategy to catch issues early
- Artifact upload for debugging

### Security-First

- Security scanning of all rendered manifests
- Validation of security contexts and best practices
- Policy enforcement through OPA/Polaris

### Maintainability

- Dedicated CI values file (no inline configuration)
- Modular test structure
- Clear documentation and examples

## Common Issues and Troubleshooting

### Test Failures

**Template Rendering Fails**:
- Check required values are provided
- Verify subchart dependencies are available
- Review Helm lint output

**Unit Test Failures**:
- Validate test assertions match actual template output
- Check for changes in template helper functions
- Verify test data matches expected service structure

**Security Scan Issues**:
- Review kubesec/Polaris recommendations
- Update security contexts if needed
- Check for privileged containers (only VPN should be privileged)

### Adding New Tests

1. **For new services**: Add test cases to `services_test.yaml`
2. **For template helpers**: Add to `template-helpers_test.yaml`
3. **For advanced features**: Add to `advanced-features_test.yaml`
4. **Update ci-values.yaml**: Enable new service for comprehensive testing

## Best Practices

- Test both positive and negative cases (enabled/disabled)
- Validate security contexts and resource settings
- Test conditional logic (VPN, ingress, persistence)
- Include edge cases in unit tests
- Keep CI values minimal but comprehensive
- Document any special testing requirements
