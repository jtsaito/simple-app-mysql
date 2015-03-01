Running a Rails App MySQL in Docker Different Containers
========================================================

The example simple-app-mysql Rails app contains only a single model
(Note) and a single controller generating a new Note instance and rendering
it as text. Here we describe how to launch the app and the database
(MySQL in our example) in two separate Docker containers and how to 
make the database container accessible by linking it from the app container.

1. Launch the mysql container.

```
docker run --name some-mysql-2 -e MYSQL_ROOT_PASSWORD=secret_password_here -e MYSQL_DATABASE=simple-app-mysql -d mysql
```

We need to assign the `name` to use it later for the `docker run --link` option when launching the app container.

We are using the `mysql` conatiner from [registry.hub.docker.com](https://registry.hub.docker.com/_/mysql/) which allows passing database name, user name and password by environment variables as in the example call above.


2. Crucially, we have set the `name` as `host` entry in our `config/databases.yml`.

```
production: 
   host: some-mysql-2
```


2. Run the app container's shell.
```
docker run -p 80:80 --link some-mysql-2:some-mysql-2 -i -t --entrypoint /bin/bash jtsaito/simple-app-mysql -s
```

3. Set up the database for the Rails project on the container. 

```
root@e5c1421b3af5:/var/www/simple-app# bundle exec rake db:setup
```

This yields (as expected):

```
simple-app-mysql already exists
-- create_table("notes", {:force=>:cascade})
   -> 0.0371s
-- initialize_schema_migrations_table()
   -> 0.0436s
-- create_table("notes", {:force=>:cascade})
   -> 0.0142s
-- initialize_schema_migrations_table()
   -> 0.0276s
root@e5c1421b3af5:/var/www/simple-app# bundle exec rails c production
Loading production environment (Rails 4.2.0)
irb(main):001:0> Note.all
  Note Load (0.6ms)  SELECT `notes`.* FROM `notes`
=> #<ActiveRecord::Relation []>
```

4. Launch the container as usual.

```
docker run -p 80:80 --link some-mysql-2:some-mysql-2  -i -t jtsaito/simple-app-mysql -d
```

5. If we now check with `docker ps` we see both docker containers. 

```
CONTAINER ID   IMAGE                             COMMAND CREATED        CREATED             STATUS              PORTS                  NAMES
6d58a615930f   jtsaito/simple-app-mysql:latest   "/bin/sh -c /usr/bin   41 seconds ago      Up 44 seconds       0.0.0.0:80->80/tcp     clever_yonath
5966e75f83d0   mysql:latest                      "/entrypoint.sh mysql  22 minutes ago      Up 22 minutes       3306/tcp some-mysql-2
```

6. We can now run visit port 80 on our box (when using docker2boot: `boot2docker ip`).
