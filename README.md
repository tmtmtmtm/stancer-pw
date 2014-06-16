# Stancer-PW

## Summary

Generate 'Stances' for Vote Data

## Background

A [voteit-api server](https://github.com/tmtmtmtm/voteit-api) allows you
to access aggregate information on how people or groups voted on
given motions. 

``Stancer`` lets you set up Issues as a collection of motions, apply
weightings to each, and get an aggregate stance on the whole issue.

An example of this can be seen at http://ukvotes.discomposer.com/

## Status

This is a work in progress. 

The code currently has several hard-coded assumptions in relation to its
use with [stance-viewer-uk](https://github.com/tmtmtmtm/stance-viewer-uk)

If you want to use this elsewhere, let me know and I can help factor it
out a little better.

## Usage

1. Produce an ``issues.json`` file — for example, by following the example 
at [voteit-data-pw](https://github.com/tmtmtmtm/voteit-data-pw)

2. ``ruby -Ilib/ bin/make_party_stances.rb > partystances.json``

3. ``ruby -Ilib/ bin/make_mp_stances.rb > mpstances.json``

4. Copy those JSON files to your Stance Viewer (see 
[stance-viewer-uk](https://github.com/tmtmtmtm/stance-viewer-uk) for an
example.)
