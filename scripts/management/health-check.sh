#!/bin/bash
#
# Health Check Script
# Checks status of all critical services and resources
#
# Usage: bash scripts/management/health-check.sh
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Track overall health
ISSUES=0

print_header "Virtual Desktop Server Health Check"
echo "Generated: $(date)"
echo ""

# System Resources
print_header "System Resources"

# CPU
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
echo "CPU Usage: ${CPU_USAGE}%"
if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
    print_warning "High CPU usage"
    ((ISSUES++))
fi

# Memory
MEMORY_INFO=$(free -h | grep Mem)
MEMORY_USED=$(echo $MEMORY_INFO | awk '{print $3}')
MEMORY_TOTAL=$(echo $MEMORY_INFO | awk '{print $2}')
MEMORY_PERCENT=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')
echo "Memory: $MEMORY_USED / $MEMORY_TOTAL (${MEMORY_PERCENT}%)"
if (( $(echo "$MEMORY_PERCENT > 90" | bc -l) )); then
    print_warning "High memory usage"
    ((ISSUES++))
fi

# Disk
DISK_INFO=$(df -h / | tail -1)
DISK_USED=$(echo $DISK_INFO | awk '{print $3}')
DISK_TOTAL=$(echo $DISK_INFO | awk '{print $2}')
DISK_PERCENT=$(echo $DISK_INFO | awk '{print $5}' | tr -d '%')
echo "Disk: $DISK_USED / $DISK_TOTAL (${DISK_PERCENT}%)"
if [ "$DISK_PERCENT" -gt 90 ]; then
    print_error "Critical disk usage!"
    ((ISSUES++))
elif [ "$DISK_PERCENT" -gt 80 ]; then
    print_warning "High disk usage"
    ((ISSUES++))
fi

echo ""

# Services
print_header "Services Status"

check_service() {
    local service=$1
    local name=$2
    
    if systemctl is-active --quiet "$service"; then
        print_success "$name is running"
    else
        print_error "$name is not running"
        ((ISSUES++))
    fi
}

check_service "code-server" "code-server"
check_service "docker" "Docker"
check_service "fail2ban" "fail2ban"
check_service "google-cloud-ops-agent" "Cloud Ops Agent"

echo ""

# Network
print_header "Network Status"

# Check if port 8443 is listening
if sudo netstat -tuln | grep -q ':8443 '; then
    print_success "code-server port 8443 is listening"
else
    print_error "code-server port 8443 is NOT listening"
    ((ISSUES++))
fi

# Check internet connectivity
if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    print_success "Internet connectivity OK"
else
    print_error "No internet connectivity"
    ((ISSUES++))
fi

# Check DNS resolution
if ping -c 1 -W 2 google.com > /dev/null 2>&1; then
    print_success "DNS resolution OK"
else
    print_error "DNS resolution failed"
    ((ISSUES++))
fi

echo ""

# Firewall
print_header "Firewall Status"

if sudo ufw status | grep -q "Status: active"; then
    print_success "UFW firewall is active"
    
    # Check required ports
    if sudo ufw status | grep -q "8443"; then
        print_success "Port 8443 (code-server) is allowed"
    else
        print_warning "Port 8443 might not be allowed in UFW"
        ((ISSUES++))
    fi
else
    print_warning "UFW firewall is not active"
    ((ISSUES++))
fi

echo ""

# Storage
print_header "Storage Check"

# Check workspace directories
for workspace in workspace1-frontend workspace2-backend workspace3-ai-ml workspace4-infrastructure workspace5-experiments; do
    if [ -d "/data/shared/projects/$workspace" ]; then
        SIZE=$(du -sh "/data/shared/projects/$workspace" 2>/dev/null | cut -f1)
        echo "✓ $workspace: $SIZE"
    else
        print_error "$workspace directory missing"
        ((ISSUES++))
    fi
done

# Check backup directory
if [ -d "/backup" ]; then
    BACKUP_COUNT=$(ls /backup/projects_*.tar.gz 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 0 ]; then
        LATEST_BACKUP=$(ls -t /backup/projects_*.tar.gz 2>/dev/null | head -1)
        BACKUP_AGE=$(stat -c %Y "$LATEST_BACKUP")
        CURRENT_TIME=$(date +%s)
        AGE_DAYS=$(( (CURRENT_TIME - BACKUP_AGE) / 86400 ))
        
        echo "Backups: $BACKUP_COUNT total"
        echo "Latest backup: $(basename $LATEST_BACKUP) (${AGE_DAYS} days old)"
        
        if [ "$AGE_DAYS" -gt 2 ]; then
            print_warning "Latest backup is more than 2 days old"
            ((ISSUES++))
        fi
    else
        print_warning "No backups found"
        ((ISSUES++))
    fi
else
    print_error "Backup directory missing"
    ((ISSUES++))
fi

echo ""

# Development Tools
print_header "Development Tools"

check_command() {
    local cmd=$1
    local name=$2
    
    if command -v "$cmd" > /dev/null 2>&1; then
        VERSION=$($cmd --version 2>&1 | head -n1)
        echo "✓ $name: $VERSION"
    else
        print_error "$name not found"
        ((ISSUES++))
    fi
}

check_command "git" "Git"
check_command "docker" "Docker"
check_command "node" "Node.js"
check_command "python3" "Python"
check_command "go" "Go"
check_command "cargo" "Rust"
check_command "gcloud" "Google Cloud SDK"

echo ""

# Summary
print_header "Health Check Summary"

if [ $ISSUES -eq 0 ]; then
    print_success "All systems operational! 🎉"
    exit 0
elif [ $ISSUES -le 3 ]; then
    print_warning "System is mostly healthy but has $ISSUES issue(s)"
    exit 1
else
    print_error "System has $ISSUES issues that need attention"
    exit 2
fi
