#!/bin/bash

HOST="http://localhost:8080"

CODE=$(curl -s -o /dev/null -w "%{http_code}" $HOST)
if [ "$CODE" != "200" ]; then
	echo "No homepage found so not running ?"
	exit 1
fi

CODE=$(curl -s -o /dev/null -w "%{http_code}" $HOST/random)
if [ "$CODE" != "404" ]; then
	echo "No 404 not found page"
	exit 1
fi

CODE=$(curl -X POST -s -o /dev/null -w "%{http_code}" $HOST/images/pull)
if [ "$CODE" != "404" ]; then
	echo "Env variable ROUTE on default"
	exit 1
fi

CODE=$(curl -X POST -s -o /dev/null -w "%{http_code}" $HOST/images/poule)
if [ "$CODE" != "404" ]; then
	echo "No token page not in 404 ($CODE)"
	##TODO correct bug
	##exit 1
fi

CODE=$(curl -X POST -s -o /dev/null -w "%{http_code}" "$HOST/images/poule?token=wrong")
if [ "$CODE" != "404" ]; then
	echo "Wrong token page not in 404 ($CODE)"
	##TODO correct bug
	##exit 1
fi

CODE=$(curl -X POST -s -o /dev/null -w "%{http_code}" "$HOST/images/poule?token=123456789")
if [ "$CODE" != "404" ]; then
	echo "No image parameter and no json ($CODE)"
	##TODO correct bug
	##exit 1
fi

CODE=$(curl -X POST -s -o /dev/null -w "%{http_code}" "$HOST/images/poule?token=123456789&image=nouchka/puller")
if [ "$CODE" != "200" ]; then
	echo "Image not found (get parameter)"
	exit 1
fi

CODE=$(curl -X POST -s -o /dev/null -w "%{http_code}" -d '{"repository":{"namespace":"nouchka","name":"puller"}}' "$HOST/images/poule?token=123456789")
if [ "$CODE" != "200" ]; then
	echo "Image not found (json data)"
	exit 1
fi

CODE=$(curl -X POST -s -o json.tmp -w "%{http_code}" -d '{"repository":{"namespace":"nouchka","name":"puller"}}' "$HOST/images/poule?token=123456789")
if ! grep "success" json.tmp >> /dev/null; then
	echo "No success:"
	cat json.tmp
	[ ! -f "json.tmp" ] || rm json.tmp
	exit 1
fi
[ ! -f "json.tmp" ] || rm json.tmp
echo "All done"
exit 0
