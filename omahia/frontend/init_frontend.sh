#!/bin/bash
# Ensure we are in the correct base directory for frontend setup
cd /app/omahia/frontend || { echo "Failed to cd to /app/omahia/frontend"; exit 1; }

echo "Current directory: $(pwd)"

# Define a temporary directory for create-react-app
TEMP_APP_DIR="cra_temp"

# Create the temporary directory
mkdir "$TEMP_APP_DIR" || { echo "Failed to create temporary directory $TEMP_APP_DIR"; exit 1; }

# Navigate into the temporary directory
cd "$TEMP_APP_DIR" || { echo "Failed to cd to temporary directory $TEMP_APP_DIR"; exit 1; }

echo "Initializing React app in $(pwd)..."
# Using --use-npm because yarn might not be available or might cause issues.
npx create-react-app . --use-npm

# Check if create-react-app was successful by looking for a key file, e.g., package.json
if [ ! -f "package.json" ]; then
    echo "create-react-app failed to create a package.json in $TEMP_APP_DIR"
    # Clean up temp dir before exiting
    cd ..
    rm -rf "$TEMP_APP_DIR"
    exit 1
fi

echo "Moving React app files from $TEMP_APP_DIR to /app/omahia/frontend..."
# Move all files (including dotfiles) from TEMP_APP_DIR to the parent directory (omahia/frontend)
# The 'dotglob' option makes '*' match dotfiles. 'shopt -s dotglob' enables it.
shopt -s dotglob
mv ./* ..
shopt -u dotglob # Disable dotglob again to be safe

# Navigate back to the parent directory (omahia/frontend)
cd .. || { echo "Failed to cd back to /app/omahia/frontend"; exit 1; }

# Remove the now-empty temporary directory
echo "Cleaning up temporary directory $TEMP_APP_DIR..."
rm -rf "$TEMP_APP_DIR"

echo "Frontend initialization script finished successfully."
