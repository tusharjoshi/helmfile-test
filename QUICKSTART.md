# Helmfile Quick Reference

## Quick Commands

### Setup
```bash
# Install helmfile and helm
./envsetup.sh

# Validate configuration
./validate.sh
```

### Deployment
```bash
# Deploy to development
./deploy.sh deploy development

# Deploy to staging
./deploy.sh deploy staging

# Deploy to production
./deploy.sh deploy production
```

### Status and Monitoring
```bash
# Check deployment status
./deploy.sh status development

# Show differences before deploying
./deploy.sh diff staging

# Generate templates (dry-run)
./deploy.sh template production
```

### Cleanup
```bash
# Destroy all releases in environment
./deploy.sh destroy development
```

## Environment Differences

| Feature | Default | Development | Staging | Production |
|---------|---------|-------------|---------|------------|
| Nginx Service | ClusterIP | NodePort | LoadBalancer | LoadBalancer |
| Nginx Replicas | 1 | 1 | 2 | 3 |
| Redis Auth | Enabled | Disabled | Enabled | Enabled |
| Redis Persistence | Disabled | Disabled | Enabled | Enabled |
| Ingress Controller | Disabled | Enabled | Enabled | Enabled |
| Resource Limits | Minimal | Low | Medium | High |

## Useful kubectl Commands

```bash
# List all resources across namespaces
kubectl get all --all-namespaces

# Check specific namespace
kubectl get all -n web-dev

# View pod logs
kubectl logs -n web-dev deployment/nginx-web-dev

# Port forward to access services locally
kubectl port-forward -n web-dev svc/nginx-web-dev 8080:80

# Check persistent volumes (staging/production)
kubectl get pv,pvc -n cache-staging
```

## Troubleshooting

### Common Issues
1. **Template errors**: Check `.gotmpl` files for syntax
2. **Missing values**: Verify environment YAML files
3. **Chart versions**: Update versions in environment configs
4. **Resource constraints**: Adjust resource requests/limits

### Debug Commands
```bash
# Enable debug mode
helmfile --environment development --debug sync

# Check what would be deployed
helmfile --environment development diff

# Validate templates only
helmfile --environment development template
```
