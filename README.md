# MohoMine

To start your Phoenix app:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

# Install ODBC for Firebird
First you have to install ODBC app for linux:
`sudo apt-get install odbcinst`

Next you should download Linux ODBC drivers from firebirdsql.com. After 
extracting the tarball you should see a libOdbcFb.so file. Copy this
to /usr/lib folder

Next install firebird (it can also be obtained from firebirdsql.com)
by downloading the tarball and running ./install.sh. It will place
the necessary files into /opt/firebird. Do the following:

 * sudo cp /opt/firebird/lib/libfbclient.so.x.y.z /usr/lib/libfbclient.so.x.y.z
 (where `x`, `y` and `z` are versioning numbers)
 * ln -s /usr/lib/libfbclient.so.x.y.z /usr/lib/libfbclient.so.x
 * ln -s /usr/lib/libfbclient.so.x /usr/lib/libfbclient.so

For legacy applications, this should also be done:

 * ln -s /usr/lib/libfbclient.so /usr/lib/libgds.so.0
 * ln -s /usr/lib/libfbclient.so /usr/lib/libgds.so

After this, add a similar config to /etc/odbcinst.ini
```
[Firebird]
Description    = Firebird driver
Driver         = /usr/lib/libOdbcFb.so
```

Now you are ready to connect to a Firebird database using the `Firebird` 
datasource defined in the /etc/odbcinst.ini file. Erlang has odbc by default
so it makes sense to use it. Try the following to connect:

```
:odbc.start()
{:ok, result} = :odbc.connect('Driver=Firebird;Uid=SYSDBA;Pwd=[your_password];Server=localhost;Port=3050;Database=/path_to_db/db_file.fdb', [])
:odbc.stop()
```
