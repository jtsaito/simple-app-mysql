app_path = File.expand_path(File.dirname(__FILE__) + '/..')

working_directory app_path

pid "#{app_path}/tmp/pids/unicorn.pid"

stderr_path "#{app_path}/log/unicorn.log"
stdout_path "#{app_path}/log/unicorn.log"

listen 3000
listen "/tmp/unicorn.simple-app.sock"

worker_processes 2

timeout 30
