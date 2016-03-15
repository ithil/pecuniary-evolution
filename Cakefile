{exec} = require 'child_process'
puts = (str) -> console.log str

task 'build', "Build project", ->
  exec 'coffee --bare --map --compile --output lib/ src/', (err, stdout, stderr) ->
    throw err if err
    puts stdout + stderr
