#Node.js API#

Simple API based on NodeJS.

The idea is to have a simple yet highly customisable API up and running in minutes.
Quite useful for building Apps that need to store and query data.

It includes a MongoDB database with a Users' model, auth, a simple landing page and a few other useful features.

Pull requests and contributors are more then welcome :)



#Linux Server Setup#

##Install all software##
To build a server that automates installing all required software (nginx, nodejs, mongo, expresJs...) simply run the ServerSetup.sh script. 
Tested on Ubuntu 14.04, for running on any other distributions a couple of updates are required in the mongo db installation part)
- `./ServerSetup.sh`

##Config##

Make sure you update the `helpers/config.js` file



#Local Setup#

Install modules
`sudo npm install`

Start MongoDB on the data directory
`mongod --dbpath data`

Build API documentation
apidoc -i ./ -o public/apiDocs/ -e node_modules

Start the server
`node bin/www`

View API documentation
`http://localhost:3000/apiDocs/`

View landing page
`http://localhost:3000`