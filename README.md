# Stancer-PW

## Summary

Generate 'Stances' for Vote Data

## Background

[Stancer](https://github.com/tmtmtmtm/stancer) allows you
generate the 'stances' taken by a politician, or group of politicians,
on an Issue.

This is the specific implementation of that for UK voting data.

## Status

This is a work in progress, with the goal of entirely removing this
project. To do this we need to end up solely with configuration files
that can be passed to the generic stancer, using data entirely at remote
sources.

## Current Usage

1. Install 'stancer' from https://github.com/tmtmtmtm/stancer

2. Produce a suitable ``issues.json`` file (see for example, [voteit-data-pw](https://github.com/tmtmtmtm/voteit-data-pw))

3. Produce a ``motions.json`` file 

3. ``ruby bin/make_party_stances.rb > partystances.json``

4. ``ruby bin/make_mp_stances.rb > mpstances.json``

5. Copy those JSON files to your Stance Viewer 
