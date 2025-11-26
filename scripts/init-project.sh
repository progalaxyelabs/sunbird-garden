#!/bin/bash

# Sunbird Project Initialization Script
# Creates a new project from the sunbird-garden template

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script location (sunbird-garden root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Usage
usage() {
    echo -e "${BLUE}Usage:${NC} $0 <project-name> <target-path>"
    echo ""
    echo "Arguments:"
    echo "  project-name  Name for the new project (lowercase, no spaces)"
    echo "  target-path   Directory where the project will be created"
    echo ""
    echo "Example:"
    echo "  $0 myapp /home/user/projects"
    echo "  This creates /home/user/projects/myapp"
    exit 1
}

# Validate project name (lowercase, alphanumeric, hyphens only)
validate_project_name() {
    if [[ ! "$1" =~ ^[a-z][a-z0-9-]*$ ]]; then
        echo -e "${RED}Error:${NC} Project name must be lowercase, start with a letter, and contain only letters, numbers, and hyphens."
        exit 1
    fi
}

# Parse arguments
PROJECT_NAME=$1
TARGET_PATH=$2

if [ -z "$PROJECT_NAME" ] || [ -z "$TARGET_PATH" ]; then
    usage
fi

validate_project_name "$PROJECT_NAME"

# Full path for new project
PROJECT_PATH="$TARGET_PATH/$PROJECT_NAME"

# Check if target already exists
if [ -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error:${NC} Directory $PROJECT_PATH already exists."
    exit 1
fi

# Check if target path exists
if [ ! -d "$TARGET_PATH" ]; then
    echo -e "${YELLOW}Warning:${NC} Target path $TARGET_PATH does not exist. Creating it..."
    mkdir -p "$TARGET_PATH"
fi

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Sunbird Project Initialization${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "Source template: ${GREEN}$SCRIPT_DIR${NC}"
echo -e "New project:     ${GREEN}$PROJECT_PATH${NC}"
echo ""

# Step 1: Copy template
echo -e "${BLUE}[1/5] Copying template...${NC}"
cp -r "$SCRIPT_DIR" "$PROJECT_PATH"

# Remove backup directories if present
rm -rf "$PROJECT_PATH/sunbird-api.backup" 2>/dev/null || true
rm -rf "$PROJECT_PATH/sunbird-frontend.backup" 2>/dev/null || true
rm -rf "$PROJECT_PATH/.git" 2>/dev/null || true

echo -e "${GREEN}   Template copied${NC}"

# Step 2: Replace sunbird with project name in configuration files
echo -e "${BLUE}[2/5] Customizing project name...${NC}"

cd "$PROJECT_PATH"

# Replace in docker-compose.yaml
sed -i "s/sunbird-/$PROJECT_NAME-/g" docker-compose.yaml
sed -i "s/sunbird_/$PROJECT_NAME_/g" docker-compose.yaml

# Replace in .env.example
sed -i "s/Sunbird/${PROJECT_NAME^}/g" .env.example
sed -i "s/sunbird/$PROJECT_NAME/g" .env.example

# Replace in build.sh
sed -i "s/Sunbird/${PROJECT_NAME^}/g" build.sh

# Replace in www/package.json
sed -i "s/sunbird-www/$PROJECT_NAME-www/g" www/package.json

echo -e "${GREEN}   Project name updated${NC}"

# Step 3: Create .env from template
echo -e "${BLUE}[3/5] Creating .env file...${NC}"
cp .env.example .env
echo -e "${GREEN}   .env file created (remember to update secrets!)${NC}"

# Step 4: Initialize git repository
echo -e "${BLUE}[4/5] Initializing git repository...${NC}"
git init
git add .
git commit -m "Initial commit from sunbird-garden template

Project: $PROJECT_NAME
Template: sunbird-garden v2"
echo -e "${GREEN}   Git repository initialized${NC}"

# Step 5: Show next steps
echo -e "${BLUE}[5/5] Setup complete!${NC}"

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}Project $PROJECT_NAME created successfully!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "1. Update environment variables:"
echo -e "   ${YELLOW}cd $PROJECT_PATH${NC}"
echo -e "   ${YELLOW}nano .env${NC}"
echo ""
echo "2. Build and start the project:"
echo -e "   ${YELLOW}./build.sh${NC}"
echo -e "   ${YELLOW}docker compose up${NC}"
echo ""
echo "3. Access your application:"
echo "   Frontend: http://localhost:4400"
echo "   API:      http://localhost:4402"
echo "   Alert:    http://localhost:4401"
echo ""
echo "4. Add remote repository:"
echo -e "   ${YELLOW}git remote add origin git@bitbucket.org:progalaxyelabs/$PROJECT_NAME.git${NC}"
echo -e "   ${YELLOW}git push -u origin main${NC}"
echo ""
