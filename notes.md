
Actions:

 * comment out all authorization code
 * Make the first user the current user
 * search and replace for `psu.edu`. changed most to localhost.

# To Install

These instructions should be considered a _best approximation._ Please change
or add to them when needed.

 * Install ruby-1.9.3
 
 * Install imagemagick
   - yum install ImageMagick ImageMagick-devel
 * Install and start redis
   - yum install redis
 * check out repo
   - git clone ...
 * Install and start jetty
   - git ... <submodules>
 * `bundle install`
 * Install [FITS][] and put the path in `config/application.rb`

    curl -O http://fits.googlecode.com/files/fits-0.6.1.zip
    unzip fits-0.6.1.zip
    chmod +x fits-0.6.1/fits.sh

   Adjust `config.fits_path` in `config/application.rb` line 44 to point to the correct place

 * rake tasks: (don't know if this is optimal or even in the correct order)
   some tasks may even be missing

   - `scholarsphere:init`
   - `scholarsphere:generate_secret`
   - `db:create`
   - `db:migrate`
   - `jetty:environment`

 * add a user to the database using the rails console. Give this user admin
   rights (so can view resque monitoring page)

    rails console
    > a = User.create(email:'SOMEONE@localhost', login: 'SOMEONE', display_name: 'Someone', password:'something')
    > a.add_group("admin")
    > a.save


 [FITS]: http://code.google.com/p/fits/

 * start resque workers

    ./start-pool

 * start the server

    ./start-server


# Setting up the server

1. Install ruby 1.9.3p286
1. check out source code
1. Install imagemagick, imagemagick-devel
1. Install FITS service
1. `bundle install`


# Attribution

From Mike Giarlo:

> OK, ScholarSphere's service owner is cool with attribution in the form
> of a link to http://scholarsphere.psu.edu/ with anchor text, "Built on
> Penn State ScholarSphere".  We care less about the verb in that
> sentence, and more that the "Penn State ScholarSphere" string and the
> link are there.  Thanks much for offering!
