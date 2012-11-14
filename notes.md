
Actions:

 * comment out all authorization code
 * Make the first user the current user
 * search and replace for `psu.edu`. changed most to localhost.
 * Install and start jetty
 * Install and start redis
 * Install [FITS][] and put the path in `config/application.rb`
 * rake tasks: (don't know if this is optimal or even in the correct order)
   some tasks may even be missing

   - `scholarsphere:init`
   - `scholarsphere:generate_secret`
   - `db:create`
   - `db:migrate`
   - `jetty:environment`

 * add my user to database using console

    rails console
    > User.create(email:'someone@localhost', login: 'sone', display_name: 'Someone')


 [FITS]: http://code.google.com/p/fits/

To start resque workers

    rake resque:pool

(can also do:

    resque-pool

)

To start server

    unicorn_rails

To start resque monitoring page

    resque-web -r libvirt1.library.nd.edu -N scholarsphere:development

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
