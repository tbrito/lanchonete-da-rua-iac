#!/bin/bash

echo "Executing create_pkg.sh..."

cd $path_cwd
dir_name=lambda_dist_pkg/
mkdir $dir_name

# Create and activate virtual environment...
virtualenv -p $runtime env_$function_name
source $path_cwd/env_$function_name/bin/activate

# Installing python dependencies...
FILE=$path_cwd/$function_name/requirements.txt

if [ -f "$FILE" ]; then
  echo "Installing dependencies..."
  echo "From: requirement.txt file exists..."
  pip install -r "$FILE" -t $path_cwd/$dir_name

else
  echo "Error: requirement.txt does not exist!"
fi

# Deactivate virtual environment...
deactivate

# Create deployment package...
# echo "Creating deployment package..."
# cd env_$function_name/lib/$runtime/site-packages/
# cp -r . $path_cwd/$dir_name
# cp -r $path_cwd/$function_name/* $path_cwd/$
# cd $path_cwd/$dir_name && zip -r ../$function_name.zip .

# Copy function code to the package directory...
echo "Creating deployment package..."
cp -r $path_cwd/$function_name/* $path_cwd/$dir_name

# Create a ZIP file of the package directory...
cd $path_cwd/$dir_name
zip -r ../$function_name.zip .

# Removing virtual environment folder...
echo "Removing virtual environment folder..."
# rm -rf $path_cwd/env_$function_name

echo "Finished script execution!"