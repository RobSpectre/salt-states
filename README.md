# Salt States

My Salt states for maintaining the servers in the various BKH environments.


## Summary

Over a long weekend, I started rolling out [Salt](http://www.saltstack.org) for
configuration management of all my various machines.  I'm new to Salt and Salt
itself is new, so I'm sharing my states with folks to learn more about best
practices and share some of the tricks I've learned along the way.

 
## Conventions

Based on my reading of [the Salt
docs](http://docs.saltstack.com/topics/tutorials/starting_states.html), I've
adopted a flat topology for my state tree.  Currently following these
conventions:

* Isolation - each service is highly segregated from each other. Applications 
  require services and extend with their own configurations.  Create environment
  isolation between applications where possible.
* Environment - Hosts are segregated by hostname.  Production hosts end in a
  public TLD (e.g. .com), private hosts in a private TLD with local resolution
  (e.g. .pvt).  Roles are segregated by CNAME (e.g. web* for web, db* for
  database, etc).
* Users - Sensitive user data is held in a pillar file and created in users.


## Creating a User

Users are maintained by definition in a pillar. To create your users, create a
users.sls file in your pillar tree with this format:

```yaml
users:
  - user:
    username: tdurden
    fullname: Tyler Durden
    password: [Hash - SHA-512 for Ubuntu]
    groups:
      - group1
      - group2
```


## Meta

- Created by [Rob Spectre](http://www.brooklynhacker.com)
- [MIT License](http://opensource.org/licenses/MIT)
- Lovingly crafted in Brooklyn, NY
