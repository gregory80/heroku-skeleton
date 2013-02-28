#!/bin/bash
#
# author: gregory tomlinson
# copyright: 2013
# Liscense: MIT
# repos: https://github.com/gregory80/heroku-skeleton
# 
# Usage:
#     bash <(curl -fsSL "http://bitly.com/heroku-skeleton") ~/path/to/app
#     cd ~/path/to/app
#     bash app/scripts/runlocal.sh #start server on port 5000
# 
# Inspired by mike dory on Tornado-Heroku-Quickstart
# https://github.com/mikedory/Tornado-Heroku-Quickstart
#
# see README.md
# 
# gunicorn for heroku start code via 
# https://github.com/mccutchen
# 
if [ $# -lt 1 ]; then
  echo "Usage: build_env.sh <../path/to/myapp>"
  exit 1
fi
# options
INSTALL_PIP=false
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#
#
echo "Starting heroku-skeleton stub out, version 1.0"
echo "Report issues to github issues:"
echo "https://github.com/gregory80/heroku-skeleton"
echo "Creating application $1"
echo "...................."
sleep 1
#
# first create the directory
#
mkdir -p $1
pushd $1 > /dev/null
#
#
mkdir -p app/scripts app/static app/config
touch README.md requirements.txt .gitignore .env
# make virtual env
#
#
virtualenv venv --distribute
source venv/bin/activate
#
pushd app > /dev/null
# in the app folder
touch webapp.py __init__.py config/dev.conf scripts/runlocal.sh
#
#
# Add External JS Files
mkdir -p static/js static/css static/graphics templates
pushd static/js > /dev/null
echo "Fetching static JS library files"
jsfiles=(
  'http://code.jquery.com/jquery-1.9.1.js' 
  'http://backbonejs.org/backbone.js'
  'http://underscorejs.org/underscore.js' 
  'https://raw.github.com/janl/mustache.js/master/mustache.js'
  )
for jsfile in ${jsfiles[@]}
do
  filepath=(${jsfile//\// })
  curl ${jsfile} -o ${filepath[${#filepath[@]}-1]} 2&> /dev/null
done
#
#
popd > /dev/null


#
function readTmplFile {
  if [ -f "$1" ];
  then
    # use the local copy
    cat $1
  else
    # fail over to remote
    curl -fsSL "$2" 2>/dev/null
  fi
  return 0
}
#
#
#
# leave the app/ dir
popd > /dev/null
#
known_files=("app/webapp.py" 
  "app/templates/main.html" "app/static/js/app.js"
  "app/scripts/compile.sh" "app/scripts/closure_compile.py"
  "app/scripts/runlocal.sh" "app/scripts/compile.sh"
  "app/uimodules/scripttag.html")
for kfile in ${known_files[@]}
do
  file_str=$(readTmplFile "${SCRIPTDIR}/build_templates/${kfile}" "${BASE_GIT}/build_templates/${kfile}")
  echo "${file_str}" > ${kfile}
done
#
# pip install basic packages
# only tornado is TRULY needed
# the rest make like easier
if $INSTALL_PIP; then
  pip install tornado
  pip install gunicorn 
  pip install redis 
  pip install pylibmc 
  pip install lxml
  # pip install boto 
  # pip install CoffeeScript
  # pip install lesscss  
fi
#
# build the requirements file
#
pip freeze > requirements.txt
echo "This is a stub for tornado on heroku" > README.md
#
#
echo "*.pyc" >> .gitignore
echo ".DS_Store" >> .gitignore
echo ".env" >> .gitignore
echo "venv/" >> .gitignore
#
#
echo 'ENV="dev"' >> .env
echo 'PORT=5000' >> .env
echo 'MEMCACHE_SERVERS="127.0.0.1"' >> .env
#
#
echo 'app_name="my example app"' >> app/config/dev.conf
#
echo "web: gunicorn -k tornado --workers=4 --bind=0.0.0.0:\$PORT 'app.webapp:webapp()'" > Procfile
#
# iniitalize git, add our files
git init .
git add .
git commit -m "initial commit"
#
#
echo "...................................................."
echo "Your application $1"
echo "Execute"
echo "bash $1/app/scripts/runlocal.sh"
echo "to start server on port 5000"
echo "Configure local dev port .env"
echo "...................................................."
#
#
exit 0

