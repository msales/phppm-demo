# phppm-demo
Meetup demo to play with different PHP-PM configurations.

What we want to show is, how "event" and connection limits improve stability of PHP-PM under load (our learning).

## setup laravel demo
```
docker run --rm -it -v /$PWD:/app composer:1.6.1 create-project --prefer-dist laravel/laravel laravel-demo3
```

# Limit your docker memory
PHP-PM still has memory leaks, so for testing, limit the memory of your docker container or it will eat up all you ram (and you'll start swapping...).

## Load test setup (NOT a performance test)
* each request takes in average 250ms (usleep(random))
* per worker we can therefore process 4 req/sec

## test standard setup
* unlimited amount of connections from nginx to php-pm
* standard php event loop
```
local_port=13370
docker run --rm -d -v $PWD/laravel-demo3/:/var/www -p $local_port:80 --name phppm --memory 2G phppm/nginx --workers=8 --bootstrap=laravel --app-env=prod --logging=0 --reload-timeout=3 --max-requests=1000
ab -n 1000 -c 16 http://localhost:$local_port/ |grep -e 'Requests per second' -e 'longest request'
ab -n 1000 -c 32 http://localhost:$local_port/ |grep -e 'Requests per second' -e 'longest request' 
sleep 5; curl --max-time 5 http://localhost:$local_port/health

docker stop phppm
```

## test event loop setup
* we allow `$workers*2` connections upstream from nginx to php-pm
* nginx will *reject* all additional requests
* "event" library installed (more reliable event loop under high load)
* AWS xLB has a retry mechanism, so blocked requests will not be "lost"
* Result: always fast answers as there is little queueing. Rather have a few wait longer (retry) than everyone wait (queue)
```
docker build -t phppm-event .
local_port=13370
docker run --rm -d -v $PWD/laravel-demo3/:/var/www -p $local_port:80 --name phppm --memory 2G phppm-event --workers=8 --bootstrap=laravel --app-env=prod --logging=0 --reload-timeout=3 --max-requests=1000
ab -n 1000 -c 16 http://localhost:$local_port/ |grep -e 'Requests per second' -e 'longest request'
ab -n 1000 -c 32 http://localhost:$local_port/ |grep -e 'Requests per second' -e 'longest request'
docker stop phppm
```


