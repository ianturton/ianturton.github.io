---
layout: post
title: Automating Fixing Broken Styles in GeoServer
date: 2020-09-09
categories: geoserver
---
# Automating Fixing Broken Styles in GeoServer

Every so often I discovered that I would got a problem with my GeoServer
install some or all of the layers will lose their connection to the
default Style or to one of their associated Styles. This happens more
often on Windows machines that it does on Linux machines, so I've never
worried too much about reporting it or investigating it.  

However today it occurred on a customer machine and rather than
throwing away the install, and starting again it felt as if I
should fix it. To do this I used a short Python script based on
[`gsconfig-py3`](https://github.com/quadratic-be/gsconfig-py3) which
allows you to have complete control over GeoServer using the rest API.

This is short script I wrote to work through every layer in the
catalogue and checks to see if there is a problem with it if there
is it assigns the generic style to the layer as it's new default
style. It also checks to see if there are any broken Styles in the
associated style list and replaces these with the generic style too. At
present you will need to make sure that you're using my version of
[`gsconfig-py3`](https://github.com/ianturton/gsconfig-py3) as there
are a few small bugs that need to be fixed and some more robustness to
handle the broken layers that I've added to the base version.


~~~py
import click
import logging
import sys
from geoserver.catalog import Catalog

log = logging.getLogger(__name__)
stdout_hdlr = logging.StreamHandler(sys.stdout)
stdout_hdlr.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
stdout_hdlr.setLevel(logging.INFO)
log.addHandler(stdout_hdlr)
log.setLevel(logging.INFO)
cat = Catalog('http://localhost:8080/geoserver/rest/', username='admin', password='geoserver')


def fix_slds():
    """Process all layers in the catalog and make sure there are no null styles"""
    layers = cat.get_layers()
    for layer in layers:
        log.info("Processing layer "+layer.name)
        generic = cat.get_style('generic')
        if layer:
            log.debug("Adding style to  layer "+layer.name)

            if not layer.default_style:

                log.debug("setting genric default style: ")
                layer.default_style = generic
            styles = list(layer.styles)
            if styles:
                log.debug([style.name for style in styles])
                styles = [style if style is not None else generic for style in styles]

            else:
                styles = [generic]

            layer.styles = styles
            cat.save(layer)


@click.group()
@click.option('--debug', is_flag=True)
def cli(debug):
    if debug:
        stdout_hdlr.setLevel(logging.DEBUG)
        log.setLevel(logging.DEBUG)


@cli.command()
def fixer():
    fix_slds()


if __name__ == '__main__':
    cli()
~~~

To use it (provided that you are still using the default admin password and port) is type `python fix_slds fixer` if you called the file something other than `fix_slds.py` you'll need to change that too. If you want to see what's going on throw `--debug` in to make it chattier.
