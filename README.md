# WeWoo

Wewoo is a small wrapper library that provides for graph database
management using Ruby. Any graph databases that supports the Rexster graph
server REST API can be integrated with Wewoo.

## Installation

Add this line to your application's Gemfile:

```
gem 'wewoo'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install wewoo
```

## Usage

Wewoo comes bundled with a REPL console to make for experimentation with the
graph database using Ruby a joy.

```
$ wewoo
```

### Connecting to an existing graph database

Dependending on your Rexster configuration, you will need to specify the
host and port to tell Wewoo how to connect. The default url is localhost:8182.
You may also choose to set the configuration in a shell environment variable
WEWOO_URL ie WEWOO_URL='http://localhost:8185'

```ruby
Wewoo::Configuration.url( 'http://localhost:8182' )

# List out all available graphs
Wewoo::Graph.available_graphs #=> ["test_graph", "my_awesome_graph"]

# Connect to an existing graph
g = Wewoo::Graph.new( :my_awesome_graph )

# List out all vertices
g.V # => [v(95084), v(95072), v(95076), v(95088), v(95080)]

# List out all edges
g.E # => [e(1lIN-oJG-4K) [95088-created-95076], e(1lIJ-oJy-4K) [95080-created-95084]]
```

### Adding A Vertex

Most graph database don't allow setting an id on a graph element. Wewoo errs on
letting the graph implementation assign an internal id. It is usually considered
good practice to keep vertex properties to a minimum. Wewoo provides a special
property :gid to integrate the graph element with another data source.
You can leverage :gid to represent a foreign key to another store. Hence :gid must
be unique. If not set the gid will refer to the underlying graph
implementation id.

```ruby
v = g.add_vertex( name: 'Fred', age: 20, active: true, gid: 'user_900' )
v.id        #=> 1234
v.gid       #=> 'user_900'
v.props     #=> {name: 'Fred', age: 20, active: true}
v.props.age #=> 20
```

### Adding An Edge

```ruby
v1 = g.add_vertex( name: 'Fred' )
v2 = g.add_vertex( name: 'Blee' )
e  = g.add_edge( v1, v2, :friend, timestamp: Time.now )
e.id    #=> 1234
e.gid   #=> 1234
e.props #=> {"timestamp"=>"2014-03-01 13:55:26 -0700"}
```

### Deleting Graph Elements

Wewoo provides two way to delete a graph element. If you have a handle on the
instance, you can call destroy on it directly. If not you can remove an element
by calling the associated remove method on a graph instance using the graph
element id.
NOTE: By virtue of a graph database, when deleting a vertex, all associated
edges will be deleted.

```ruby
g.e( 1234 ).destroy
g.v( 5678 ).destroy
# or...
g.remove_vertex( 5678 )
g.remove_edge( 1234 )
```

### Traversing A Graph

The power of graph database is in traversal. Traversal in Wewoo is made available
using the [Gremlin](http://gremlindocs.com/) graph api.

```ruby
# Find all vertices outbound from vertex 1234
g.v( 1234 ).out #=> [v(4567)]

# Find all vertices inbound to vertex 1234
g.v( 1234 ).in  #=> [v(7890), v(7891)]

# Find all vertices directly connected to vertex 1234
g.v( 1234 ).both #=> [v(7890), v(7891), v(4567)]

# Find all edges connected to vertex 1234 with labels fred or created
g.v(1234).bothE( :fred, :created) #=> [e(1lIJ-oJy-4K) [95080-created-95084]]

# Find all vertices with name property blee
g.find_vertices( :name, 'blee' ) #=> [v(1234)]

# Find vertex with gid 1234
g.find_first_vertex( :gid, 1234 ) #=> [v(567)]

# Find vertex with id 456
g.find_vertex( 456 ) #=> [v(456)]
# or...
g.v( 456 )           #=> [v(456)]
```

Wewoo also allows you to use the full gremlin query api using the Wewoo::Graph#query
method. Wewoo does its best to construct graph elements objects with the returning
results.

```ruby
# Find all vertices who's name is fred
g.query( "g.V.out.groupCount.cap") #=> {v(113420)=>2, v(113416)=>2, v(113412)=>1}

# Find all edge with weight < 0.5
g.q( "g.E.has( 'weight', T.lt, 0.5f)" ) #=> [e(1xSj-tve-2W) [113412-friend-113416]]
```

## Releases

0.1.5 Initial drop

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

 Wewoo is released under the [MIT](http://opensource.org/licenses/MIT) license.
