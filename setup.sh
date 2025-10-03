#!/bin/bash

# ==============================================================================
#   SSEMR Project Environment Setup Script
# ==============================================================================
#
# This script automates the setup of the development environment. It will:
#   1. Check for necessary prerequisites (git, docker).
#   2. Detect the correct Docker Compose command.
#   3. Verify that the 'frontend' and 'distro' directories exist.
#   4. Create a `.env` file from an `example.env` template.
#   5. Launch the application using Docker Compose.
#
# ==============================================================================

# --- Helper Functions ---
print_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Main Script ---

# 1. Check Prerequisites
print_info "Checking for required tools..."
has_error=0
for cmd in git docker; do
    if ! command_exists $cmd; then
        print_error "$cmd is not installed. Please install it before proceeding."
        has_error=1
    fi
done

if [ $has_error -eq 1 ]; then
    exit 1
fi
print_success "All required tools are installed."

# 2. Detect Docker Compose Command
print_info "Detecting Docker Compose command..."
if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
elif command_exists docker-compose; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    print_error "Docker Compose not found. Please ensure 'docker compose' (v2) or 'docker-compose' (v1) is installed."
    exit 1
fi
print_success "Using '$DOCKER_COMPOSE_CMD' for Docker Compose."


# 3. Check for Project Directories
print_info "Checking for project directories..."

# These directories are expected to be in the same location as the script
FRONTEND_DIR="frontend"
BACKEND_DIR="distro"

if [ ! -d "$FRONTEND_DIR" ]; then
    print_error "Frontend directory '$FRONTEND_DIR' not found. Please ensure it exists in the root directory."
    exit 1
fi

if [ ! -d "$BACKEND_DIR" ]; then
    print_error "Backend (distro) directory '$BACKEND_DIR' not found. Please ensure it exists in the root directory."
    exit 1
fi
print_success "Found '$FRONTEND_DIR' and '$BACKEND_DIR' directories."


# 4. Create .env File from Template
print_info "Configuring environment variables..."
if [ -f ".env" ]; then
    print_warning ".env file already exists. Using existing configuration."
else
    print_info ".env file not found. Looking for example.env..."
    if [ -f "example.env" ]; then
        cp example.env .env
        print_success "Copied 'example.env' to '.env'."
        print_warning "IMPORTANT: Please review and edit the '.env' file with your actual credentials before proceeding."
        read -p "Press [Enter] to continue once you have updated the .env file..."
    else
        print_error "'example.env' not found. Cannot create .env file automatically."
        print_error "Please create an 'example.env' template or a '.env' file manually and re-run the script."
        exit 1
    fi
fi

# 5. Check Docker Compose File
print_info "Checking docker-compose configuration..."
DOCKER_COMPOSE_FILE="docker-compose.yml"

if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    print_error "'$DOCKER_COMPOSE_FILE' not found. Please ensure it is in the current directory."
    exit 1
fi

print_warning "Please ensure the 'context' paths in '$DOCKER_COMPOSE_FILE' are correct:"
print_warning "  - frontend build context should point to './$FRONTEND_DIR'"
print_warning "  - backend build context should point to './$BACKEND_DIR'"
read -p "Press [Enter] to continue if paths are correct..."

# 6. Build and Launch
print_info "Starting the application... This may take several minutes."
print_info "Running: $DOCKER_COMPOSE_CMD -f $DOCKER_COMPOSE_FILE up -d --build"

if ! $DOCKER_COMPOSE_CMD -f "$DOCKER_COMPOSE_FILE" up -d --build; then
    print_error "Docker Compose failed to start."
    print_error "Try running '$DOCKER_COMPOSE_CMD -f $DOCKER_COMPOSE_FILE up --build' in your terminal to see detailed logs."
    exit 1
fi

print_success "Application is starting in the background!"
print_info "To view logs, run: $DOCKER_COMPOSE_CMD -f $DOCKER_COMPOSE_FILE logs -f"
print_info "Once the health checks pass, the application will be available at http://localhost"

