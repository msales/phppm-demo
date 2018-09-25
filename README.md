# phppm-demo
Meetup demo to play with different PHP-PM configurations

## setup laravel demo
```
docker run --rm -it -v /$PWD:/app composer:1.6.1 create-project --prefer-dist laravel/laravel laravel-demo3
```

## test standard setup
```
local_port=13370
docker run --rm -d -v $PWD/laravel-demo3/:/var/www -p $local_port:80 --name phppm --memory 1G phppm/nginx --workers=2 --bootstrap=laravel --app-env=prod --logging=0 --reload-timeout=3 --max-requests=100
ab -n 5000 -c 200 http://localhost:$local_port/ |grep -e 'Requests per second' -e 'longest request' &
sleep 5; curl --max-time 5 http://localhost:$local_port/

docker stop phppm
```

## test event loop setup
```
docker build -t phppm-event .
local_port=13370
docker run --rm -d -v $PWD/laravel-demo3/:/var/www -p $local_port:80 --name phppm --memory 1G phppm-event --workers=2 --bootstrap=laravel --app-env=prod --logging=0 --reload-timeout=3 --max-requests=100
ab -n 5000 -c 200 http://localhost:$local_port/
docker stop phppm
```


