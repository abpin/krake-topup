cronJob = require('cron').CronJob
express = require 'express'
fs = require 'fs'
kson = require 'kson'
Sequelize = require 'sequelize'
schemaConfig = require('krake-toolkit').schema.config
schemaMember = require('krake-toolkit').schema.member

# Configuration setup
global.CONFIG = null;
global.ENV = (process.env['NODE_ENV'] || 'development').toLowerCase()
try 
  CONFIG = kson.parse(fs.readFileSync(__dirname + '/config/config.js').toString())[ENV];
catch error
  console.log('cannot parse config.js')
  process.exit(1)

# Postgresql connection setup 
options =
  host : CONFIG.postgres.host
  port : CONFIG.postgres.port
  dialect : 'postgres'
  logging : false
  pool :
    maxConnections : 5
    maxIdleTime : 30

dbHandler = new Sequelize CONFIG.userDataDB, CONFIG.postgres.username, CONFIG.postgres.password, options
Member = dbHandler.define 'members', schemaMember, schemaConfig


job = new cronJob(
  cronTime: "0 0 0 * * *",
  timeZone : 'Asia/Singapore',
  onTick : ()=>
    console.log new Date() + " Topping up accounts for the day"

    succeeded = (members)=>
      members.forEach (member)->
        switch member.package
          when "startup"
            member.quota += 5000
            member.save()
            console.log "topped 5,000 quota for member_id: %s", member.id

          when "business"
            member.quota += 50000
            member.save()
            console.log "topped 50,000 quota for member_id: %s", member.id

          when "power_user"
            member.quota += 500000
            member.save()
            console.log "topped 500,000 quota for member_id: %s", member.id

          else
            console.log "%s does not have a paid subscription", member.id


    failed = (error)=>
      res.send { error: error }

    Member.findAll({ where : [ "topup_day=? ", new Date().getDate() ] }).success(succeeded).error(failed)
)
job.start()


# Web Server section of system
app = module.exports = express.createServer()

app.configure ()->
  app.use(express.cookieParser())
  app.use(express.bodyParser())
  app.use(app.router)


app.get '/', (req, res)=>
  succeeded = (results)=>
    res.send results

  failed = (error)=>
    res.send { error: error }  

  Member.findAll({ 
    where : [ "package=? or package=? or package=? or package=? ", "startup", "business", "power_user", "poseidon" ] 
  }).success(succeeded).error(failed)


app.get '/:plan', (req, res)=>

  succeeded = (results)=>
    res.send results

  failed = (error)=>
    res.send { error: error }

  switch req.params.plan
    when "startup", "business", "power_user", "poseidon"
      Member.findAll({ where : [ "package=? ", req.params.plan] }).success(succeeded).error(failed)
    else
      res.send { error: "package " + req.params.plan + " does not exist" }


# app.get '/topup/:member_id', (req, res)=>
#   succeeded = (member)=>
#     switch member.package
#       when "startup"
#         member.quota += 5000
#         member.save()
#         res.send { status: "SUCCESS", message: "topped up quota", member: member }

#       when "business"
#         member.quota += 50000
#         member.save()
#         res.send { status: "SUCCESS", message: "topped up quota", member: member }

#       when "power_user"
#         member.quota += 500000
#         member.save()
#         res.send { status: "SUCCESS", message: "topped up quota", member: member }

#       else
#         res.send { error: "member " + req.params.member_id + " does not exist" }


#   failed = (error)=>
#     res.send { error: error }

#   Member.find(req.params.member_id).success(succeeded).error(failed)



# Start scheduling server
port = process.argv[2] || 9809
app.listen port
console.log 'topup server started on', port

