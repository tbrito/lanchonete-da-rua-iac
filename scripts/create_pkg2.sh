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
  pip install -r "$FILE" -t ./$function_name

  # Create deployment package...
  echo "Creating deployment package..."
  cd env_$function_name/lib/$runtime/site-packages/
  cp -r . $path_cwd/$dir_name
  cp -r $path_cwd/$function_name/ $path_cwd/$dir_name

else
  echo "Error: requirement.txt does not exist!"
fi

# Deactivate virtual environment...
deactivate



# Removing virtual environment folder...
echo "Removing virtual environment folder..."
rm -rf $path_cwd/env_$function_name

echo "Finished script execution!"