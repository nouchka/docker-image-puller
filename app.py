#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os, sys
import click
import re

from flask import Flask
from flask import request
from flask import jsonify
from flask import abort

from docker import Client

DOCKER_HOST = 'unix://var/run/docker.sock'

app = Flask(__name__)
docker = Client(base_url=DOCKER_HOST)

@app.route('/')
def main():
    return jsonify(success=True), 200

@app.route(os.environ['ROUTE'], methods=['POST'])
def image_puller():
    if not request.args['token']:
        abort(404)

    if request.args['token'] != os.environ['TOKEN']:
        abort(404)

    image = request.args.get('image', '')
    if not image:
      json = request.get_json(force=True)
      image = json['repository']['namespace'] + '/' + json['repository']['name']

    app.logger.debug('Puller for image ' + image)

    images = []
    for cont in docker.images(image, False, filters={'dangling': False}):
        if cont['RepoTags']:
          images.append(cont['RepoTags'][0])
          image = cont['RepoTags'][0].split(':')
          image_name = image[0]
          image_tag  = image[1] if len(image) == 2 else 'latest'
          app.logger.debug('Pulling... '+image_name+':'+image_tag)
          docker.pull(image_name, tag=image_tag)

    print ('Updating', str(len(images)), 'containers with', image, 'image')

    return jsonify(success=True, num_images=len(images)), 200

@click.command()
@click.option('-h',      default='0.0.0.0', help='Set the host')
@click.option('-p',      default=8080,      help='Set the listening port')
@click.option('--debug', default=False,     help='Enable debug option')
def main(h, p, debug):
    if not os.environ.get('TOKEN'):
        print ('ERROR: Missing TOKEN env variable')
        sys.exit(1)

    app.run(
        host  = os.environ.get('HOST', default=h),
        port  = os.environ.get('PORT', default=p),
        debug = os.environ.get('DEBUG', default=debug)
    )

if __name__ == "__main__":
    main()
