# Helmfile Umbrella Chart Example

This project demonstrates how to use Helmfile as an umbrella chart to deploy multiple Helm charts with configurable values across different environments.

## Features

- **Two Example Charts**: NGINX web server and Redis cache
- **Environment-specific Configuration**: Support for default, development, staging, and production environments
- **Optional Ingress Controller**: Conditionally deployed based on environment configuration
- **Dynamic Value Templating**: Uses Go templates for flexible configuration
- **Resource Management**: Environment-specific resource allocation
- **Lifecycle Hooks**: Pre and post-deployment hooks

## Project Structure

```
helmfile-test/
├── helmfile.yaml                 # Main helmfile configuration
├── deploy.sh                     # Deployment utility script
├── environments/                 # Environment-specific configurations
│   ├── default.yaml
│   ├── development.yaml
│   ├── staging.yaml
│   └── production.yaml
├── values/                       # Helm chart value templates
│   ├── nginx-values.yaml.gotmpl
│   ├── redis-values.yaml.gotmpl
│   └── ingress-values.yaml.gotmpl
└── README.md
```

## Prerequisites

- [Helm](https://helm.sh/docs/intro/install/) v3.0+
- [Helmfile](https://github.com/helmfile/helmfile) v0.150+
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) configured with cluster access
- Kubernetes cluster (local or remote)

## Quick Start

### 1. Install Dependencies

Run the setup script to install helmfile and other dependencies:

```bash
chmod +x envsetup.sh
./envsetup.sh
```

### 2. Deploy to Development Environment

```bash
# Deploy all charts to development environment
./deploy.sh deploy development

# Or use helmfile directly
helmfile --environment development sync
```

### 3. Check Deployment Status

```bash
./deploy.sh status development
```

## Environment Configurations

### Default Environment
- Minimal resource allocation
- ClusterIP services
- No ingress controller
- Basic authentication

### Development Environment  
- NodePort services for easy access
- Ingress controller enabled
- Debug logging
- Minimal resources for testing

### Staging Environment
- LoadBalancer services
- Ingress controller enabled
- Persistent storage for Redis
- Medium resource allocation

### Production Environment
- LoadBalancer services
- Ingress controller with autoscaling
- Persistent storage with custom storage class
- High availability (3 replicas for nginx)
- Production-level resource allocation

## Usage Examples

### Deploy to Specific Environment

```bash
# Deploy to staging
./deploy.sh deploy staging

# Deploy to production
./deploy.sh deploy production
```

### Show What Would Be Deployed (Dry Run)

```bash
./deploy.sh deploy production --dry-run
```

### View Differences Before Deployment

```bash
./deploy.sh diff staging
```

### Generate Templates Without Deploying

```bash
./deploy.sh template development
```

### Destroy All Resources

```bash
./deploy.sh destroy development
```

## Configuration Override Examples

### Override Values at Runtime

You can override values using environment variables or helmfile flags:

```bash
# Override Redis password
REDIS_PASSWORD=mysecretpassword helmfile --environment production sync

# Override nginx replica count
helmfile --environment staging --set nginx.replicaCount=5 sync
```

### Custom Values Files

Create additional values files for specific use cases:

```bash
# Create custom values
echo "nginx:
  replicaCount: 10
  resources:
    requests:
      cpu: 500m" > custom-values.yaml

# Deploy with custom values
helmfile --environment production --values custom-values.yaml sync
```

## Chart Configurations

### NGINX Web Server
- **Chart**: `bitnami/nginx`
- **Purpose**: Web server with custom welcome page
- **Configuration**: Resources, replicas, service type
- **Health Checks**: Liveness and readiness probes

### Redis Cache
- **Chart**: `bitnami/redis`
- **Purpose**: In-memory cache and data store
- **Configuration**: Authentication, persistence, resources
- **Modes**: Standalone architecture

### NGINX Ingress Controller (Optional)
- **Chart**: `ingress-nginx/ingress-nginx`
- **Purpose**: Ingress traffic management
- **Configuration**: Autoscaling, metrics, SSL termination
- **Conditional**: Only deployed when `ingress.enabled: true`

## Customization

### Adding New Charts

1. Add repository to `helmfile.yaml`:
```yaml
repositories:
  - name: my-repo
    url: https://my-charts.example.com
```

2. Add release configuration:
```yaml
releases:
  - name: my-app
    chart: my-repo/my-chart
    values:
      - values/my-app-values.yaml.gotmpl
```

3. Create values template in `values/my-app-values.yaml.gotmpl`

4. Add environment-specific configs in `environments/*.yaml`

### Environment Variables

The project supports several environment variables:

- `REDIS_PASSWORD`: Override Redis password (production)
- `KUBECONFIG`: Specify kubeconfig file location
- `HELM_DEBUG`: Enable Helm debug mode

## Troubleshooting

### Common Issues

1. **Template Parsing Errors**
   - Check Go template syntax in `.gotmpl` files
   - Ensure proper quoting around template expressions

2. **Missing Values**
   - Verify environment files contain required values
   - Check default values in `helmfile.yaml`

3. **Chart Version Issues**
   - Update chart versions in environment files
   - Run `helm repo update` to refresh chart repositories

### Debug Mode

Enable debug output for detailed information:

```bash
helmfile --environment development --debug sync
```

### Validate Templates

Generate templates without deploying to check syntax:

```bash
helmfile --environment development template
```

## Best Practices

1. **Version Control**: Always version your environment configurations
2. **Secrets Management**: Use external secret management for sensitive data
3. **Testing**: Test deployments in development before staging/production
4. **Monitoring**: Monitor resource usage and adjust configurations accordingly
5. **Backup**: Ensure persistent data is backed up (Redis with persistence enabled)

## Commands to test helmfile on K8S sandbox

These commands are tested on [Killercoda Sandbox](https://killercoda.com/)

### Installing helmfile

```bash
git clone https://github.com/tusharjoshi/helmfile-test.git
cd helmfile-test
chmod +x envsetup.sh
./envsetup.sh
```

### Quick Deploy

```bash
# Deploy to development environment
./deploy.sh deploy development

# Check status
kubectl get pods --all-namespaces

# Access NGINX (if using NodePort in development)
curl http://localhost:30080

# Clean up
./deploy.sh destroy development
```
