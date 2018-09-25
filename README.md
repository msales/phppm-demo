# phppm-demo
Meetup demo to play with different PHP-PM configurations

## setup laravel demo
```
docker run --rm -it -v /$PWD:/app composer:1.6.1 create-project --prefer-dist laravel/laravel laravel-demo3
```

## test standard setup
```
docker run --rm -d -v $PWD/laravel-demo3/:/var/www -p $local_port:80 --name phppm phppm/nginx --workers=8 --bootstrap=laravel --app-env=prod
ab -n 1000 -c 10 http://localhost:$local_port/
docker stop phppm
```

## test event loop setup
```
docker build -t phppm-event .
docker run --rm -d -v $PWD/laravel-demo3/:/var/www -p $local_port:80 --name phppm phppm-event --workers=8 --bootstrap=laravel --app-env=prod
ab -n 1000 -c 10 http://localhost:$local_port/
docker stop phppm
```


